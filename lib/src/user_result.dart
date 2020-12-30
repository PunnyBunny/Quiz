import 'package:flutter/cupertino.dart';

class UserResult {
  final String name;

  final DateTime dateOfBirth;

  final String gender;

  final String testName;
  final String schoolName;

  final String gradeLevel;

  final int score;
  final int testLength;

  UserResult({
    @required this.name,
    @required this.dateOfBirth,
    @required this.gender,
    @required this.testName,
    @required this.schoolName,
    @required this.gradeLevel,
    @required this.testLength,
    this.score,
  });
}
