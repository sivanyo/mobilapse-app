import 'package:flutter/material.dart';
import 'package:mobi_lapse/main.dart';
import 'angle.dart';
import 'package:firebase_database/firebase_database.dart' as fb_db;


List<Angle> ANGLES = [Angle()];
var AddColor = MaterialStateProperty.all<Color>(Colors.white);
var RemoveColor = MaterialStateProperty.all<Color>(Colors.white);
var Disabled = MaterialStateProperty.all<Color>(Colors.grey);
var STATE = 0;

class AnglesList extends StatefulWidget {
  const AnglesList({Key? key}) : super(key: key);

  @override
  _AnglesList createState() => _AnglesList();
}

class _AnglesList extends State<AnglesList> {
  final ScrollController _scrollController = ScrollController();


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
        STATE = int.parse(currVal.toString());
        print('State is $ROBOT_STATE');
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    _add() {
      setState(() {
        if (Capturing != 1) {
          ANGLES.add(Angle());
        }
      });
    }

    _remove() {
      setState(() {
        if (ANGLES.isNotEmpty && Capturing != 1) {
          ANGLES.remove(ANGLES.elementAt(ANGLES.length - 1));
        }
      });
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Scrollbar(
            isAlwaysShown: true,
            controller: _scrollController,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: ANGLES.length,
                itemBuilder: (context, index) {
                  return Center(
                      child: ListTile(
                    title: Text(
                      'Choose the angle for item ${index + 1}',
                      style:
                          const TextStyle(fontFamily: 'A', color: Colors.black),
                    ),
                    leading: ANGLES[index],
                  ));
                }),
          )),
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  print('pressed');
                  ROBOT_STATE == 0 ? _add() : null;
                  print(ANGLES.length);
                },
                style: ButtonStyle(
                    backgroundColor: STATE == 1 ? Disabled : AddColor),
                child: Row(
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    Text(
                      'Add plant',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  print('pressed');
                  ROBOT_STATE == 0 ? _remove() : null;
                  print(ANGLES.length);
                },
                style: ButtonStyle(
                    backgroundColor: STATE == 1 ? Disabled : RemoveColor),
                child: Row(
                  children: const [
                    Icon(
                      Icons.remove,
                      color: Colors.black,
                    ),
                    Text('Remove plant', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }
}
