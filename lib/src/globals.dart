import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Globals {
  final serverUri = 'http://147.8.17.92:8080';
  final dateFormatter = DateFormat('dd-MM-yyyy');

  Future<Directory> get localPath async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final resDirectory = Directory('${documentsDirectory.path}/quiz');
    await resDirectory.create();
    return resDirectory;
  }

  Future<Directory> get userAudioDirectory async =>
      Directory('${(await localPath).path}/user_recordings');

  Future<File> userAudioPath(int questionNumber) async {
    final res =
        File('${(await userAudioDirectory).path}/${questionNumber + 1}.mp3');
    if (!await res.exists()) res.create(recursive: true);
    return res;
  }

  // create a file in app's document folder for access to assets as file object
  Future<File> loadFromAssets(
      {BuildContext context, String assetFilePath, String filename}) async {
    final path = await localPath;
    final file = File('${path.path}/$assetFilePath/$filename');
    if (!await file.exists()) {
      await file.create(recursive: true);
      final data = (context == null)
          ? await rootBundle.load('$assetFilePath/$filename')
          : await DefaultAssetBundle.of(context)
              .load('$assetFilePath/$filename');
      file.writeAsBytes(data.buffer.asInt8List());
    }
    return file;
  }
}

final globals = Globals();
