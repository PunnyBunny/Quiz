import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'globals.dart' as globals;
import 'user_result.dart';

class McSummaryPage extends StatefulWidget {
  @override
  _McSummaryPageState createState() => _McSummaryPageState();
}

class _McSummaryPageState extends State<McSummaryPage> {
  String finalScore = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final UserResult result = ModalRoute.of(context).settings.arguments;
      setState(() {
        finalScore = '最終分數: ${result.score}/${result.testLength}';
      });
      final response = await http.post(
        'http://testquiz.hopto.org:5000',
        body: {
          'action': 'add_new',
          'name': result.name,
          'date_of_birth': globals.dateFormatter.format(result.dateOfBirth),
          'gender': result.gender,
          'score': '${result.score}',
          'test_name': result.testName,
          'test_full_score': '${result.testLength}',
          'type': 'AUDIO',
        },
      );
      assert(response.statusCode == 200);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                finalScore,
                style: TextStyle(fontSize: 40.0, color: Colors.white),
              ),
              Padding(padding: EdgeInsets.all(30.0)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () =>
                    Navigator.popUntil(context, ModalRoute.withName('/')),
                child: Text(
                  '離開',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
