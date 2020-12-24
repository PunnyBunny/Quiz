import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

import 'quiz.dart';

class HomePage extends StatelessWidget {
  final RandomColor _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];
    quizzes.forEach((quiz) {
      buttons.add(Padding(
          padding: EdgeInsets.all(12.0),
          child: _button(
              title: quiz.title,
              color: _randomColor.randomColor(
                  colorHue: ColorHue.blue,
                  colorBrightness: ColorBrightness.dark),
              action: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => quiz)))));
    });
    return WillPopScope(
      child: Scaffold(
        body: Center(
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                      Text('請依次序選擇一個測試',
                          style: Theme.of(context).textTheme.headline4),
                      _instructionButton(context)
                    ] +
                    buttons,
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }

  Widget _button({String title, Color color, Function action}) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(350.0, 50.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: Colors.white, width: 3.0),
          primary: _randomColor.randomColor(
            colorHue: ColorHue.blue,
            colorBrightness: ColorBrightness.dark,
          ),
        ),
        onPressed: action,
        child: Text(title),
      ),
    );
  }

  Widget _instructionButton(context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
        ),
        child: Text('查看指示'),
        onPressed: () async =>
            await Navigator.pushNamed(context, '/instructions'),
      ),
    );
  }
}
