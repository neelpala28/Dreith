import 'package:flutter/material.dart';

final ThemeData dreithDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFF3D3B8E),
    surface: Color(0xFF1A1A1A),
    error: Color(0xFFFF4F4F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFFEDEDED),
    onError: Colors.white,
  ),
  cardColor: const Color(0xFF1A1A1A),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D0D0D),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFFEDEDED),
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: Color(0xFFEDEDED)),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color(0xFFEDEDED),
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: Color(0xFFEDEDED),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: Color(0xFFEDEDED),
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFFB0B0B0),
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: Color(0xFF777777),
      fontSize: 12,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFEDEDED),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6C63FF),
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1A1A1A),
    hintStyle: TextStyle(color: Color(0xFF777777)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFF6C63FF), width: 1.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  ),
  splashFactory: InkRipple.splashFactory,
);
