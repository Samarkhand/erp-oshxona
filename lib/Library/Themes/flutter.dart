import 'package:flutter/material.dart';

ThemeData get flutterTheme => 
  ThemeData(
      backgroundColor: const Color(0xFFEEEEEE),
      scaffoldBackgroundColor:  const Color(0xFFEEEEEE),
      cardColor: const Color.fromARGB(255, 252, 252, 252),
      primarySwatch: Colors.blue,
      appBarTheme:  const AppBarTheme(
        /*backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        foregroundColor: Colors.blue[600],*/
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(fontSize: 26),
        headline2: TextStyle(fontSize: 24),
        headline3: TextStyle(fontSize: 22),
        headline4: TextStyle(fontSize: 20),
        headline5: TextStyle(fontSize: 19),
        headline6: TextStyle(fontSize: 18),
      ),
    );