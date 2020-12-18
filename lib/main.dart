import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/info_form.dart';
import 'src/quiz_home.dart';
import 'src/summary.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Permission.microphone.request();
    Permission.storage.request();
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
        '/summary': (context) => SummaryPage(),
      },
    );
  }
}
