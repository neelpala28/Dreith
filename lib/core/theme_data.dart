import 'package:flutter/material.dart';

final ThemeData dreithDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  cardColor: const Color(0xFF1A1A1A),
  primaryColor: const Color(0xFF6C63FF),
  hintColor: const Color(0xFF777777),

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFF3D3B8E),
    error: Color(0xFFFF4F4F),
    surface: Color(0xFF1A1A1A),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
    onSurface: Color(0xFFEDEDED),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D0D0D),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Color(0xFFEDEDED),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Color(0xFFEDEDED)),
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFEDEDED), fontSize: 16),
    bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
    bodySmall: TextStyle(color: Color(0xFF777777), fontSize: 12),
    titleLarge: TextStyle(
      color: Color(0xFFEDEDED),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6C63FF),
    foregroundColor: Colors.white,
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1A1A1A),
    hintStyle: TextStyle(color: Color(0xFF777777)),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);
