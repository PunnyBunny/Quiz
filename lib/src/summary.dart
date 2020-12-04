import 'package:flutter/material.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    final String finalScore = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Final Score: $finalScore",
              style: TextStyle(fontSize: 35.0),
            ),
            Padding(padding: EdgeInsets.all(30.0)),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blue,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/', ModalRoute.withName('/info_form')),
              child: Text(
                "Leave",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
