import 'package:firebase_database/firebase_database.dart' as fb_db;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String alertTitle, String error) {

  // set up the button
  Widget okButton = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(); // dismisses only the dialog and returns nothing
      },
      child: new Text('OK'),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(alertTitle),
    content: Text(error),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

String ParseAlerts (int index){
  return 'Anomaly detected at plant : ${index}';

}

void UpdateFirebase(String valueToUpdate, Map<String, dynamic> newVal){
  fb_db.FirebaseDatabase.instance.ref()
      .child(valueToUpdate)
      .update(newVal);
}