import 'package:flutter/material.dart';

import 'globals.dart';

class InstructionPage extends StatefulWidget {
  final String instruction;
  final String assetFilePath;
  final String filename;

  const InstructionPage(
      {Key key, this.instruction, this.assetFilePath, this.filename})
      : super(key: key);

  @override
  _InstructionPageState createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: globals.loadFromAssets(
              context: context,
              assetFilePath: widget.assetFilePath,
              filename: widget.filename),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _title(),
                  Text(widget.instruction),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      globals.soundManager.playUserAudioButton(
                        file: snapshot.data,
                        style: ElevatedButton.styleFrom(
                          primary: _isPlaying ? Colors.blueGrey : Colors.blue,
                        ),
                        child: Text("播放指示"),
                        onPressed: () => setState(() {
                          _isPlaying = globals.soundManager.isUsingAudioService;
                        }),
                        disable: _isPlaying,
                      ),
                      globals.soundManager.stopUserAudioButton(
                        style: ElevatedButton.styleFrom(
                          primary: _isPlaying ? Colors.red : Colors.blueGrey,
                        ),
                        child: Icon(Icons.stop),
                        onPressed: () => setState(() {
                          _isPlaying =
                              globals.soundManager.isUsingAudioService;
                        }),
                        disable: !_isPlaying, // disable if not playing
                      ),
                    ],
                  ),
                  _backButton(),
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        '香港中學生粵語語義能力測試',
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.blue),
        child: Text('知道'),
        onPressed: () async {
          await globals.soundManager.stopAudioService();
          Navigator.pop(context);
        },
      ),
    );
  }
}
