import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

import 'audio_manager.dart';
import 'instructions.dart';
import 'quiz.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _randomColor = RandomColor();
  final _audioManager = AudioManager();

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];
    quizzes.forEach((quiz) {
      buttons.add(
        Padding(
          padding: EdgeInsets.all(12.0),
          child: _button(
            title: quiz.title,
            color: _randomColor.randomColor(
                colorHue: ColorHue.blue, colorBrightness: ColorBrightness.dark),
            action: () async {
              await _audioManager.stopAudioService();
              await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => quiz));
            },
          ),
        ),
      );
    });

    return WillPopScope(
      child: Scaffold(
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                    _instructionTile(),
                    Divider(color: Colors.white),
                    Text('請依次序完成各部分',
                        style: Theme.of(context).textTheme.headline4),
                  ] +
                  buttons,
            ),
          ],
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

  Widget _instructionTile() {
    return ExpansionTile(
      initiallyExpanded: true,
      maintainState: true,
      title: Text('查看指示', style: Theme.of(context).textTheme.headline5),
      children: [_instructionPage()],
    );
  }

  Widget _instructionPage() {
    return InstructionPage(
      instruction: '請依次序完成各部分。',
      audioAssetFilePath: 'assets/audios/instructions',
      audioFilename: 'home_page.mp3',
      audioManager: _audioManager,
    );
  }
}
