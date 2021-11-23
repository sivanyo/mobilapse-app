import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'capture_player.dart';
import 'classes/capture_item.dart';

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
          title: Text("Previous Lapses"),
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
                    backgroundColor: Colors.green,
                    shadowColor: Colors.teal,
                    fixedSize: const Size.fromWidth(300),
                  ),
                  onPressed: () async {
                    getPreviousCaptures();
                  },
                  child: const Text('Begin Capture', textScaleFactor: 1.4),
                );
              } else if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            'Watch Capture ${index+1}'),
                        leading: Icon(
                          Icons.videocam_rounded,
                          color: Colors.blue,
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
                          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                              content: new Text(
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

  print(res.length);
  return res;
}

DateTime getDateTimeFromName(String name) {
  final formatter = DateFormat(r'''yyyy-MM-dd'T'hh-mm-ss''');

  DateTime formattedObj =
      formatter.parse(name.split('_').last.split('.').first);
  return formattedObj;
}
