import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

ThemeData lightMode= ThemeData(
  colorScheme: ColorScheme.light(
    // ignore: deprecated_member_use
    background: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    inversePrimary: Colors.grey.shade900,
  ),
  
);

AppTheme lightAppTheme() {
return AppTheme(id: 'light', data: lightMode, description: 'Custom Light Theme');
}