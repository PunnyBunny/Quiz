import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class SoundManager {
  var _audioPlayer = FlutterSoundPlayer();
  var _audioRecorder = FlutterSoundRecorder();

  Stream<int> _timerStream;
  StreamSubscription<int> _timerSubscription;

  StreamSubscription<PlaybackDisposition> _playerSubscription;

  int timerSeconds = 0;
  bool isUsingAudioService = false;

  Future<void> init() async {
    _audioPlayer = await FlutterSoundPlayer().openAudioSession();
    await _audioPlayer.setSubscriptionDuration(Duration(milliseconds: 20));
    _audioRecorder = await FlutterSoundRecorder().openAudioSession();
  }

  Widget timer() {
    String minute = '${timerSeconds ~/ 60}'.padLeft(2, '0'),
        seconds = '${timerSeconds % 60}'.padLeft(2, '0');
    return Text('$minute:$seconds');
  }

  Future<void> _stopPlayer() async {
    _playerSubscription?.cancel();
    _timerSubscription?.cancel();

    _timerStream = null;
    isUsingAudioService = false;

    await _audioPlayer.stopPlayer();
    await _audioRecorder.stopRecorder();
  }

  Widget recordUserAudioButton({
    File file,
    ButtonStyle style,
    Widget child,
    void Function(int) callback,
    bool disable: false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: style,
        child: child,
        onPressed: () async {
          if (!disable) {
            _timerStream = _stopwatchStream();
            _timerSubscription = _timerStream.listen((seconds) {
              callback(seconds);
            });

            timerSeconds = 0;
            isUsingAudioService = true;
            await _audioRecorder.startRecorder(toFile: file.uri.toString());
          }
        },
      ),
    );
  }

  Widget playUserAudioButton({
    File file,
    ButtonStyle style,
    Widget child,
    void Function(int) onTick,
    bool disable: false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: style,
        child: child,
        onPressed: () async {
          if (!disable) {
            _timerStream = _stopwatchStream();
            _timerSubscription = _timerStream.listen((seconds) {
              timerSeconds = seconds;
            });

            timerSeconds = 0;
            isUsingAudioService = true;

            _playerSubscription = _audioPlayer.onProgress.listen((event) async {
              if (event.duration - event.position <=
                  Duration(milliseconds: 200)) await _stopPlayer();
            });
            await _audioPlayer.startPlayer(fromURI: file.uri.toString());
          }
        },
      ),
    );
  }

  Widget stopUserAudioButton({
    ButtonStyle style,
    Widget child,
    bool disable: false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: style,
        child: child,
        onPressed: () async {
          if (!disable) {
            await _stopPlayer();
          }
        },
      ),
    );
  }

  Stream<int> _stopwatchStream() {
    StreamController<int> controller;
    Timer timer;
    final interval = Duration(seconds: 1);
    int counter = 0;

    void tick(_) {
      ++counter;
      controller.add(counter);
    }

    void stopTimer() {
      timer?.cancel();
      timer = null;
      counter = 0;
      controller.close();
    }

    void startTimer() {
      timer = Timer.periodic(interval, tick);
    }

    controller =
        StreamController<int>(onListen: startTimer, onCancel: stopTimer);

    return controller.stream;
  }
}
