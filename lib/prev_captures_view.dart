import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'capture_player.dart';
import 'classes/capture_item.dart';

List<CaptureItem> captureList = [];

//todo : fix date time formating to 24-hours formating

class CapturesViewRoute extends StatefulWidget {
  @override
  _CapturesViewState createState() => _CapturesViewState();
}

class _CapturesViewState extends State<CapturesViewRoute> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  bool start = false;

  @override
  Widget build(BuildContext context) {
    _addLapse(CaptureItem capture) {
      setState(() {
        captureList.add(capture);
      });
    }

    void getPreviousCaptures() async {
      print("CALLED!");
      firebase_storage.ListResult result = await firebase_storage
          .FirebaseStorage.instance
          .ref('captures')
          .list();
      print('done getting items');
      for (firebase_storage.Reference ref in result.items) {
        firebase_storage.FullMetadata meta = await ref.getMetadata();
        DateTime? creationTimeInFirebase = meta.timeCreated;
        DateTime creationDate = getDateTimeFromName(ref.name);
        String downloadURL = await ref.getDownloadURL();
        // String downloadURL = "test";
        CaptureItem capture = CaptureItem(
            ref.name, creationDate, downloadURL, creationTimeInFirebase);
        _addLapse(capture);
        print('Found file: $ref');
        print(captureList.length);
      }
      print(captureList.first.name);
      captureList.sort((a, b) {
        int cmp = a.creationDate.compareTo(b.creationDate);
        if (cmp != 0) return cmp;
        return getObjectNum(a.name).compareTo(getObjectNum(b.name));
      });
    }

    if (!start) {
      start = true;
      captureList.clear();
      getPreviousCaptures();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Previous Lapses"),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              start = false;
              Navigator.pop(context, false);
            },
          ),
        ),
        body: ListView.builder(
            shrinkWrap: true,
            itemCount: captureList.length,
            itemBuilder: (context, index) {
              return Card(
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    title: Text(
                      'Watch Capture ${index + 1}',
                      style:
                          const TextStyle(fontFamily: 'A', color: Colors.black),
                    ),
                    subtitle: Text(
                      '${captureList.elementAt(index).name}, captured at '
                      '${captureList.elementAt(index).creationDate}',
                      style:
                          const TextStyle(fontFamily: 'B', color: Colors.green),
                    ),
                    leading: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoPlayerRoute(
                                  downloadURL:
                                      captureList[index].downloadURL)));
                    },
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Filename: ${captureList[index].name.toString()}')));
                    },
                  ));
            }));
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
}
