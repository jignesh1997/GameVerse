
import 'package:flutter/material.dart';
import 'package:game_verse/pages/dashboard_page.dart';


void main() {
  runApp(GameVerseApp());
}

class GameVerseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameVerse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: DashboardPage(),
    );
  }
}