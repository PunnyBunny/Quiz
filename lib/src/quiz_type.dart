import 'package:json_annotation/json_annotation.dart';

enum QuizType {
  @JsonValue("audio")
  AUDIO,
  @JsonValue("mc")
  MULTIPLE_CHOICE,
}
