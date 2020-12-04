import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'basic_quiz.g.dart';

var quizzes = List<Quiz>();

@JsonSerializable()
class Quiz extends StatefulWidget {
  Quiz(this.title, this.length, this.choices, this.questions,
      this.correctAnswers, this.audios, this.images);

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  Map<String, dynamic> toJson() => _$QuizToJson(this);
  final String title;
  final List<String> questions, correctAnswers, audios, images;
  final List<List<String>> choices;
  final int length;

  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  int _questionNumber = 0;
  List<String> _choices;
  final _assetsAudioPlayer = AssetsAudioPlayer();
  var _noOfQuestionsFilled = 0;

  @override
  void initState() {
    super.initState();
    _choices = List<String>.filled(widget.length, "", growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Question ${_questionNumber + 1} of ${widget.length}",
                  style: TextStyle(fontSize: 22.0),
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', ModalRoute.withName('/info_form'));
            },
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(10.0),
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              // image
              widget.images == null
                  ? Container()
                  : Column(children: [
                Padding(padding: EdgeInsets.all(1.0)),
                Image.asset(
                  "assets/images/${widget.images[_questionNumber]}.jpg",
                ),
              ]),

              // audio
              widget.audios == null
                  ? Container()
                  : Column(
                children: [
                  Padding(padding: EdgeInsets.all(6.0)),
                  MaterialButton(
                    minWidth: 150.0,
                    height: 25.0,
                    color: Colors.blueGrey,
                    child: Text("Play Sound"),
                    onPressed: () {
                      _assetsAudioPlayer.open(
                        Audio(
                          "assets/audios/${widget.audios[_questionNumber]}.mp3",
                        ),
                      );
                    },
                  ),
                ],
              ),

              // question
              Padding(padding: EdgeInsets.all(2.0)),

              Text(
                widget.questions[_questionNumber],
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),

              Padding(padding: EdgeInsets.all(6.0)),
            ] +
                _choiceButtons() +
                [
                  // // quit button
                  // Padding(padding: EdgeInsets.all(6.0)),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     minimumSize: Size(150.0, 50.0),
                  //     primary: Colors.red,
                  //   ),
                  //   onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  //       context, '/', ModalRoute.withName('/info_form')),
                  //   child: Text(
                  //     "Quit",
                  //     style: TextStyle(fontSize: 18.0, color: Colors.white),
                  //   ),
                  // ),

                  Padding(padding: EdgeInsets.all(10.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: _questionNumber == 0
                                ? Colors.blueGrey
                                : Colors.lightBlue,
                            shape: CircleBorder(),
                            minimumSize: Size(50.0, 50.0)),
                        child: Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 50),
                        onPressed: _prevQuestion,
                      ),
                      _submitButton(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: _questionNumber == widget.length - 1
                                ? Colors.blueGrey
                                : Colors.lightBlue,
                            shape: CircleBorder(),
                            minimumSize: Size(50.0, 50.0)),
                        child: Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 50),
                        onPressed: _nextQuestion,
                      ),
                    ],
                  )
                ],
          ),
        ),
      ),
    );
  }

  List<Widget> _choiceButtons() {
    return widget.choices[_questionNumber]
        .map((choice) =>
        ElevatedButton(
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
          onPressed: () {
            _assetsAudioPlayer.stop();
            if (_choices[_questionNumber] == "") {
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
        ))
        .toList(); // choices
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
      child: Text("Submit"),
      onPressed: () {
        if (_noOfQuestionsFilled == widget.length) {
          int score = 0;
          for (int i = 0; i < widget.length; ++i) {
            if (_choices[i] == widget.correctAnswers[i]) {
              score++;
            }
          }
          Navigator.pushNamed(context, '/summary', arguments: score);
        }
      },
    );
  }

  void _nextQuestion() {
    if (_questionNumber + 1 < widget.length)
      setState(() {
        _questionNumber++;
      });
  }

  void _prevQuestion() {
    if (_questionNumber > 0)
      setState(() {
        _questionNumber--;
      });
  }
}
