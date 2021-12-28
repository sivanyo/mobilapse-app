import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobi_lapse/prev_captures_view.dart';
import 'package:http/http.dart' as http;

import 'angle.dart';
import 'angles_list.dart';

// const String ROBOT_ADDRESS = 'http://pi';
// Mor hotspot
// const String ROBOT_ADDRESS = 'http://192.168.43.38:5000';
// Shachar hotspot
String ROBOT_ADDRESS = 'http://172.20.10.9:5000';
int Capturing = 0;

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
      theme:
          ThemeData(primarySwatch: Colors.blue, backgroundColor: Colors.green),
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
            );}},
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
              Expanded(
                child: Image.asset(
                  'assets/images/icon.jpeg',
                  fit: BoxFit.fitWidth,
                  width: 200,
                ),
              ),
              const Text(
                'Please configure the number of plants and their location in the track:',
                textScaleFactor: 1,
                style: TextStyle(fontSize: 25),
              ),
              const Expanded(
                child: Center(child: AnglesList()),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  ElevatedButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: pressed ? Colors.red : Colors.green,
                        shadowColor: Colors.teal,
                        fixedSize: const Size.fromHeight(30),
                      ),
                      onPressed: () async {
                        try {
                          int numberOfItems = ANGLES.length;
                          List<String> angels = [];
                          for (int i = 0; i < numberOfItems; i++) {
                            angels.add(ParseAngle(ANGLES[i].toString()));
                          }
                          print(angels);
                          if (!pressed) {
                            print('Begin');
                            Capturing = 1;
                            await sendBeginCapture(numberOfItems, angels);
                          } else {
                            print('Stop');
                            Capturing = 0;
                            await sendStopCapture(numberOfItems);
                          }
                          _update_button();
                        } on http.ClientException catch (e) {
                          print('Error connecting to the robot $e');
                        } on Exception catch (e) {
                          print('General exception $e');
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.video_call),
                          const SizedBox.square(
                            dimension: 2,
                          ),
                          (pressed
                              ? const Text(
                                  'Stop Capture',
                                  textScaleFactor: 1.4,
                                )
                              : const Text('Begin Capture',
                                  textScaleFactor: 1.4)),
                        ],
                      ),
                  ),
                  ElevatedButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.lightBlue,
                        fixedSize: const Size.fromHeight(30)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CapturesViewRoute()));
                    },
                    child: Row(children: const [
                      Icon(Icons.video_library),
                      SizedBox.square(
                        dimension: 2,
                      ),
                      Text('Show previous lapses', textScaleFactor: 1.4)
                    ]),
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ));
  }
}

// TODO: add future builder with circle loading and updating result after sending request

Future<void> ActivateListeners() async{
  final databaseReference = FirebaseDatabase.instance.reference();
  databaseReference
      .child('ROBOT_IP')
      .onValue.listen((event) {
    ROBOT_ADDRESS = "http://${event.snapshot.value}:5000";
    print("@");
    print(event.snapshot.value);
  });
}

Future<http.Response> sendBeginCapture(
    int numObjects, List<String> angles) async {
  await ActivateListeners();
  print(ROBOT_ADDRESS);
  print('Sending request to begin capture');
  String body = jsonEncode(<String, dynamic>{
    'message': 'Hello from flutter app ${DateTime.now()}',
    'numObjects': numObjects,
    'objectAngleList': angles,
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

String ParseAngle(String angle){
  if(angle == angels[2]) {
    return angle.toUpperCase();
  }
  var splitted = angle.split(' ');
  return "${splitted[0].toUpperCase()}_${splitted[1].toUpperCase()}";
}
// to make the app feel smoother