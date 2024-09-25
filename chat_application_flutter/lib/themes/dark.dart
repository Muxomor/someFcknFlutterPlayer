import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

ThemeData darkMode= ThemeData(
  colorScheme: ColorScheme.dark(
    // ignore: deprecated_member_use
    background: Colors.grey.shade900,
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ),
  
);

AppTheme darkAppTheme() {
return AppTheme(id: 'dark', data: darkMode, description: 'Custom Dark Theme');
}