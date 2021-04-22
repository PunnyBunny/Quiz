import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/globals.dart';
import 'src/home_page.dart';
import 'src/info_form.dart';
import 'src/quiz.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/info_form': (context) => InformationForm(),
  '/': (context) => HomePage(),
};

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
            fontSize: 28.0,
            color: Colors.red,
          ),
          headline5: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(Size(0.0, 0.0)),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
            ),
          ),
        ),
        brightness: Brightness.dark,
      ),
      initialRoute: '/info_form',
      routes: routes,
    );
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized(); // for using rootBundle
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]); // force portrait
    await SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom]); // hide status bar

    var statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();
    statuses.forEach((key, value) {
      assert(value.isGranted);
    });

    // load all audio assets into app document folder
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
    manifestMap.forEach((key, value) {
      if (key.contains('audios/') && key.contains('.mp3')) {
        int lastSlashPosition = key.lastIndexOf('/');
        globals.loadFromAssets(
          assetFilePath: key.substring(0, lastSlashPosition),
          filename: key.substring(lastSlashPosition + 1),
        );
      }
    });

    // load quiz data from json
    String json = await rootBundle.loadString('assets/data.json');
    List<dynamic> loaded = jsonDecode(json);
    loaded.forEach((data) {
      quizzes.add(Quiz.fromJson(data));
    });
    quizzes.forEach((quiz) {});
  }
}
