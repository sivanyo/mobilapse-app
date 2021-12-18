import 'package:flutter/material.dart';

var angels =  ["HARD_RIGHT", "SOFT_RIGHT", "STRAIGHT", "SOFT_LEFT", "HARD_LEFT"];

class Angle extends StatefulWidget {
  Angle({Key? key}) : super(key: key);
  String value = angels.first;

  @override
  State<Angle> createState() => _AngleState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return value;
  }
}

class _AngleState extends State<Angle> {
  //var angleValue = angels.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: super.widget.value,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 28,
      elevation: 24,
      style: const TextStyle(color: Colors.black, fontFamily: 'A'),
      underline: Container(
        height: 3,
        color: Colors.green,
      ),
      onChanged: (String? newValue) {
        setState(() {
          super.widget.value = newValue!;
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