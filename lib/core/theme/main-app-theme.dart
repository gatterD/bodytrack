import 'package:flutter/material.dart';

final main_theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
  ),
);
