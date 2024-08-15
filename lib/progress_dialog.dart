import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20.0),
            Text("Downloading...", style: TextStyle(fontFamily: 'Urbanist')),
          ],
        ),
      ),
    );
  }
}