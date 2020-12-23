import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'sound_manager.dart';

class Globals {
  Globals() {
    soundManager.init();
  }

  final serverUri = 'http://testquiz.hopto.org:5000';
  final dateFormatter = DateFormat('dd-MM-yyyy');
  final soundManager = SoundManager();

  Future<Directory> userAudiosPath() async {
    final tmpPath = await getTemporaryDirectory();
    final path = Directory('${tmpPath.path}/quiz_recordings');
    await path.create();
    return path;
  }

  Future<File> userAudioPath(int questionNumber) async {
    final res =
        File('${(await userAudiosPath()).path}/${questionNumber + 1}.aac');
    await res.create();
    return res;
  }

  Future<Directory> localPath() async {
    return await getApplicationDocumentsDirectory();
  }

  // create a file in app's document folder for access to assets as file object
  Future<File> loadFromAssets(
      {BuildContext context, String assetFilePath, String filename}) async {
    final path = await localPath();
    final file = File(path.path + assetFilePath + filename);
    if (!await file.exists()) {
      await file.create(recursive: true);
      final data = context == null
          ? await rootBundle.load(assetFilePath + filename)
          : await DefaultAssetBundle.of(context).load(assetFilePath + filename);
      file.writeAsBytes(data.buffer.asInt8List());
    }
    return file;
  }
}

final globals = Globals();
