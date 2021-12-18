import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:mobi_lapse/prev_captures_view.dart';
import 'package:http/http.dart' as http;

import 'angels_list.dart';

// const String ROBOT_ADDRESS = 'http://pi';
const String ROBOT_ADDRESS = 'http://192.168.43.38:5000';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobi Lapse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.green
      ),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error loading Firebase ${snapshot.error.toString()}');
            return Text('Something went wrong!');
          } else if (snapshot.hasData) {
            return const MyHomePage(title: 'Mobi Lapse');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String downloadUrl = '';
  bool pressed = false;

  void _update_button() {
    setState(() {
      pressed = !pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please configure the number of plants and their location in the track:',
              textScaleFactor: 2,
              style: TextStyle(fontFamily: 'BIG'),),
            const Expanded(
                child: Center(
                  child: AngelsList()
                ),
            ),
            const SizedBox(
              height: 8,
            ),
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: pressed ? Colors.red : Colors.green,
                  shadowColor: Colors.teal,
                  fixedSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  try {
                    int numberOfItems = ANGLES.length;
                    List<String> angels = [];
                    for (int i = 0; i<numberOfItems; i++){
                      angels.add(ANGLES[i].toString());
                    }
                    print(angels);
                    if (!pressed) {
                      print('Begin');
                      await sendBeginCapture(numberOfItems, angels);
                    } else {
                      print('Stop');
                      await sendStopCapture(numberOfItems);
                    }
                    _update_button();
                  } on http.ClientException catch (e) {
                    print('Error connecting to the robot $e');
                  } on Exception catch (e) {
                    print('General exception $e');
                  }
                },
                child: pressed
                    ? const Text(
                  'Stop Capture',
                  textScaleFactor: 1.4,
                )
                    : const Text(
                    'Begin Capture', textScaleFactor: 1.4)),
            const SizedBox(
              height: 8,
            ),
            TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.lightBlue,
                    fixedSize: const Size.fromHeight(40)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CapturesViewRoute()));
                },
                child:
                const Text('Show previous lapses', textScaleFactor: 1.4)),
            const SizedBox(
              height: 8,
            ),
            Expanded(child: Image.asset(
                'assets/images/icon.jpeg',
                fit: BoxFit.fitWidth
            ),)
          ],
        ),
      )
    );
  }
}

// TODO: add future builder with circle loading and udpating result after sending request

Future<http.Response> sendBeginCapture(int numObjects, List<String> angels) async {
  print('Sending request to begin capture');
  String body = jsonEncode(<String, dynamic>{
    'message': 'Hello from flutter app ${DateTime.now()}',
    'numObjects': numObjects,
    'command': 'start'
  });
  print('Sending request to: ${ROBOT_ADDRESS}/capture');
  print('Request body: $body');

  return http.post(Uri.parse('${ROBOT_ADDRESS}/capture'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: body);
}

Future<http.Response> sendStopCapture(int numObjects) {
  print('Sending request to stop capture');
  String body = jsonEncode(<String, dynamic>{
    'message': 'Hello from flutter app ${DateTime.now()}',
    'command': 'stop',
    'numObjects': numObjects
  });

  print('Sending request to: ${ROBOT_ADDRESS}/capture');
  print('Request body: $body');
  return http.post(Uri.parse('${ROBOT_ADDRESS}/capture'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body);
}
