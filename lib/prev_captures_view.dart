import 'dart:html';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
            builder: (context, snapshot) {
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
                    // await listExample();
                    // await downloadURLExample();
                  },
                  child: const Text('Begin Capture', textScaleFactor: 1.4),
                );
              } else if (snapshot.hasData) {
                return Text('The answer to everything is ${snapshot.data}');
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            })
        // ListView(
        //   padding: const EdgeInsets.all(8),
        //   children: <Widget>[
        //     Container(
        //       height: 50,
        //       color: Colors.amber[600],
        //       child: const Center(child: Text('Entry A')),
        //     ),
        //     Container(
        //       height: 50,
        //       color: Colors.amber[500],
        //       child: const Center(child: Text('Entry B')),
        //     ),
        //     Container(
        //       height: 50,
        //       color: Colors.amber[100],
        //       child: const Center(child: Text('Entry C')),
        //     ),
        //   ],
        // )
        // Center(
        //   child: Column(
        //     children: [
        //       Image.network(downloadUrl),
        //     ],
        //   ),
        // ),
        );
  }
}

Future getPreviousCaptures() async {
  print("CALLED!");
  List<CaptureItem> res = [];
  firebase_storage.ListResult result =
      await firebase_storage.FirebaseStorage.instance.ref().list();
  print('done getting items');
  result.items.forEach((firebase_storage.Reference ref) {
    print('Found file: $ref');
  });

  return res;
}

class PrevCapturesViewRoute extends StatelessWidget {
  PrevCapturesViewRoute({Key? key, required this.downloadUrl})
      : super(key: key);
  final String downloadUrl;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  List<CaptureItem> captureList = [];

  Future<void> getPreviousCaptures() async {
    List<CaptureItem> res;
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instance.ref('images').list();
    print('done getting items');
    result.items.forEach((firebase_storage.Reference ref) {
      print('Found file: $ref');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Previous Lapses"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.amber[600],
              child: const Center(child: Text('Entry A')),
            ),
            Container(
              height: 50,
              color: Colors.amber[500],
              child: const Center(child: Text('Entry B')),
            ),
            Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry C')),
            ),
          ],
        )
        // Center(
        //   child: Column(
        //     children: [
        //       Image.network(downloadUrl),
        //     ],
        //   ),
        // ),
        );
  }
}

class CaptureItem {
  String name;
  DateTime creationDate;
  String length;

  CaptureItem(this.name, this.creationDate, this.length);
}
