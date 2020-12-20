import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

const SERVER_URI = 'http://testquiz.hopto.org:5000';
final dateFormatter = DateFormat('dd-MM-yyyy');

Future<Directory> userAudiosPath() async {
  final tmpPath = await getTemporaryDirectory();
  final path = Directory('${tmpPath.path}/quiz_recordings');
  await path.create();
  return path;
}

Future<File> userAudioPath(int questionNumber) async {
  final res = File('${(await userAudiosPath()).path}/${questionNumber + 1}.aac');
  await res.create();
  return res;
}
