import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/audio_summary.dart';
import 'src/globals.dart';
import 'src/info_form.dart';
import 'src/instructions.dart';
import 'src/mc_summary.dart';
import 'src/quiz_home.dart';

void main() async {
  final app = MyApp();
  await app.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '測試',
      theme: ThemeData(
        textTheme: TextTheme(
          button: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
          bodyText2: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
          headline1: TextStyle(
            // use headline 1 for warnings
            fontSize: 24.0,
            color: Colors.red,
          ),
        ),
        brightness: Brightness.dark,
      ),
      initialRoute: '/info_form',
      routes: {
        '/info_form': (context) => InformationForm(),
        '/info_form/instructions': (context) => infoFormInstructions(context),
        '/': (context) => HomePage(),
        '/mc_summary': (context) => McSummaryPage(),
        '/audio_summary': (context) => AudioSummaryPage(),
      },
    );
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    var statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();
    statuses.forEach((key, value) {
      assert(value.isGranted);
    });

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    manifestMap.forEach((key, value) {
      if (key.contains('audios/') && key.contains('.mp3')) {
        int lastSlashPosition = key.lastIndexOf('/');
        globals.loadFromAssets(
          assetFilePath: key.substring(0, lastSlashPosition + 1),
          filename: key.substring(lastSlashPosition + 1),
        );
      }
    });
  }
}
