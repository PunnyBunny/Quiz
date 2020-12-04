import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

import 'basic_quiz.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RandomColor _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];
    quizzes.forEach((quiz) {
      buttons.add(_button(
          quiz.title,
          _randomColor.randomColor(
              colorHue: ColorHue.blue, colorBrightness: ColorBrightness.dark),
          () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => quiz))));
      buttons.add(Padding(padding: EdgeInsets.all(12.0)));
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
      ),
      body: Container(
        margin: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        ),
      ),
    );
  }

  Widget _button(String title, Color color, Function func) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(350.0, 50.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: Colors.white, width: 3.0),
        primary: _randomColor.randomColor(
          colorHue: ColorHue.blue,
          colorBrightness: ColorBrightness.dark,
        ),
      ),
      onPressed: func,
      child: Text(title),
    );
  }
}
