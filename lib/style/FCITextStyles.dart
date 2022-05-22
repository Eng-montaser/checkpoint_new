import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FCITextStyle {
  Color? color = Colors.black;
  FCITextStyle({this.color});
  String? getFontFamily() {
    /// get Font Family by language
    return GoogleFonts.changa().fontFamily;
  }

  ///--------------------------
  ///       Text style Normal -
  ///--------------------------
  TextStyle normal10() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(10));
  }

  TextStyle normal11() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(11));
  }

  TextStyle normal12() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(12));
  }

  TextStyle normal13() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(13));
  }

  TextStyle normal14() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(14));
  }

  TextStyle normal16() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(16));
  }

  TextStyle normal18() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(18));
  }

  TextStyle normal20() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(20));
  }

  TextStyle normal22() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(22));
  }

  TextStyle normal25() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(25));
  }

  TextStyle normal30() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.normal,
        fontSize: ScreenUtil().setSp(30));
  }

  ///--------------------------
  ///       Text style Bold -
  ///--------------------------
  TextStyle bold10() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(10));
  }

  TextStyle bold11() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(11));
  }

  TextStyle bold12() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(12));
  }

  TextStyle bold13() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(13));
  }

  TextStyle bold14() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(14));
  }

  TextStyle bold16() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(16));
  }

  TextStyle bold18() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(18));
  }

  TextStyle bold20() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(20));
  }

  TextStyle bold22() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(22));
  }

  TextStyle bold25() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(25));
  }

  TextStyle bold30() {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(30));
  }

  TextStyle bold(int size) {
    return TextStyle(
        color: color,
        fontFamily: getFontFamily(),
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil().setSp(size));
  }
}

class FCIColors {
  static Color taskText() => Color(0xff2f363e);
  static Color taskCheckBox() => Color(0xff6fb308);
  static Color taskBackGround() => Color(0xfff7f7f7);
  static Color timerText() => Color(0xff7e7e7e);
  static Color timerRequired() => Color(0xff00bde7);
  static Color timerRed() => Color(0xff6db201);
  static Color timerMissed() => Color(0xffbf0614);
  static Color background() => Color(0xff293e53);
}
