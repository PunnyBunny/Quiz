import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'globals.dart' as globals;
import 'quiz.dart';
import 'user_info.dart';

class InformationForm extends StatefulWidget {
  @override
  _InformationFormState createState() => _InformationFormState();
}

class _InformationFormState extends State<InformationForm> {
  String _userName = '';
  DateTime _userDateOfBirth = DateTime.now();
  String _userGender = '';

  bool _userNameWarning = false;
  bool _userDateOfBirthWarning = false;
  bool _userGenderWarning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('請填寫基本資料'),
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
          hintText: '姓名',
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
        child: Text('出生日期: ' + globals.DATE_FORMATTER.format(_userDateOfBirth)),
        onPressed: () async {
          final DateTime picked = await showDatePicker(
            context: context,
            initialDate: _userDateOfBirth,
            firstDate: DateTime(1960),
            lastDate: DateTime.now(),
          );
          if (picked != null && picked != _userDateOfBirth) {
            setState(() {
              _userDateOfBirth = picked;
            });
          }
        },
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: DropdownButton(
        value: _userGender.isEmpty ? null : _userGender,
        hint: Text('性別'),
        items: [
          DropdownMenuItem(value: 'm', child: Text('男')),
          DropdownMenuItem(value: 'f', child: Text('女')),
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
        side: BorderSide(color: Colors.white, width: 1.0),
        primary: Colors.green,
      ),
      child: Text('遞交'),
      onPressed: () async {
        setState(() {
          _userNameWarning = _userName.isEmpty;
          _userDateOfBirthWarning =
              globals.DATE_FORMATTER.format(_userDateOfBirth) ==
                  globals.DATE_FORMATTER.format(DateTime.now());
          _userGenderWarning = _userGender.isEmpty;
        });
        if (!_userNameWarning &&
            !_userDateOfBirthWarning &&
            !_userGenderWarning) {
          // all information is correctly filed
          currentUserInfo = UserInfo(_userName, _userDateOfBirth, _userGender);
          _confirm();
        } else {
          _alert();
        }
      },
    );
  }

  void _alert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            '${_userNameWarning ? '請填寫姓名\n' : ''}'
            '${_userDateOfBirthWarning ? '請填寫出生日期\n' : ''}'
            '${_userGenderWarning ? '請填寫性別\n' : ''}',
            style: Theme.of(context).textTheme.headline1,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('好'),
            )
          ],
        );
      },
    );
  }

  void _confirm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            '確定?',
            style: Theme.of(context).textTheme.headline1,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _loadJson();
                Navigator.popAndPushNamed(context, '/');
              },
              child: Text('好'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('返回'),
            )
          ],
        );
      },
    );
  }

  Future<void> _loadJson() async {
    String json = await rootBundle.loadString('assets/data.json');
    List<dynamic> loaded = jsonDecode(json);
    loaded.forEach((data) {
      quizzes.add(Quiz.fromJson(data));
    });
  }
}
