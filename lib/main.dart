import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/audio_summary.dart';
import 'src/info_form.dart';
import 'src/mc_summary.dart';
import 'src/quiz_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void _init() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    var statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();
    statuses.forEach((key, value) {
      assert(value.isGranted);
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, _init);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '測試',
      theme: ThemeData(
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
          bodyText2: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
          headline1: TextStyle(
            // use headline 1 for warnings
            fontSize: 24.0,
            color: Colors.red,
          ),
        ),
        brightness: Brightness.dark,
      ),
      initialRoute: '/info_form',
      routes: {
        '/info_form': (context) => InformationForm(),
        '/': (context) => HomePage(),
        '/mc_summary': (context) => McSummaryPage(),
        '/audio_summary': (context) => AudioSummaryPage(),
      },
    );
  }
}
