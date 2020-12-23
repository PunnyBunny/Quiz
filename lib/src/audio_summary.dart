import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'globals.dart';
import 'user_result.dart';

class AudioSummaryPage extends StatefulWidget {
  @override
  _AudioSummaryPageState createState() => _AudioSummaryPageState();
}

class _AudioSummaryPageState extends State<AudioSummaryPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final UserResult result = ModalRoute.of(context).settings.arguments;

      final zipFile =
          File((await getTemporaryDirectory()).path + '/audios.zip');
      await zipFile.create();
      await ZipFile.createFromDirectory(
          sourceDir: await globals.userAudiosPath(), zipFile: zipFile);
      var request = http.MultipartRequest('POST', Uri.parse(globals.serverUri))
        ..fields['action'] = 'add_new'
        ..fields['type'] = 'audio'
        ..fields['name'] = result.name
        ..fields['date_of_birth'] =
            globals.dateFormatter.format(result.dateOfBirth)
        ..fields['gender'] = '${result.score}'
        ..fields['test_name'] = result.testName
        ..files.add(await http.MultipartFile.fromPath('audios', zipFile.path));

      final response = await request.send();
      assert(response.statusCode == 200);
      print('uploaded audios zip file');
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
}
