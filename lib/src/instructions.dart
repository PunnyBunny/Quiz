import 'dart:io';

import 'package:flutter/material.dart';

import 'globals.dart';

Widget playAudioFromFileButton(
    ButtonStyle style, Text instruction, File file) {
  return ElevatedButton(
    style: style,
    child: instruction,
    onPressed: () {
      Globals.soundPlayer.startPlayer(fromURI: file.uri.toString());
    },
  );
}

class InstructionPage extends StatefulWidget {
  final List<Widget> widgets;

  InstructionPage(this.widgets);

  @override
  _InstructionPageState createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: widget.widgets),
      ),
    );
  }
}
