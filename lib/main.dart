import 'package:flutter/material.dart';
import 'calculator.dart';
import 'app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatefulWidget {
  @override
  _MeuAppState createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  bool _isDarkMode = false;

 @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false; 
    });
  }
  
  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mocami',
      theme: _isDarkMode ? _darkTheme : _lightTheme,
      home: Calculator(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }

  static final ThemeData _lightTheme = ThemeData(
    primaryColor: AppColors.darkBackground,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightAppBar,
      foregroundColor: Colors.black,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary), 
      bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
        border:OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.lightBorderFocus, width: 2),
        ),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    primaryColor: AppColors.darkBackground,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkAppBar,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary), 
      bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBackground,
        border:OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.darkBorderFocus, width: 2),
        ),
    ),
  );
}
