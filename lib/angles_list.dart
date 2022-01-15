import 'package:flutter/material.dart';
import 'package:mobi_lapse/main.dart';
import 'angle.dart';

List<Angle> ANGLES = [Angle()];
var AddColor = MaterialStateProperty.all<Color>(Colors.white);
var RemoveColor = MaterialStateProperty.all<Color>(Colors.white);
var Disabled = MaterialStateProperty.all<Color>(Colors.grey);

class AnglesList extends StatefulWidget {
  const AnglesList({Key? key}) : super(key: key);

  @override
  _AnglesList createState() => _AnglesList();
}

class _AnglesList extends State<AnglesList> {
  final ScrollController _scrollController = ScrollController();

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
                    backgroundColor: Capturing == 1 ? Disabled : AddColor),
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
                    backgroundColor: Capturing == 1 ? Disabled : RemoveColor),
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
