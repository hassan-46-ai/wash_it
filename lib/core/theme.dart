import 'package:flutter/material.dart';

const kPrimary = Color(0xFF0063CF);
const kDeep = Color(0xFF002D63);
const kAccent = Color(0xFF45D4FF);
const kGold = Color(0xFFFFC83D);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.dark),
      scaffoldBackgroundColor: Colors.transparent,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: kDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
