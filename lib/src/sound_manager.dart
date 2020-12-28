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
  bool isPausingAudioService = false;

  Function() _recorderOnStop, _playerOnStop;

  Future<void> init() async {
    _audioPlayer = await FlutterSoundPlayer().openAudioSession();
    await _audioPlayer.setSubscriptionDuration(Duration(milliseconds: 20));
    _audioRecorder = await FlutterSoundRecorder().openAudioSession();
    await _audioRecorder.setSubscriptionDuration(Duration(milliseconds: 20));
  }

  Widget timer() {
    String minute = '${timerSeconds ~/ 60}'.padLeft(2, '0'),
        seconds = '${timerSeconds % 60}'.padLeft(2, '0');
    return Text('$minute:$seconds', style: TextStyle(fontSize: 30.0));
  }

  Future<void> pauseAudioService() async {
    isPausingAudioService = true;
    if (!_audioPlayer.isStopped) await _audioPlayer.pausePlayer();
    if (!_audioRecorder.isStopped) await _audioRecorder.pauseRecorder();
    _playerSubscription?.pause();
    _timerSubscription?.pause();
  }

  Future<void> resumeAudioService() async {
    isPausingAudioService = false;
    if (_audioPlayer.isPaused) await _audioPlayer.resumePlayer();
    if (_audioRecorder.isPaused) await _audioRecorder.resumeRecorder();
    _playerSubscription?.resume();
    _timerSubscription?.resume();
  }

  Future<void> stopAudioService({bool callOnStop: true}) async {
    _playerSubscription?.cancel();
    _timerSubscription?.cancel();

    isUsingAudioService = false;
    isPausingAudioService = false;

    await _audioPlayer.stopPlayer();
    await _audioRecorder.stopRecorder();

    if (callOnStop) {
      _playerOnStop?.call();
      _recorderOnStop?.call();
    }

    _playerOnStop = null;
    _recorderOnStop = null;
  }

  Widget recordAudioButton({
    File file,
    ButtonStyle style,
    Widget child,
    void Function() onTick,
    void Function() onPressed,
    void Function() onStop,
    bool disable: false,
  }) {
    return ElevatedButton(
      style: style,
      child: child,
      onPressed: () async {
        _recorderOnStop = onStop;
        if (!disable) {
          _timerStream = _stopwatchStream();
          _timerSubscription = _timerStream.listen((seconds) {
            timerSeconds = seconds;
            onTick?.call();
          });

          timerSeconds = 0;
          onTick?.call();
          isUsingAudioService = true;

          await _audioRecorder.startRecorder(toFile: file.path);
        }
        onPressed();
      },
    );
  }

  Widget playAudioButton({
    File file,
    ButtonStyle style,
    Widget child,
    void Function() onTick,
    void Function() onPressed,
    void Function() onStop,
    bool disable: false,
  }) {
    return ElevatedButton(
      style: style,
      child: child,
      onPressed: () async {
        _playerOnStop = onStop;
        if (!disable) {
          _timerStream = _stopwatchStream();
          _timerSubscription = _timerStream.listen((seconds) {
            timerSeconds = seconds;
            onTick?.call();
          });

          timerSeconds = 0;
          onTick?.call();
          isUsingAudioService = true;

          _playerSubscription = _audioPlayer.onProgress.listen((event) async {
            if (event.duration - event.position <=
                Duration(milliseconds: 200)) {
              await stopAudioService();
            }
          });

          await _audioPlayer.startPlayer(fromURI: file.path, codec: Codec.mp3);
          onPressed();
        }
      },
    );
  }

  Widget stopAudioButton({
    ButtonStyle style,
    Widget child,
    bool disable: false,
    void Function() onPressed,
  }) {
    return ElevatedButton(
      style: style,
      child: child,
      onPressed: () async {
        if (!disable) {
          await stopAudioService();
          onPressed();
        }
      },
    );
  }

  Widget pauseAudioServiceButton({
    ButtonStyle style,
    Widget child,
    bool disable: false,
    void Function() onPressed,
  }) {
    return ElevatedButton(
      style: style,
      child: child,
      onPressed: () {
        if (!disable) {
          pauseAudioService();
          onPressed();
        }
      },
    );
  }

  Widget resumeAudioServiceButton({
    ButtonStyle style,
    Widget child,
    bool disable: false,
    void Function() onPressed,
  }) {
    return ElevatedButton(
      style: style,
      child: child,
      onPressed: () {
        if (!disable) {
          resumeAudioService();
          onPressed();
        }
      },
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
    }

    void startTimer() {
      counter = 0;
      timer = Timer.periodic(interval, tick);
    }

    void resumeTimer() {
      timer = Timer.periodic(interval, tick);
    }

    controller = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onPause: stopTimer,
      onResume: resumeTimer,
    );

    return controller.stream;
  }
}
