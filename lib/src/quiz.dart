import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'globals.dart';
import 'quiz_type.dart';
import 'user_info.dart';
import 'user_result.dart';

part 'quiz.g.dart';

var quizzes = List<Quiz>();

@JsonSerializable()
class Quiz extends StatefulWidget {
  Quiz(this.title, this.type, this.length, this.goal, this.questions,
      this.audios, this.choices, this.correctAnswers, this.images);

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  Map<String, dynamic> toJson() => _$QuizToJson(this);

  @JsonKey(required: true, nullable: false)
  final String title;

  @JsonKey(required: true, nullable: false)
  final QuizType type;

  @JsonKey(required: true, nullable: false)
  final int length;

  @JsonKey(required: true, nullable: false)
  final String goal;

  @JsonKey(required: true, nullable: false)
  final List<String> audios;

  @JsonKey(required: true)
  final List<String> questions;

  // properties that only exists in quizzes with type MC:
  final List<List<String>> choices;
  final List<String> correctAnswers;
  final List<String> images;

  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int _questionNumber = 0;
  List<String> _userInputs;
  int _noOfQuestionsFilled = 0;

  bool _isUsingAudioService = false;
  bool _isPausingAudioService = false;

  @override
  void initState() {
    super.initState();
    _userInputs = List<String>.filled(widget.length, '', growable: true);
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
                    _goal(),
                    _question(),
                    _userAudioSection(),
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

  Widget _goal() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        widget.goal + ':',
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _question() {
    if (widget.questions == null) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          child: Text(
            widget.questions[_questionNumber],
            style: TextStyle(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _userAudioSection() {
    Widget _timer() {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: globals.soundManager.timer(),
      );
    }

    Widget _playQuestionAudioButton() {
      return FutureBuilder(
          future: globals.loadFromAssets(
              assetFilePath: 'assets/audios',
              filename: '${widget.audios[_questionNumber]}'),
          builder: (context, snapshot) {
            bool disable = _isUsingAudioService;
            if (snapshot.hasData) {
              return globals.soundManager.playAudioButton(
                file: snapshot.data,
                style: ElevatedButton.styleFrom(
                  primary: disable ? Colors.blueGrey : Colors.blue,
                ),
                child: Text("播放問題"),
                onPressed: _getButtonStates,
                onStop: _getButtonStates,
                onTick: _updateTimer,
                disable: disable,
              );
            } else {
              return Container();
            }
          });
    }

    Widget _recordUserAudioButton() {
      return FutureBuilder(
          future: globals.userAudioPath(_questionNumber),
          builder: (context, snapshot) {
            if (widget.type == QuizType.AUDIO && snapshot.hasData) {
              bool disable = _isUsingAudioService;
              return globals.soundManager.recordAudioButton(
                file: snapshot.data,
                style: ElevatedButton.styleFrom(
                  primary: disable ? Colors.blueGrey : Colors.blue,
                ),
                child: Text("錄製答案"),
                onPressed: _getButtonStates,
                onStop: () {
                  _getButtonStates();
                  _userInputs[_questionNumber] = 'done';
                },
                onTick: _updateTimer,
                disable: disable,
              );
            } else {
              return Container();
            }
          });
    }

    Widget _playUserAudioButton() {
      return FutureBuilder(
          future: globals.userAudioPath(_questionNumber),
          builder: (context, snapshot) {
            if (widget.type == QuizType.AUDIO && snapshot.hasData) {
              bool disable =
                  _isUsingAudioService || _userInputs[_questionNumber].isEmpty;
              return globals.soundManager.playAudioButton(
                file: snapshot.data,
                style: ElevatedButton.styleFrom(
                  primary: disable ? Colors.blueGrey : Colors.blue,
                ),
                child: Text("播放已錄製的答案"),
                onPressed: _getButtonStates,
                onStop: _getButtonStates,
                onTick: _updateTimer,
                disable: disable,
              );
            } else {
              return Container();
            }
          });
    }

    Widget _stopAudioButton() {
      final disable = !_isUsingAudioService;
      return globals.soundManager.stopAudioButton(
        style: ElevatedButton.styleFrom(
          primary: disable ? Colors.blueGrey : Colors.red,
        ),
        child: Icon(Icons.stop),
        disable: disable,
        onPressed: _getButtonStates,
      );
    }

    Widget _pauseAudioButton() {
      final disable = (!_isUsingAudioService) || _isPausingAudioService;
      return globals.soundManager.pauseAudioServiceButton(
        style: ElevatedButton.styleFrom(
          primary: disable ? Colors.blueGrey : Colors.blue,
        ),
        child: Icon(Icons.pause),
        disable: disable,
        onPressed: _getButtonStates,
      );
    }

    Widget _resumeAudioButton() {
      final disable = (!_isUsingAudioService) || !_isPausingAudioService;
      return globals.soundManager.resumeAudioServiceButton(
        style: ElevatedButton.styleFrom(
          primary: disable ? Colors.blueGrey : Colors.blue,
        ),
        child: Icon(Icons.play_arrow),
        disable: disable,
        onPressed: _getButtonStates,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _playQuestionAudioButton(),
              _playUserAudioButton(),
              _recordUserAudioButton(),
            ],
          ),
          _timer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stopAudioButton(),
              _pauseAudioButton(),
              _resumeAudioButton(),
            ],
          ),
        ],
      ),
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
                    primary: choice == _userInputs[_questionNumber]
                        ? Colors.purple
                        : Colors.lightBlue,
                    minimumSize: const Size(350.0, 35.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    side: BorderSide(color: Colors.white54, width: 3.0),
                  ),
                  onPressed: () async {
                    await globals.soundManager.stopAudioService();

                    if (_userInputs[_questionNumber].isEmpty) {
                      setState(() {
                        _noOfQuestionsFilled++;
                      });
                    }
                    setState(() {
                      _userInputs[_questionNumber] = choice;
                    });
                  },
                  child: Text(choice),
                ),
              ),
            )
            .toList(); // choices
  }

  Widget _prevQuestionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: _questionNumber == 0 || _isUsingAudioService
              ? Colors.blueGrey
              : Colors.lightBlue,
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
        primary: _noOfQuestionsFilled == widget.length || _isUsingAudioService
            ? Colors.blueGrey
            : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: Size(100.0, 50.0),
      ),
      child: Text('遞交'),
      onPressed: () {
        if (_noOfQuestionsFilled == widget.length) {
          if (widget.type == QuizType.MULTIPLE_CHOICE) {
            int score = 0;
            for (int i = 0; i < widget.length; ++i) {
              if (_userInputs[i] == widget.correctAnswers[i]) {
                score++;
              }
            }
            Navigator.pushNamed(
              context,
              '/mc_summary',
              arguments: UserResult(
                name: currentUserInfo.name,
                dateOfBirth: currentUserInfo.dateOfBirth,
                gender: currentUserInfo.gender,
                testName: widget.title,
                score: score,
                testLength: widget.length,
              ),
            );
          } else {
            Navigator.pushNamed(
              context,
              '/audio_summary',
              arguments: UserResult(
                name: currentUserInfo.name,
                dateOfBirth: currentUserInfo.dateOfBirth,
                gender: currentUserInfo.gender,
                testName: widget.title,
              ),
            );
          }
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
          primary: _questionNumber == widget.length - 1 || _isUsingAudioService
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

  void _getButtonStates() {
    setState(() {
      _isUsingAudioService = globals.soundManager.isUsingAudioService;
      _isPausingAudioService = globals.soundManager.isPausingAudioService;
    });
  }

  void _updateTimer() {
    setState(() {});
  }
}
