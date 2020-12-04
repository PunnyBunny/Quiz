// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quiz _$QuizFromJson(Map<String, dynamic> json) {
  return Quiz(
    json['title'] as String,
    json['length'] as int,
    (json['choices'] as List)
        ?.map((e) => (e as List)?.map((e) => e as String)?.toList())
        ?.toList(),
    (json['questions'] as List)?.map((e) => e as String)?.toList(),
    (json['correctAnswers'] as List)?.map((e) => e as String)?.toList(),
    (json['audios'] as List)?.map((e) => e as String)?.toList(),
    (json['images'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$QuizToJson(Quiz instance) => <String, dynamic>{
      'title': instance.title,
      'questions': instance.questions,
      'correctAnswers': instance.correctAnswers,
      'audios': instance.audios,
      'images': instance.images,
      'choices': instance.choices,
      'length': instance.length,
    };
