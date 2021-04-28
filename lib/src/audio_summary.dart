import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';
import 'user_result.dart';

UserResult _result;

class AudioSummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(50.0),
                child: Text("謝謝", style: Theme.of(context).textTheme.headline2),
              ),
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

  AudioSummaryPage(UserResult result) {
    _result = result;
    Future.delayed(Duration.zero, () async {
      final zipFile = File('${(await globals.localPath).path}/audios.zip');
      if (await zipFile.exists()) await zipFile.delete();
      await ZipFile.createFromDirectory(
        sourceDir: await globals.userAudioDirectory,
        zipFile: zipFile,
        includeBaseDirectory: true,
      );
      var request = http.MultipartRequest('POST', Uri.parse(globals.serverUri))
        ..fields['type'] = 'audio'
        ..fields['name'] = _result.name
        ..fields['date_of_birth'] =
            globals.dateFormatter.format(_result.dateOfBirth)
        ..fields['gender'] = _result.gender
        ..fields['test_name'] = _result.testName
        ..fields['school_name'] = _result.school
        ..fields['grade_level'] = _result.gradeLevel
        ..fields['length'] = '${_result.testLength}'
        ..files.add(await http.MultipartFile.fromPath('audios', zipFile.path));
      final response = await request.send().timeout(Duration(seconds: 5));
      print(response.statusCode);
      assert(response.statusCode == 200);
    });
  }
}
