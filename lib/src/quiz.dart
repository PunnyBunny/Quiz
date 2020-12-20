import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

import 'user_info.dart';
import 'user_result.dart';

part 'quiz.g.dart';

var quizzes = List<Quiz>();

enum QuizType {
  @JsonValue("audio")
  AUDIO,
  @JsonValue("mc")
  MULTIPLE_CHOICE,
}

@JsonSerializable()
class Quiz extends StatefulWidget {
  Quiz(this.title, this.type, this.length, this.choices, this.questions,
      this.correctAnswers, this.audios, this.images);

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  Map<String, dynamic> toJson() => _$QuizToJson(this);

  @JsonKey(required: true)
  final String title;

  @JsonKey(required: true)
  final QuizType type;

  @JsonKey(required: true)
  final List<String> questions;

  @JsonKey(required: true)
  final int length;

  // properties that only exists in quizzes with type MC:
  final List<String> correctAnswers;
  final List<String> audios;
  final List<String> images;
  final List<List<String>> choices;

  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  Stream<int> _timerStream;
  StreamSubscription<int> _timerSubscription;
  int _timerSeconds = 0;

  StreamSubscription<PlaybackDisposition> _playerSubscription;

  bool _isUsingAudioService = false;
  bool _recorded = false;

  int _questionNumber = 0;
  List<String> _choices;
  int _noOfQuestionsFilled = 0;
  FlutterSoundPlayer _audioPlayer;
  FlutterSoundRecorder _audioRecorder;

  void init() async {
    _audioPlayer = await FlutterSoundPlayer().openAudioSession();
    _audioRecorder = await FlutterSoundRecorder().openAudioSession();
  }

  @override
  void initState() {
    super.initState();
    _choices = List<String>.filled(widget.length, '', growable: true);
    init();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.closeAudioSession().then((v) async {
      await _audioRecorder.closeAudioSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '第 ${_questionNumber + 1}/${widget.length} 題',
            style: TextStyle(fontSize: 22.0),
          ),
          leading: _backButton(),
        ),
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                    _playSystemAudioButton(),
                    _question(),
                    _userAudio(),
                  ] +
                  _choiceButtons() +
                  [
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _prevQuestionButton(),
                          _submitButton(),
                          _nextQuestionButton(),
                        ],
                      ),
                    ),
                    _image(),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                '確認退出？',
                style: Theme.of(context).textTheme.headline1,
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  child: Text('退出'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('取消'),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _playSystemAudioButton() {
    return widget.type == QuizType.AUDIO
        ? Container()
        : Padding(
            padding: EdgeInsets.all(2.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                side: BorderSide(color: Colors.white, width: 1.0),
                minimumSize: Size(150.0, 25.0),
                primary: Colors.lightBlue,
              ),
              child: Text('播放聲音'),
              onPressed: () {
                _audioPlayer.openAudioSession().then((player) async {
                  await player.startPlayer(
                      fromURI:
                          'assets/audios/${widget.audios[_questionNumber]}.mp3');
                });
              },
            ),
          );
  }

  Widget _question() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
        widget.questions[_questionNumber],
        style: Theme.of(context).textTheme.headline4,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _userAudio() {
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
        if (timer != null) {
          timer.cancel();
          timer = null;
          counter = 0;
          controller.close();
        }
      }

      void startTimer() {
        timer = Timer.periodic(interval, tick);
      }

      controller =
          StreamController<int>(onListen: startTimer, onCancel: stopTimer);

      return controller.stream;
    }

    Widget _audioTimer() {
      String minute = '${_timerSeconds ~/ 60}'.padLeft(2, '0'),
          seconds = '${_timerSeconds % 60}'.padLeft(2, '0');
      return Text('$minute:$seconds');
    }

    Future<String> _getPath() async {
      final tmpPath = await getTemporaryDirectory();
      final path = Directory('${tmpPath.path}/quiz_recordings');
      await path.create();
      return '${path.path}/${_questionNumber + 1}.aac';
    }

    Future<void> _stopPlayer() async {
      if (_timerSubscription != null) await _timerSubscription.cancel();
      _timerStream = null;

      if (_playerSubscription != null) await _playerSubscription.cancel();

      setState(() {
        _isUsingAudioService = false;
      });
      await _audioRecorder.stopRecorder();
      await _audioPlayer.stopPlayer();
    }

    Widget _playUserAudioButton() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(200.0, 50.0),
            primary:
                _isUsingAudioService || !_recorded ? Colors.grey : Colors.blue,
          ),
          child: Text("播放已錄製的答案"),
          onPressed: () async {
            if (!_isUsingAudioService && _recorded) {
              _timerStream = _stopwatchStream();
              _timerSubscription = _timerStream.listen((seconds) {
                setState(() {
                  _timerSeconds = seconds;
                });
              });
              setState(() {
                _timerSeconds = 0;
                _isUsingAudioService = true;
              });

              final file = File(await _getPath());
              await _audioPlayer.startPlayer(fromURI: file.uri.toString());
              await _audioPlayer
                  .setSubscriptionDuration(Duration(milliseconds: 50));
              _playerSubscription =
                  _audioPlayer.onProgress.listen((event) async {
                if (event.duration - event.position <=
                    Duration(milliseconds: 100)) await _stopPlayer();
              });
            }
          },
        ),
      );
    }

    Widget _recordUserAudioButton() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(150.0, 50.0),
            primary: _isUsingAudioService ? Colors.grey : Colors.blue,
          ),
          child: Text("錄製答案"),
          onPressed: () async {
            if (!_isUsingAudioService) {
              _timerStream = _stopwatchStream();
              _timerSubscription = _timerStream.listen((seconds) {
                setState(() {
                  _timerSeconds = seconds;
                });
              });
              setState(() {
                _recorded = true;
                _timerSeconds = 0;
                _isUsingAudioService = true;
              });
              final file = File(await _getPath());
              await _audioRecorder.startRecorder(toFile: file.path);
            }
          },
        ),
      );
    }

    Widget _stopUserAudioButton() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(50.0, 50.0),
            primary: _isUsingAudioService ? Colors.red : Colors.grey,
          ),
          child: Icon(Icons.stop, color: Colors.black),
          onPressed: () async {
            if (_isUsingAudioService) {
              await _stopPlayer();
            }
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _audioTimer(),
            _stopUserAudioButton(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _recordUserAudioButton(),
            _playUserAudioButton(),
          ],
        ),
      ],
    );
  }

  List<Widget> _choiceButtons() {
    return widget.type == QuizType.AUDIO
        ? []
        : widget.choices[_questionNumber]
            .map(
              (choice) => Padding(
                padding: EdgeInsets.zero,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: choice == _choices[_questionNumber]
                        ? Colors.purple
                        : Colors.lightBlue,
                    minimumSize: const Size(350.0, 35.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    side: BorderSide(color: Colors.white54, width: 3.0),
                  ),
                  onPressed: () async {
                    await _audioPlayer.closeAudioSession();
                    await _audioPlayer.stopPlayer();

                    if (_choices[_questionNumber] == '') {
                      setState(() {
                        _noOfQuestionsFilled++;
                      });
                    }
                    setState(() {
                      _choices[_questionNumber] = choice;
                    });
                  },
                  child: Text(
                    choice,
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ),
            )
            .toList(); // choices
  }

  Widget _prevQuestionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: _questionNumber == 0 ? Colors.blueGrey : Colors.lightBlue,
          shape: CircleBorder(),
          minimumSize: Size(50.0, 50.0)),
      child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 50),
      onPressed: () {
        if (_questionNumber > 0)
          setState(() {
            _questionNumber--;
          });
      },
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: _noOfQuestionsFilled == widget.length
            ? Colors.green
            : Colors.blueGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: Size(100.0, 50.0),
      ),
      child: Text('遞交'),
      onPressed: () {
        if (_noOfQuestionsFilled == widget.length) {
          int score = 0;
          for (int i = 0; i < widget.length; ++i) {
            if (_choices[i] == widget.correctAnswers[i]) {
              score++;
            }
          }
          Navigator.pushNamed(
            context,
            '/summary',
            arguments: UserResult(
              currentUserInfo.name,
              currentUserInfo.dateOfBirth,
              currentUserInfo.gender,
              score,
              widget.title,
              widget.length,
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  '請先完成所有題目',
                  style: Theme.of(context).textTheme.headline1,
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('好'),
                  )
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _nextQuestionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: _questionNumber == widget.length - 1
              ? Colors.blueGrey
              : Colors.lightBlue,
          shape: CircleBorder(),
          minimumSize: Size(50.0, 50.0)),
      child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 50),
      onPressed: () {
        if (_questionNumber + 1 < widget.length)
          setState(() {
            _questionNumber++;
          });
      },
    );
  }

  Widget _image() {
    return widget.images == null
        ? Container()
        : Padding(
            padding: EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/images/${widget.images[_questionNumber]}',
            ),
          );
  }
}
