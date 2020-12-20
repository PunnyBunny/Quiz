import 'package:flutter/cupertino.dart';

class UserResult {
  @required
  final String name;

  @required
  final DateTime dateOfBirth;

  @required
  final String gender;

  @required
  final String testName;

  final int score;
  final int testLength;

  UserResult(
      {this.name,
      this.dateOfBirth,
      this.gender,
      this.testName,
      this.score,
      this.testLength});
}
