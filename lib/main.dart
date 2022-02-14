import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart' as fb_db;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobi_lapse/prev_captures_view.dart';
import 'package:http/http.dart' as http;

import 'alert_dialog.dart';
import 'angle.dart';
import 'angles_list.dart';

// const String ROBOT_ADDRESS = 'http://pi';
// Mor hotspot
// const String ROBOT_ADDRESS = 'http://192.168.43.38:5000';
// Shachar hotspot
String ROBOT_ADDRESS = 'http://172.20.10.9:5000';
int ROBOT_STATE = 0;
int Capturing = 0;
double Speed = 30;

Future main() async {
  //ListenToRobotState();
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
            return const Text('Something went wrong!');
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

  @override
  void initState() {
    super.initState();
    fb_db.FirebaseDatabase.instance
        .ref()
        .child('ROBOT_STATE')
        .onValue
        .listen((event) {
      final currVal = event.snapshot.value.toString();
      setState(() {
        ROBOT_STATE = int.parse(currVal.toString());
        print('State is $ROBOT_STATE');
      });
    });
    fb_db.FirebaseDatabase.instance
        .ref()
        .child('AnomalyData')
        .onValue
        .listen((event) {
      var map = Map<String, dynamic>.from(event.snapshot.value as dynamic);
      setState(() {
        var index = map['index'];
        if (index != -1) {
          var error = ParseAlerts(index);
          showAlertDialog(context, "Anomaly detection", error);
          map['index'] = -1;
          UpdateFirebase("AnomalyData", map);
        }
      });
    });
    fb_db.FirebaseDatabase.instance
        .ref()
        .child('RobotError')
        .onValue
        .listen((event) {
      var map = Map<String, dynamic>.from(event.snapshot.value as dynamic);
      setState(() {
        if (map['Detected']) {
          showAlertDialog(context, "Error", map['Error']);
          map['Detected'] = false;
          UpdateFirebase('RobotError', map);
        }
      });
    });
    fb_db.FirebaseDatabase.instance
        .ref()
        .child('RobotAlert')
        .onValue
        .listen((event) {
      var map = Map<String, dynamic>.from(event.snapshot.value as dynamic);
      setState(() {
        if (map['Detected']) {
          showAlertDialog(context, "Alert", map['Error']);
          map['Detected'] = false;
          UpdateFirebase('RobotAlert', map);
        }
      });
    });
    fb_db.FirebaseDatabase.instance
        .ref()
        .child('RobotWarning')
        .onValue
        .listen((event) {
      var map = Map<String, dynamic>.from(event.snapshot.value as dynamic);
      setState(() {
        if (map['Detected']) {
          showAlertDialog(context, "Warning", map['Warning']);
          map['Detected'] = false;
          UpdateFirebase('RobotAlert', map);
        }
      });
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
              Image.asset(
                'assets/images/icon.jpeg',
                fit: BoxFit.fitWidth,
                width: 160,
              ),
              const Text(
                'Please configure the number of plants and their location on the track:',
                textScaleFactor: 1,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Expanded(
                child: Center(child: AnglesList()),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'Please choose the robot\'s speed:',
                textScaleFactor: 1,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Text('Current speed is : $Speed'),
              Slider(
                  value: Speed,
                  label: "Robot\'s Speed",
                  divisions: 20,
                  onChanged: (double value) {
                    setState(() {
                      Speed = value;
                    });
                  },
                  min: 30,
                  max: 60,
              activeColor: Colors.blue,
              inactiveColor: Colors.black45
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor:
                        ROBOT_STATE == 1 ? Colors.red : Colors.green,
                    shadowColor: Colors.teal,
                    fixedSize: const Size(200, 30)),
                onPressed: () async {
                  try {
                    int numberOfItems = ANGLES.length;
                    List<String> angels = [];
                    for (int i = 0; i < numberOfItems; i++) {
                      angels.add(parseAngle(ANGLES[i].toString()));
                    }
                    print(angels);
                    if (ROBOT_STATE == 0) {
                      print('Begin');
                      Capturing = 1;
                      await sendBeginCapture(
                          numberOfItems, angels, Speed.toInt());
                    } else {
                      print('Stop');
                      Capturing = 0;
                      await sendStopCapture(numberOfItems);
                    }
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
                    (ROBOT_STATE == 1
                        ? const Text(
                            'Stop Capture',
                            textScaleFactor: 1.4,
                          )
                        : const Text('Begin Capture', textScaleFactor: 1.4)),
                  ],
                ),
              ),
              ElevatedButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.lightBlue,
                    fixedSize: const Size(200, 30)),
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
                  Text('Show previous lapses', textScaleFactor: 1.0)
                ]),
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

Future<void> activateListeners() async {
  final databaseReference = fb_db.FirebaseDatabase.instance.ref('/RobotData');
  print('Getting ROBOT_IP');
  databaseReference.child('ROBOT_DATA').onValue.listen((event) {
    var map = Map<String, dynamic>.from(event.snapshot.value as dynamic);
    var val = map['ROBOT_IP'];
    ROBOT_ADDRESS = "http://${val}:5000";
    print('IP received from server: ${val}');
  });
  databaseReference.child('lastUpdated').onValue.listen((event) {
    print('The IP address was last updated at: ${event.snapshot.value}');
  });
}

Future<http.Response> sendBeginCapture(
    int numObjects, List<String> angles, int speed) async {
  await activateListeners();
  print('Complete ROBOT_IP is: $ROBOT_ADDRESS');
  print('Sending request to begin capture');
  String body = jsonEncode(<String, dynamic>{
    'message': 'Hello from flutter app ${DateTime.now()}',
    'numObjects': numObjects,
    'objectAngleList': angles,
    'speed': speed,
    'command': 'start'
  });
  print('Sending request to: $ROBOT_ADDRESS/capture');
  print('Request body: $body');

  return http.post(Uri.parse('$ROBOT_ADDRESS/capture'),
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

  print('Sending request to: $ROBOT_ADDRESS/capture');
  print('Request body: $body');
  return http.post(Uri.parse('$ROBOT_ADDRESS/capture'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body);
}

String parseAngle(String angle) {
  if (angle == angels[2]) {
    return angle.toUpperCase();
  }
  var splitted = angle.split(' ');
  return "${splitted[0].toUpperCase()}_${splitted[1].toUpperCase()}";
}
// to make the app feel smoother
