class UserInfo {
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String schoolName;
  final String gradeLevel;

  UserInfo(
      {this.name,
      this.dateOfBirth,
      this.gender,
      this.schoolName,
      this.gradeLevel});
}

UserInfo currentUserInfo;
