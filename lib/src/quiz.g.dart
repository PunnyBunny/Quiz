// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instruction _$InstructionFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['audio', 'text']);
  return Instruction(
    json['audio'] as String,
    json['text'] as String,
  );
}

Map<String, dynamic> _$InstructionToJson(Instruction instance) =>
    <String, dynamic>{
      'audio': instance.audio,
      'text': instance.text,
    };

Quiz _$QuizFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'title',
    'type',
    'length',
    'instructions',
    'goal',
    'audios',
    'questions'
  ]);
  return Quiz(
    json['title'] as String,
    _$enumDecode(_$QuizTypeEnumMap, json['type']),
    json['length'] as int,
    json['goal'] as String,
    (json['questions'] as List)?.map((e) => e as String)?.toList(),
    (json['audios'] as List).map((e) => e as String).toList(),
    (json['choices'] as List)
        ?.map((e) => (e as List)?.map((e) => e as String)?.toList())
        ?.toList(),
    (json['correctAnswers'] as List)?.map((e) => e as String)?.toList(),
    (json['images'] as List)?.map((e) => e as String)?.toList(),
    (json['instructions'] as List)
        ?.map((e) =>
            e == null ? null : Instruction.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$QuizToJson(Quiz instance) => <String, dynamic>{
      'title': instance.title,
      'type': _$QuizTypeEnumMap[instance.type],
      'length': instance.length,
      'instructions': instance.instructions,
      'goal': instance.goal,
      'audios': instance.audios,
      'questions': instance.questions,
      'choices': instance.choices,
      'correctAnswers': instance.correctAnswers,
      'images': instance.images,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

const _$QuizTypeEnumMap = {
  QuizType.AUDIO: 'audio',
  QuizType.MULTIPLE_CHOICE: 'mc',
};
