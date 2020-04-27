import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import 'main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: _buildTheme(),
        home: MainPage(),
      );

  ThemeData _buildTheme() =>
      ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue);
}

//////////////////////////////////////////
