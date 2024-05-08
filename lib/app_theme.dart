import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme{
  static final ThemeData lightTheme = ThemeData(
      appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0C63EE),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Color(0xFF0C63EE)),
          shadowColor: Colors.black,
      )
  );
}