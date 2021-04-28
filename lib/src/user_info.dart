class UserInfo {
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String school;
  final String gradeLevel;

  UserInfo(
      {this.name,
      this.dateOfBirth,
      this.gender,
      this.school,
      this.gradeLevel});
}

UserInfo currentUserInfo;
