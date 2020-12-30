import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'audio_manager.dart';
import 'globals.dart';
import 'instructions.dart';
import 'user_info.dart';

class InformationForm extends StatefulWidget {
  @override
  _InformationFormState createState() => _InformationFormState();
}

class _InformationFormState extends State<InformationForm> {
  final DateTime _today = DateTime.now();

  String _name;
  String _schoolName;
  String _gradeLevel;
  DateTime _dateOfBirth = DateTime.now();
  String _gender;

  bool _nameWarning = false;
  bool _schoolNameWarning = false;
  bool _gradeLevelWarning = false;
  bool _dateOfBirthWarning = false;
  bool _genderWarning = false;

  final _audioManager = AudioManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _instructionTile(),
                Divider(color: Colors.white),
                Text('請填寫基本資料', style: Theme.of(context).textTheme.headline4),
                _nameField(),
                _schoolNameField(),
                _gradeLevelField(),
                _dateOfBirthField(),
                _genderField(),
                _submitButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _nameField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
        onChanged: (name) {
          setState(() {
            _name = name;
          });
        },
        decoration: InputDecoration(
          hintText: '姓名',
          hintStyle: Theme.of(context).textTheme.headline6,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _gradeLevelField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: DropdownButton(
        value: _gradeLevel,
        hint: Text('就讀年級', style: Theme.of(context).textTheme.headline6),
        items: [
          DropdownMenuItem(value: 's1', child: Text('中一')),
          DropdownMenuItem(value: 's2', child: Text('中二')),
          DropdownMenuItem(value: 's3', child: Text('中三')),
          DropdownMenuItem(value: 's4', child: Text('中四')),
          DropdownMenuItem(value: 's5', child: Text('中五')),
          DropdownMenuItem(value: 's6', child: Text('中六')),
        ],
        onChanged: (value) {
          setState(() {
            _gradeLevel = value;
          });
        },
      ),
    );
  }

  Widget _schoolNameField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
        onChanged: (name) {
          setState(() {
            _schoolName = name;
          });
        },
        decoration: InputDecoration(
          hintText: '就讀學校',
          hintStyle: Theme.of(context).textTheme.headline6,
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
          minimumSize: Size(200.0, 60.0),
          primary: Colors.lightBlue,
        ),
        child: Text(
          '出生日期: ' +
              (globals.dateFormatter.format(_dateOfBirth) ==
                      globals.dateFormatter.format(_today)
                  ? '請選擇'
                  : globals.dateFormatter.format(_dateOfBirth)),
          style: Theme.of(context).textTheme.headline6,
        ),
        onPressed: () async {
          final DateTime picked = await showDatePicker(
            context: context,
            initialDate: _dateOfBirth,
            firstDate: DateTime(1960),
            lastDate: _today,
          );
          if (picked != null) {
            setState(() {
              _dateOfBirth = picked;
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
        value: _gender,
        hint: Text('性別', style: Theme.of(context).textTheme.headline6),
        items: [
          DropdownMenuItem(value: 'm', child: Text('男')),
          DropdownMenuItem(value: 'f', child: Text('女')),
        ],
        onChanged: (value) {
          setState(() {
            _gender = value;
          });
        },
      ),
    );
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          primary: Colors.green,
        ),
        child: Text('遞交', style: Theme.of(context).textTheme.headline4),
        onPressed: () async {
          setState(() {
            _nameWarning = _name == null;
            _dateOfBirthWarning = _dateOfBirth == _today;
            _genderWarning = _gender == null;
            _gradeLevelWarning = _gradeLevel == null;
            _schoolNameWarning = _schoolName == null;
          });
          if (!_nameWarning &&
              !_dateOfBirthWarning &&
              !_genderWarning &&
              !_gradeLevelWarning &&
              !_schoolNameWarning) {
            // all information is correctly filed
            currentUserInfo = UserInfo(
              name: _name,
              dateOfBirth: _dateOfBirth,
              gender: _gender,
              schoolName: _schoolName,
              gradeLevel: _gradeLevel,
            );
            _confirm();
          } else {
            _alert();
          }
        },
      ),
    );
  }

  Widget _instructionPage() {
    return InstructionPage(
      instruction: '請填上基本資料',
      audioAssetFilePath: 'assets/audios/instructions',
      audioFilename: 'info_form.mp3',
      audioManager: _audioManager,
    );
  }

  Widget _instructionTile() {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text('查看指示', style: Theme.of(context).textTheme.headline5),
      children: [_instructionPage()],
      maintainState: true,
    );
  }

  void _alert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            '${_nameWarning ? '請填寫姓名\n' : ''}'
            '${_dateOfBirthWarning ? '請填寫出生日期\n' : ''}'
            '${_genderWarning ? '請填寫性別\n' : ''}',
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
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
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
}
