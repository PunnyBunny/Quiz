import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

class Globals {
  static const SERVER_URI = 'http://testquiz.hopto.org:5000';
  static final dateFormatter = DateFormat('dd-MM-yyyy');
  static final soundPlayer = FlutterSoundPlayer();
  static final soundRecorder = FlutterSoundRecorder();

  static Future<Directory> userAudiosPath() async {
    final tmpPath = await getTemporaryDirectory();
    final path = Directory('${tmpPath.path}/quiz_recordings');
    await path.create();
    return path;
  }

  static Future<File> userAudioPath(int questionNumber) async {
    final res = File('${(await userAudiosPath()).path}/${questionNumber + 1}.aac');
    await res.create();
    return res;
  }
}
