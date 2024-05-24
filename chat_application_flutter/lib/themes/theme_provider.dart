import 'package:chat_application_flutter/themes/dark.dart';
import 'package:chat_application_flutter/themes/light.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  bool get isLightMode => _themeData == lightMode;

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