import 'package:flutter/material.dart';

var angels =  ["HARD_RIGHT", "SOFT_RIGHT", "STRAIGHT", "SOFT_LEFT", "HARD_LEFT"];

class Angle extends StatefulWidget {
  const Angle({Key? key}) : super(key: key);

  @override
  State<Angle> createState() => _AngleState();
}

class _AngleState extends State<Angle> {
  var angleValue = angels.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: angleValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 28,
      elevation: 24,
      style: const TextStyle(color: Colors.deepPurple, fontFamily: 'A'),
      underline: Container(
        height: 3,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          angleValue = newValue!;
        });
      },
      items: angels.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}