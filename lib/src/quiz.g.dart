// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quiz _$QuizFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['title', 'type', 'questions', 'length']);
  return Quiz(
    json['title'] as String,
    _$enumDecodeNullable(_$QuizTypeEnumMap, json['type']),
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
      'type': _$QuizTypeEnumMap[instance.type],
      'questions': instance.questions,
      'length': instance.length,
      'correctAnswers': instance.correctAnswers,
      'audios': instance.audios,
      'images': instance.images,
      'choices': instance.choices,
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

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$QuizTypeEnumMap = {
  QuizType.AUDIO: 'audio',
  QuizType.MULTIPLE_CHOICE: 'mc',
};
