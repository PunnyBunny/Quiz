import 'dart:io';

import 'package:flutter/material.dart';

import 'audio_manager.dart';
import 'globals.dart';

class InstructionPage extends StatefulWidget {
  final String instruction;
  final String audioAssetFilePath;
  final String audioFilename;
  final AudioManager audioManager;
  final void Function() onPressed;
  final void Function() onStop;
  final bool disable;

  const InstructionPage({
    Key key,
    @required this.instruction,
    @required this.audioAssetFilePath,
    @required this.audioFilename,
    @required this.audioManager,
    this.onPressed,
    this.onStop,
    this.disable: false,
  }) : super(key: key);

  @override
  _InstructionPageState createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  bool _isUsingAudioService = false;
  bool _isPausingAudioService = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: globals.loadFromAssets(
        context: context,
        assetFilePath: widget.audioAssetFilePath,
        filename: widget.audioFilename,
      ),
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
                  _instruction(),
                  _audioRow(snapshot.data),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
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

  Widget _instruction() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(widget.instruction, textAlign: TextAlign.left),
    );
  }

  void _getButtonStates() {
    setState(() {
      _isUsingAudioService = widget.audioManager.isUsingAudioService;
      _isPausingAudioService = widget.audioManager.isPausingAudioService;
    });
    widget.onPressed?.call();
  }

  Widget _audioRow(File file) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _playInstructionButton(file),
          _stopPlayingInstructionButton(),
          _pausePlayingInstructionButton(),
          _resumePlayingInstructionButton(),
        ],
      ),
    );
  }

  Widget _playInstructionButton(File file) {
    return widget.audioManager.playAudioButton(
      file: file,
      style: ElevatedButton.styleFrom(
        primary: widget.disable || _isUsingAudioService
            ? Colors.blueGrey
            : Colors.blue,
      ),
      child: Text("播放指示"),
      onPressed: () {
        _getButtonStates();
        widget.onPressed?.call();
      },
      onStop: () {
        _getButtonStates();
        widget.onStop?.call();
      },
      disable: widget.disable || _isUsingAudioService,
    );
  }

  Widget _stopPlayingInstructionButton() {
    return widget.audioManager.stopAudioButton(
      style: ElevatedButton.styleFrom(
        primary: _isUsingAudioService ? Colors.red : Colors.blueGrey,
      ),
      child: Icon(Icons.stop),
      onPressed: () {
        _getButtonStates();
        widget.onStop?.call();
      },
      disable: !_isUsingAudioService, // disable if not playing
    );
  }

  Widget _pausePlayingInstructionButton() {
    return widget.audioManager.pauseAudioServiceButton(
      style: ElevatedButton.styleFrom(
        primary: _isPausingAudioService || !_isUsingAudioService
            ? Colors.blueGrey
            : Colors.blue,
      ),
      child: Icon(Icons.pause),
      onPressed: _getButtonStates,
      disable: _isPausingAudioService || !_isUsingAudioService,
    );
  }

  Widget _resumePlayingInstructionButton() {
    return widget.audioManager.resumeAudioServiceButton(
      style: ElevatedButton.styleFrom(
        primary: !_isPausingAudioService || !_isUsingAudioService
            ? Colors.blueGrey
            : Colors.blue,
      ),
      child: Icon(Icons.play_arrow),
      onPressed: _getButtonStates,
      disable:
          widget.disable || !_isPausingAudioService || !_isUsingAudioService,
    );
  }
}
