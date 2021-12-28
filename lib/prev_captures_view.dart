import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'capture_player.dart';
import 'classes/capture_item.dart';

//todo : fix date time formating to 24-hours formating

class CapturesViewRoute extends StatefulWidget {
  @override
  _CapturesViewState createState() => _CapturesViewState();
}

class _CapturesViewState extends State<CapturesViewRoute> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  List<CaptureItem> captureList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Previous Lapses"),
          backgroundColor: Colors.green,
        ),
        body: FutureBuilder(
            future: getPreviousCaptures(),
            builder: (context, AsyncSnapshot<List<CaptureItem>> snapshot) {
              if (snapshot.hasError) {
                print(snapshot);
                print('Error!');
                return TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.red,
                    shadowColor: Colors.teal,
                    fixedSize: const Size.fromWidth(300),
                  ),
                  onPressed: () {},
                  child: const Text('ERROR'),
                );
              } else if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          'Watch Capture ${index + 1}',
                          style: const TextStyle(
                              fontFamily: 'A', color: Colors.black),
                        ),
                        subtitle: Text(
                          '${snapshot.data!.elementAt(index).name}, captured at ${snapshot.data!.elementAt(index).creationDate}',
                          style: const TextStyle(
                              fontFamily: 'B', color: Colors.green),
                        ),
                        leading: const Icon(
                          Icons.videocam_rounded,
                          color: Colors.greenAccent,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoPlayerRoute(
                                      downloadURL:
                                          snapshot.data![index].downloadURL)));
                        },
                        onLongPress: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Filename: ${snapshot.data![index].name.toString()}')));
                        },
                      );
                    });
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}

Future<List<CaptureItem>> getPreviousCaptures() async {
  print("CALLED!");
  List<CaptureItem> res = [];
  firebase_storage.ListResult result =
      await firebase_storage.FirebaseStorage.instance.ref('captures').list();
  print('done getting items');
  for (firebase_storage.Reference ref in result.items) {
    firebase_storage.FullMetadata meta = await ref.getMetadata();
    DateTime? creationTimeInFirebase = meta.timeCreated;
    DateTime creationDate = getDateTimeFromName(ref.name);
    String downloadURL = await ref.getDownloadURL();
    // String downloadURL = "test";
    CaptureItem capture = CaptureItem(ref.name, creationDate, '5 minutes',
        downloadURL, creationTimeInFirebase);
    res.add(capture);
    print('Found file: $ref');
  }
  print(res.first.name);
  // res.sort((a, b) => getObjectNum(a.name).compareTo(getObjectNum(b.name)));
  // res.sort((a, b) => a.creationDate.compareTo(b.creationDate));
  res.sort((a, b) {
    int cmp = a.creationDate.compareTo(b.creationDate);
    if (cmp != 0) return cmp;
    return getObjectNum(a.name).compareTo(getObjectNum(b.name));
  });
  return res;
}

int getObjectNum(String name) {
  var splitted = name.split('_');
  String objectNum = splitted[1];
  return int.parse(objectNum);
}

DateTime getDateTimeFromName(String name) {
  final formatter = DateFormat(r'''yyyy-MM-dd'T'hh-mm-ss''');

  DateTime formattedObj =
      formatter.parse(name.split('_').last.split('.').first);
  return formattedObj;
}
