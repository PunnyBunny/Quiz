import 'package:flutter/material.dart';

import 'globals.dart';

class InstructionPage extends StatefulWidget {
  final String instruction;
  final String assetFilePath;
  final String filename;
  final void Function() onPressed;
  final void Function() onStop;
  final bool disable;

  const InstructionPage(
      {Key key,
      this.instruction,
      this.assetFilePath,
      this.filename,
      this.onPressed,
      this.onStop,
      this.disable: false})
      : super(key: key);

  @override
  _InstructionPageState createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  bool _isUsingAudioService = false;
  bool _isPausingAudioService = false;

  @override
  Widget build(BuildContext context) {
    void getButtonStates() {
      setState(() {
        _isUsingAudioService = globals.soundManager.isUsingAudioService;
        _isPausingAudioService = globals.soundManager.isPausingAudioService;
      });
      widget.onPressed?.call();
    }

    return FutureBuilder(
        future: globals.loadFromAssets(
            context: context,
            assetFilePath: widget.assetFilePath,
            filename: widget.filename),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _title(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.instruction, textAlign: TextAlign.left),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: globals.soundManager.playAudioButton(
                            file: snapshot.data,
                            style: ElevatedButton.styleFrom(
                              primary: widget.disable || _isUsingAudioService
                                  ? Colors.blueGrey
                                  : Colors.blue,
                            ),
                            child: Text("播放指示"),
                            onPressed: () {
                              getButtonStates();
                              widget.onPressed();
                            },
                            onStop: () {
                              getButtonStates();
                              widget.onStop();
                            },
                            disable: widget.disable || _isUsingAudioService,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: globals.soundManager.stopAudioButton(
                            style: ElevatedButton.styleFrom(
                              primary: _isUsingAudioService
                                  ? Colors.red
                                  : Colors.blueGrey,
                            ),
                            child: Icon(Icons.stop),
                            onPressed: () {
                              getButtonStates();
                              widget.onStop?.call();
                            },
                            disable:
                                !_isUsingAudioService, // disable if not playing
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: globals.soundManager.pauseAudioServiceButton(
                            style: ElevatedButton.styleFrom(
                              primary: _isPausingAudioService ||
                                      !_isUsingAudioService
                                  ? Colors.blueGrey
                                  : Colors.blue,
                            ),
                            child: Icon(Icons.pause),
                            onPressed: getButtonStates,
                            disable:
                                _isPausingAudioService || !_isUsingAudioService,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: globals.soundManager.resumeAudioServiceButton(
                            style: ElevatedButton.styleFrom(
                              primary: !_isPausingAudioService ||
                                      !_isUsingAudioService
                                  ? Colors.blueGrey
                                  : Colors.blue,
                            ),
                            child: Icon(Icons.play_arrow),
                            onPressed: getButtonStates,
                            disable: widget.disable ||
                                !_isPausingAudioService ||
                                !_isUsingAudioService,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        '香港中學生粵語語義能力測試',
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.left,
      ),
    );
  }
}
