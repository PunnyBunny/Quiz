import 'package:flutter/material.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz',
      theme: ThemeData(
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
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
