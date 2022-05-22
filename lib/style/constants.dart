import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:checkpoint/model/SosData.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///***************************************
///    Ahmed Ashour Constant             *
///***************************************
const String BaseUrl = 'http://hrms.fsdmarketing.com/api/v1/';

//String Culture = 'en';
const String MAPAPIKEY = 'AIzaSyCdVIteMWFxbV6WMKh-8FopoExTanQCCIg';
const String kLogo = "assets/images/logo_white.png";
const String kLogoBlack = "assets/images/logo_black.png";
/*const primaryColor = Color(0xff102030);
const accentColor = Color(0xff1a1b1d);
const lightColor = Color(0xffcccecd);*/
const primaryColor = Color(0xffffa11a);
const accentColor = Color(0xff77838f);
const buttonStart = Color(0xff00d165);
const buttonEnd = Color(0xff293e52);
const buttonScan = Color(0xff0080bd);
const buttonSOS = Color(0xff7b8d8d);
const buttonIncident = Color(0xffe53e3e);
const buttonFlash = Color(0xffbdc3c7);
const buttonAdd = Color(0xffb7c0ff);

/// Colors   ----------------------------------------
hexColor(String _colorHexCode) {
  String colornew = '0xff' + _colorHexCode;
  colornew = colornew.replaceAll('#', '');
  int colorInt = int.parse(colornew);
  return colorInt;
}

Color PrimaryColor = Color(0xff102030);
Color AccentColor = Color(0xff1a1b1d);

Widget loading() {
  return Center(
    child: Image.asset(
      'assets/images/loading.gif',
      width: ScreenUtil().setWidth(100),
      height: ScreenUtil().setHeight(100),
      fit: BoxFit.fill,
    ),
  );
}

Widget loadingTow(width) {
  return Center(
    child: Image.asset(
      'assets/images/loading.gif',
      width: ScreenUtil().setWidth(width),
      height: ScreenUtil().setWidth(width),
      fit: BoxFit.fill,
    ),
  );
}

final List<Action_Messages> emergency_texts = [
  Action_Messages(id: 1, message: "Fire"),
  Action_Messages(id: 2, message: "Suspicious /unattended bag"),
  Action_Messages(id: 3, message: "Major Medical case"),
  Action_Messages(id: 4, message: "System failure"),
  Action_Messages(id: 5, message: "Cctv Failure"),
  Action_Messages(id: 6, message: "FM 200 alarm activation"),
  Action_Messages(id: 7, message: "Power shutdown"),
  Action_Messages(id: 8, message: "Elevator entrapment"),
  Action_Messages(id: 9, message: "Heavy water leakage"),
  Action_Messages(id: 10, message: "Environmental disaster /weather change"),
  Action_Messages(id: 11, message: "Major vehicle accident"),
];
String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  return htmlText
      .replaceAll(exp, '\n')
      .replaceAll('\n\n', '\n')
      .replaceAll('\n\n', '\n');
}

showMessage(
  context,
  String title,
  String desc,
  bool success,
) {
  AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      headerAnimationLoop: false,
      dialogType: success ? DialogType.SUCCES : DialogType.ERROR,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      title: title,
      desc: desc,
      btnOkText: "ok".tr(),
      btnOkColor: success ? Color(0xff00d164) : Colors.red,
      btnOkOnPress: () {},
      onDissmissCallback: (type) {})
    ..show();
}

showOfflineMessage(
  context,
  String title,
  String desc,
) {
  AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      headerAnimationLoop: false,
      dialogType: DialogType.INFO,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      title: title,
      desc: desc,
      btnOkText: "ok".tr(),
      btnOkColor: Color(0xff00d164),
      btnOkOnPress: () {},
      onDissmissCallback: (type) {})
    ..show();
}

disclosureMessage(
  context,
) {
  AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      headerAnimationLoop: false,
      dialogType: DialogType.INFO,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      title: 'Location Disclosure',
      desc:
          'Checkpoint app collects location data to enable work tracking even when the app is closed or not in use ,'
          'these data sent to admin when you send SOS or make barcode scan point',
      btnOkText: "ok".tr(),
      btnOkColor: Color(0xff00d164),
      btnOkOnPress: () {},
      onDissmissCallback: (type) {})
    ..show();
}

enum AuthType { login, signUp }
enum connection_type { wifi, mobile, none }

bool emailIsValid(String email) {
  return !RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}
