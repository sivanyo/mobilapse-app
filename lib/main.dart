import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:mobi_lapse/prev_captures_view.dart';

import 'capture_player.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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

  Future<void> listExample() async {
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instance.ref().listAll();
    print('done getting items');
    result.items.forEach((firebase_storage.Reference ref) {
      print('Found file: $ref');
    });

    result.prefixes.forEach((firebase_storage.Reference ref) {
      print('Found directory: $ref');
    });
  }

  Future<void> downloadURLExample() async {
    downloadUrl = await firebase_storage.FirebaseStorage.instance
        .ref('1eca8e1a-59fe-4df4-845c-fc1c38632eb3.jpg')
        .getDownloadURL();

    print(downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
                'Please select the number of plants in the garden track:',
                textScaleFactor: 2),
            MyStatefulWidget(),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: pressed ? Colors.red : Colors.green,
                  shadowColor: Colors.teal,
                  fixedSize: const Size.fromWidth(300),
                ),
                onPressed: () async {
                  _update_button();
                  // await listExample();
                  // await downloadURLExample();
                },
                child: const Text('Begin Capture', textScaleFactor: 1.4)),
            SizedBox(
              height: 15,
            ),
            TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.lightBlue,
                    fixedSize: const Size.fromWidth(300)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CapturesViewRoute()));
                },
                child:
                    const Text('Show previous lapses', textScaleFactor: 1.4)),
            SizedBox(
              height: 15,
            ),
            // TextButton(
            //     style: TextButton.styleFrom(
            //         primary: Colors.black,
            //         backgroundColor: Colors.lightBlue,
            //         fixedSize: const Size.fromWidth(300)),
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => VideoPlayerRoute()));
            //     },
            //     child: const Text('View video', textScaleFactor: 1.4)),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String dropdownValue = '3';

  List<String> getItemList() {
    List<String> res = [];
    for (int i = 1; i <= 10; i++) {
      res.add(i.toString());
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 28,
      elevation: 24,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 3,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: getItemList().map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

// Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
// TextButton(style: TextButton.styleFrom(primary: Colors.black,
// backgroundColor: Colors.green,
// fixedSize: const Size.fromHeight(50)), onPressed: () {},
// child: const Text('Play vid 1'),),
// TextButton(style: TextButton.styleFrom(primary: Colors.black,
// backgroundColor: Colors.green,
// fixedSize: const Size.fromHeight(50)), onPressed: () {},
// child: const Text('Play vid 2'),),
// TextButton(style: TextButton.styleFrom(primary: Colors.black,
// backgroundColor: Colors.green,
// fixedSize: const Size.fromHeight(50)), onPressed: () {},
// child: const Text('Play vid 3'))
// ],)
