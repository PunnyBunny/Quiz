import 'package:flutter/cupertino.dart';

class UserResult {
  final String name;

  final DateTime dateOfBirth;

  final String gender;

  final String testName;
  final String school;

  final String gradeLevel;

  final int score;
  final int testLength;

  UserResult({
    @required this.name,
    @required this.dateOfBirth,
    @required this.gender,
    @required this.testName,
    @required this.school,
    @required this.gradeLevel,
    @required this.testLength,
    this.score,
  });
}
