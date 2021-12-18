import 'package:flutter/material.dart';
import 'angle.dart';

List<Angle> ANGLES = [Angle()];

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
        ANGLES.add(Angle());
      });
    }
    return Scaffold(
        body:
        Scrollbar(
          child:
          ListView.builder(
              shrinkWrap: true,
              itemCount: ANGLES.length,
              itemBuilder: (context, index) {
                return Center(
                  child: ListTile(
                    title: Text('Choose the angle for item ${index + 1}',
                      style: const TextStyle(
                          fontFamily: 'A',
                          color: Colors.black
                      ),
                    ),
                    leading: ANGLES[index],
                  )
                );
              }
          )
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              print('pressed');
              _add();
              print(ANGLES.length);
            },
            backgroundColor: Colors.green,
            icon: const Icon(Icons.add),
          label: const Text('Add plant'),
        ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
    )
    ;
  }
}
