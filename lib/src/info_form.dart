import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'basic_quiz.dart';
import 'user_info.dart';

class InformationForm extends StatefulWidget {
  @override
  _InformationFormState createState() => _InformationFormState();
}

class _InformationFormState extends State<InformationForm> {
  String _userName = "";
  DateTime _userDateOfBirth = DateTime.now();
  String _userGender = "";

  bool _userNameWarning = false;
  bool _userDateOfBirthWarning = false;
  bool _userGenderWarning = false;

  bool _loadedJson = false;

  final _normalTextStyle = TextStyle(
    fontSize: 18.0,
  );

  final _warningTextStyle = TextStyle(
    fontSize: 20.0,
    color: Colors.red,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Basic information"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _nameField(),
          _dateOfBirthField(),
          _genderField(),
          _submitButton(),
          Padding(padding: EdgeInsets.all(18.0)),
          Text(
            _userNameWarning ? "PLEASE FILL IN YOUR NAME" : "",
            style: _warningTextStyle,
          ),
          Text(
            _userDateOfBirthWarning ? "PLEASE FILL IN YOUR DOB" : "",
            style: _warningTextStyle,
          ),
          Text(
            _userGenderWarning ? "PLEASE FILL IN YOUR GENDER" : "",
            style: _warningTextStyle,
          )
        ],
      ),
    );
  }

  Widget _nameField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        autofocus: false,
        onChanged: (name) {
          setState(() {
            _userName = name;
          });
        },
        decoration: InputDecoration(
          hintText: "Your Name",
          hintStyle: _normalTextStyle,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dateOfBirthField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
          side: BorderSide(color: Colors.white, width: 1.0),
          minimumSize: Size(double.infinity, 50.0),
          primary: Colors.transparent,
        ),
        child: Text(
          "Your date of birth: " + _toString(_userDateOfBirth),
          style: _normalTextStyle,
        ),
        onPressed: () async {
          final DateTime picked = await showDatePicker(
            context: context,
            initialDate: _userDateOfBirth,
            firstDate: DateTime(1960),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked != _userDateOfBirth)
            setState(() {
              _userDateOfBirth = picked;
            });
        },
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: DropdownButton(
        value: _userGender.isEmpty ? null : _userGender,
        hint: Text(
          "Your gender",
          style: _normalTextStyle,
        ),
        items: [
          DropdownMenuItem(value: "male", child: Text("Male")),
          DropdownMenuItem(value: "female", child: Text("Female")),
        ],
        onChanged: (value) {
          setState(() {
            _userGender = value;
          });
        },
      ),
    );
  }

  Widget _submitButton() {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.green,
      child: Text("Submit"),
      onPressed: () async {
        setState(() {
          _userNameWarning = _userName.isEmpty;
          _userDateOfBirthWarning =
              _toString(_userDateOfBirth) == _toString(DateTime.now());
          _userGenderWarning = _userGender.isEmpty;
        });
        if (!_userNameWarning &&
            !_userDateOfBirthWarning &&
            !_userGenderWarning) {
          // all information is correctly filed
          currentUserInfo = UserInfo(_userName, _userDateOfBirth, _userGender);

          if (!_loadedJson) {
            String json = await rootBundle.loadString('assets/data.json');
            List<dynamic> loaded = jsonDecode(json);
            loaded.forEach((data) {
              quizzes.add(Quiz.fromJson(data));
            });
            _loadedJson = true;
          }
          Navigator.pushNamed(context, '/');
        }
      },
    );
  }
}

String _toString(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}
