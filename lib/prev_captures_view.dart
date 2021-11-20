import 'package:flutter/material.dart';

class PrevCapturesViewRoute extends StatelessWidget {
  const PrevCapturesViewRoute({Key? key, required this.downloadUrl})
      : super(key: key);
  final String downloadUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Previous Lapses"),
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(downloadUrl),
          ],
        ),
      ),
    );
  }
}
