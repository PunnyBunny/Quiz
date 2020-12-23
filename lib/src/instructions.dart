import 'package:flutter/material.dart';

import 'globals.dart';

class InstructionPage extends StatelessWidget {
  final List<Widget> children;

  const InstructionPage({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = Padding(padding: EdgeInsets.all(20.0));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_title(context), padding] +
              children +
              [padding, _backButton(context)],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      '香港中學生粵語語義能力測試',
      style: Theme.of(context).textTheme.headline5,
      textAlign: TextAlign.center,
    );
  }

  Widget _backButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.blue),
      child: Text('知道'),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

Widget infoFormInstructions(context) {
  return FutureBuilder(
      future: globals.loadFromAssets(
          context: context,
          assetFilePath: 'assets/audios/instructions/',
          filename: 'info_page.mp3'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return InstructionPage(
            children: [
              Text('請填上基本資料'),
              globals.soundManager.playUserAudioButton(
                file: snapshot.data,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text("播放指示"),
                onTick: null,
              ),
            ],
          );
        } else {
          return Container();
        }
      });
}
