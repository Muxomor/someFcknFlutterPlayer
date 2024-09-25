import 'package:chat_application_flutter/themes/dark.dart';
import 'package:chat_application_flutter/themes/light.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

//TODO: fix this bullshit
class CustomThemeProvider with ChangeNotifier{
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  bool get isLightMode => _themeData == lightMode;
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }
  void changeTheme(){
    if(_themeData==lightMode){
      themeData = darkMode;
    }else{
      themeData = lightMode;
    }
  }
}