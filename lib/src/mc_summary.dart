import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';
import 'user_result.dart';

UserResult _result;

class McSummaryPage extends StatelessWidget {
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
                '最終分數: ${_result.score}/${_result.testLength}',
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

  McSummaryPage(UserResult result) {
    _result = result;
    Future.delayed(Duration.zero, () async {
      var request = http.MultipartRequest('POST', Uri.parse(globals.serverUri))
        ..fields['type'] = 'mc'
        ..fields['name'] = _result.name
        ..fields['date_of_birth'] =
            globals.dateFormatter.format(_result.dateOfBirth)
        ..fields['gender'] = _result.gender
        ..fields['test_name'] = _result.testName
        ..fields['score'] = '${_result.score}'
        ..fields['school_name'] = _result.schoolName
        ..fields['grade_level'] = _result.gradeLevel
        ..fields['length'] = '${result.testLength}';

      final response = await request.send();
      assert(response.statusCode == 200);
    });
  }
}
