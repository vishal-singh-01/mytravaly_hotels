import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2E7DFF));
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: const CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)))),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
  );
}