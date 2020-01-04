import 'package:flutter/material.dart';

final fontColor = const Color(0xFFFFFFFF);
final fontSubColor = const Color(0xFF8E8F90);
final inputBackgroundColor = const Color(0x0FF141416);
final borderColor = const Color(0xFFFEFEFE);
final border = OutlineInputBorder(
  borderSide: BorderSide(color: borderColor, width: 2.0),
  borderRadius: const BorderRadius.all(Radius.circular(8)),
);

final ThemeData themeData = ThemeData(
  primaryColor: const Color(0xFFFFFFFF),
  accentColor: inputBackgroundColor,
  backgroundColor: const Color(0xFF202123),
  iconTheme: IconThemeData(color: fontColor),
  dividerColor: const Color(0xFFFEFEFE),
  indicatorColor: const Color(0xFF3E9BCD),
  errorColor: const Color(0xFFFF4C4C),
  textTheme: TextTheme(
    headline: TextStyle(
        fontSize: 34.0, fontWeight: FontWeight.bold, color: fontColor),
    title: TextStyle(fontSize: 24.0, color: fontColor),
    subhead: TextStyle(
      fontSize: 18.0,
      color: fontColor,
    ),
    body2: TextStyle(fontSize: 12.0, color: fontSubColor),
    body1: TextStyle(
        fontSize: 14.0, color: fontColor, fontWeight: FontWeight.bold),
    button: TextStyle(
        fontSize: 16.0, color: fontColor, fontWeight: FontWeight.bold),
  ),
  cursorColor: fontColor,
  textSelectionColor: fontColor.withOpacity(0.3),
  buttonColor: const Color(0xFFB8BEC3),
  buttonTheme: ButtonThemeData(
    height: 48,
    buttonColor: const Color(0xFFB8BEC3),
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 2.0),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    contentPadding: EdgeInsets.all(8.0),
    border: const OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    fillColor: inputBackgroundColor,
    hintStyle: TextStyle(color: const Color(0xFF3C3D3E)),
    labelStyle: TextStyle(
      color: fontColor,
    ),
  ),
);
