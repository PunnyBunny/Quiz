import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'user_result.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String finalScore = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final UserResult result = ModalRoute.of(context).settings.arguments;
      setState(() {
        finalScore = '最終分數: ${result.score}/${result.testFullScore}';
      });
      final response = await http.post(
        "http://testquiz.hopto.org:5000",
        body: {
          'action': 'add_new',
          'name': result.name,
          'date_of_birth': DateFormat("dd-MM-yyyy").format(result.dateOfBirth),
          'gender': result.gender,
          'score': '${result.score}',
          'test_name': result.testName,
          'test_full_score': '${result.testFullScore}',
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
              MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', ModalRoute.withName('/info_form')),
                child: Text(
                  "離開",
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
