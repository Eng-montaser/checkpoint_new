// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// enum ThemeType { Dark, Light }
//
// class Setting extends ChangeNotifier {
//   Color _tempPrimaryMainColor = Color(0xffb68a35);
//   ColorSwatch? _tempAccentColor;
//   ColorSwatch? _tempScaffoldColor;
//   ColorSwatch? _tempTextColor;
//   ColorSwatch? _tempAppbarColor;
//   ColorSwatch? _tempDividerColor;
//   Color _scaffoldColor = Colors.grey;
//   Color? colorChoosenColor;
//   String? _colorChoosed;
//   static AppBarTheme? appBarTheme1;
//   ColorSwatch _accentColor = Colors.orange;
//   Color _textColor = Color(0xff1f316c);
//   Color? _currentColor;
//   Color _pickerColor = Colors.red;
//   Color? _primaryTempShadeColor;
//   Color? _accentTempShadeColor;
//   Color? _scaffoldTempShadeColor;
//   Color? _textTempShadeColor;
//   Color? _appbarTempShadeColor;
//   Color? _dividerTempShadeColor;
//   Color? _primaryShadeColor = Colors.cyan[800];
//   Color? _accentShadeColor = Colors.amber;
//   Color? _appbarShadeColor = Colors.cyan[500];
//   Color? _dividerShadeColor = Colors.grey[800];
//   Color? _textShadeColor = Colors.blue[800];
//   Color? _scaffoldShadeColor = Colors.blue[800];
//   ThemeType _themeType = ThemeType.Light;
//   double article_size = 12;
//   bool notification = true;
//
//   Color _primaryMainColor = Colors.red;
//   ColorSwatch _appbarColor = Colors.blue;
//   ColorSwatch _dividerColor = Colors.grey;
//
//   //getters
//   Color? get appbarTempShadeColor => _appbarTempShadeColor;
//   Color? get textTempShadeColor => _textTempShadeColor;
//   Color? get accentShadeColor => _accentShadeColor;
//   Color? get scaffoldTempShadeColor => _scaffoldTempShadeColor;
//   ColorSwatch get appbarcolor => _appbarColor;
//   Color? get scaffoldShadeColor => _scaffoldShadeColor;
//   Color? get accentTempShadeColor => _accentTempShadeColor;
//   ColorSwatch? get tempScaffoldColor => _tempScaffoldColor;
//   Color? get primaryTempShadeColor => _primaryTempShadeColor;
//   Color get tempPrimaryMainColor => _tempPrimaryMainColor;
//   Color? get primaryShadeColor => _primaryShadeColor;
//   ColorSwatch get accentColor => _accentColor;
//   Color get primaryMainColor => _primaryMainColor;
//   get pickerColor => _pickerColor;
//   get currentColor => _currentColor;
//   get colorChoosed => _colorChoosed;
//   ColorSwatch? get tempDividerColor => _tempDividerColor;
//   ColorSwatch? get tempAppbarColor => _tempAppbarColor;
//   Color get textColor => _textColor;
//   double get articleSize => article_size;
//   bool get _notification => notification;
//   ColorSwatch? get tempAccentColor => _tempAccentColor;
//   ColorSwatch? get dividerColor => _dividerColor;
//   ColorSwatch? get tempTextColor => _tempTextColor;
//   Color? get dividerShadeColor => _dividerShadeColor;
//   Color? get appbarShadeColor => _appbarShadeColor;
//   Color? get textShadeColor => _textShadeColor;
//   Color? get dividerTempShadeColor => _dividerTempShadeColor;
//
//   Locale _appLocale = Locale('en', 'US');
//   bool login = false;
//  // Locale get appLocal => _appLocale ?? Locale('en', 'US');
//   /*fetchLocale() async {
//     var prefs = await SharedPreferences.getInstance();
//     if (prefs.getString('language_code') == null) {
//       _appLocale = Locale('en','US');
//       return Null;
//     }
//     _appLocale = Locale(prefs.getString('language_code'));
//     return Null;
//   }*/
//
//   fetchArticelSize() async {
//     SharedPreferences? prefs = await SharedPreferences.getInstance();
//     if (prefs.getDouble('font_size') == null) {
//       article_size = 14;
//       return Null;
//     }
//     article_size = prefs.getDouble('font_size')!;
//     return Null;
//   }
//
//   fetchnotify() async {
//     var prefs = await SharedPreferences.getInstance();
//     if (prefs.getDouble('notify') == null) {
//       notification = true;
//       return Null;
//     }
//     notification = prefs.getBool('notify')!;
//     return Null;
//   }
//
//   void changeLanguage(Locale type) async {
//     var prefs = await SharedPreferences.getInstance();
//     if (_appLocale == type) {
//       return;
//     }
//     _appLocale = type;
//
//     await prefs.setString('language_code', type.languageCode);
//     //await prefs.setString('countryCode', type!.countryCode!);
//
//     notifyListeners();
//   }
//
//   void changeArticle(double size) async {
//     var prefs = await SharedPreferences.getInstance();
//     if (article_size == size) {
//       return;
//     }
//
//     await prefs.setDouble('font_size', size);
//
//     notifyListeners();
//   }
//
//   void changeNotify(bool noti) async {
//     var prefs = await SharedPreferences.getInstance();
//     if (notification == noti) {
//       return;
//     }
//
//     await prefs.setBool('notify', noti);
//
//     notifyListeners();
//   }
//
//   void checkLogin() async {
//     var prefs = await SharedPreferences.getInstance();
//     var userId = await prefs.getString('access_token');
//     var theme = await prefs.getInt('theme');
//     var langs = await prefs.getString('language_code');
//     var code = await prefs.getString('countryCode');
//
//     var size = await prefs.getDouble('font_size');
//     var noti = await prefs.getBool('notify');
//     if (size != null) {
//       article_size = size;
//     }
//     if (noti != null) {
//       notification = noti;
//     }
//     langs != null
//         ? _appLocale = Locale(langs, code)
//         : _appLocale = Locale('ar', 'SA');
//     theme != null ? _primaryMainColor = Color(theme) : null;
//
//     if (userId != null) {
//       login = true;
//     } else
//       login = false;
//     notifyListeners();
//   }
//
//   //setters
//
//   setDividerTempShadeColor(Color value) {
//     _dividerTempShadeColor = value;
//     notifyListeners();
//   }
//
//   setTextShadeColor(Color value) {
//     _textShadeColor = value;
//     notifyListeners();
//   }
//
//   setDividerShadeColor(Color value) {
//     _dividerShadeColor = value;
//     notifyListeners();
//   }
//
//   setAppbarShadeColor(Color value) {
//     _appbarShadeColor = value;
//     notifyListeners();
//   }
//
//   setAppbarTempShadeColor(Color value) {
//     _appbarTempShadeColor = value;
//     notifyListeners();
//   }
//
//   setTextTempShadeColor(Color value) {
//     _textTempShadeColor = value;
//     notifyListeners();
//   }
//
//   setDividerColor(ColorSwatch value) {
//     _dividerColor = value;
//     notifyListeners();
//   }
//
//   setTextColor(ColorSwatch value) {
//     _textColor = value;
//     notifyListeners();
//   }
//
//   setTempAccentColor(ColorSwatch value) {
//     _tempAccentColor = value;
//     notifyListeners();
//   }
//
//   setTempTextColor(ColorSwatch value) {
//     _tempTextColor = value;
//     notifyListeners();
//   }
//
//   setTempAppbarColor(ColorSwatch value) {
//     _tempAppbarColor = value;
//     notifyListeners();
//   }
//
//   setTempDividerColor(ColorSwatch value) {
//     _tempDividerColor = value;
//     notifyListeners();
//   }
//
//   setScaffoldShadeColor(Color value) {
//     _scaffoldShadeColor = value;
//     notifyListeners();
//   }
//
//   setTempScaffoldColor(ColorSwatch value) {
//     _tempScaffoldColor = value;
//     notifyListeners();
//   }
//
//   setAccentTempShadeColor(Color value) {
//     _accentTempShadeColor = value;
//     notifyListeners();
//   }
//
//   setTempShadeColor(Color value) {
//     _primaryTempShadeColor = value;
//     notifyListeners();
//   }
//
//   setPrimaryShadeColor(Color value) {
//     _primaryShadeColor = value;
//     notifyListeners();
//   }
//
//   setTempPrimaryMainColor(Color value) {
//     _tempPrimaryMainColor = value;
//     notifyListeners();
//   }
//
//   setAccentColor(ColorSwatch value) {
//     _accentColor = value;
//     notifyListeners();
//   }
//
//   setPrimaryMainColor(Color value) async {
//     _primaryMainColor = value;
//     var prefs = await SharedPreferences.getInstance();
//     prefs.setInt('theme', value.value);
//     notifyListeners();
//   }
//
//   set currentColor(value) {
//     _currentColor = value;
//     notifyListeners();
//   }
//
//   set colorChoosed(value) {
//     _colorChoosed = value;
//     notifyListeners();
//   }
//
//   set pickerColor(value) {
//     _pickerColor = value;
//     notifyListeners();
//   }
//
//   setScaffoldTempShadeColor(Color value) {
//     _scaffoldTempShadeColor = value;
//     notifyListeners();
//   }
//
//   setAccentShadeColor(Color value) {
//     _accentShadeColor = value;
//     notifyListeners();
//   }
//
//   setScaffoldColor(ColorSwatch value) {
//     _scaffoldColor = value;
//     notifyListeners();
//   }
//
//   setAppbarColor(ColorSwatch value) {
//     _appbarColor = value;
//     notifyListeners();
//   }
// }
