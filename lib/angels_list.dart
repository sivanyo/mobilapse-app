import 'package:flutter/material.dart';
import 'angle.dart';

List<String> ITEMS = ['1'];
List<Angle> ANGLES = [const Angle()];

class AngelsList extends StatefulWidget {
  const AngelsList({Key? key}) : super(key: key);

  @override
  _AngelsList createState() => _AngelsList();
}

class _AngelsList extends State<AngelsList> {

  @override
  Widget build(BuildContext context) {
    _add() {
      setState(() {
        ANGLES.add(new Angle());
      });
    };
    return Scaffold(
        body: ListView.builder(
            shrinkWrap: true,
            itemCount: ITEMS.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Choose the angle for item ${index + 1}',
                  style: const TextStyle(
                      fontFamily: 'A',
                      color: Colors.black
                  ),
                ),
                leading: ANGLES[index],
              );
            }
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              print('pressed');
              _add();
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.navigation)
        )
    )
    ;
  }
}
