import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class UserData {
  String? token;
  bool? isLogin;
  bool? is_updated;
  String? email;

  String? name;
  String? phone;
  String? image;
  String? pin_code;
  String? designation;
  String? device_id;

  int? role_id;
  int? id;
  String? shift_hours;
  String? shift_start;
  String? shift_end;

  String? tall;
  String? weight;
  String? nationality;
  UserData(
      {this.token,
      this.is_updated,
      this.name,
      this.email,
      this.phone,
      this.role_id,
      this.image,
      this.designation,
      this.device_id,
      this.nationality,
      this.pin_code,
      this.tall,
      this.shift_hours,
      this.shift_start,
      this.shift_end,
      this.id,
      this.weight});
  UserData.fromLoginJson(Map<String, dynamic> json) {
    token = json['token'];
    if (json['user'] != null) {
      is_updated = json['user']['is_updated'] == 1 ? true : false;
      name = json['user']['name'];
      email = json['user']['email'];
      phone = json['user']['phone'];
      role_id = json['user']['role_id'];
      image = json['user']['image'];
      designation = json['user']['designation'];
      device_id = json['user']['device_id'];
      nationality = json['user']['nationality'];
      pin_code = json['user']['pin_code'].toString();
      tall = json['user']['tall'];
      weight = json['user']['weight'];
      shift_hours = '${json['user']['shift_hours']}';
      shift_start = json['user']['shift_start'];
      shift_end = json['user']['shift_end'];
      id = int.parse('${json['user']['id']}');
//      image = "http://check-points.fsdmarketing.com/img/logo.jpg";
      //json['user']['image'];
    }
  }
  factory UserData.fromSearchJson(Map<String, dynamic> json) => UserData(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      id: int.parse('${json['id']}'),
      pin_code: '${json['pin_code']}',
      shift_hours: '${json['shift_hours']}',
      shift_start: json['shift_start'],
      shift_end: json['shift_end'],
      image: json['image'] != null ? json['image'] : null
      //json['user']['image'];
      );
  updateUserData(Map<String, dynamic> json) {
    is_updated = json['is_updated'] == 0 ? true : false;
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    role_id = json['role_id'];
    image = json['image'];
    designation = json['designation'];
    device_id = json['device_id'];
    nationality = json['nationality'];
    pin_code = json['pin_code'];
    tall = json['tall'];
    weight = json['weight'];
  }

  printUserData() {
    print("login");
    return "token $token\n"
        "is_updated$is_updated\n"
        "email$email\n"
        "name$name\n"
        "phone$phone\n"
        "image$image\n"
        "pin_code$pin_code\n"
        "designation$designation\n"
        "device_id$device_id\n"
        "role_id$role_id\n"
        "tall$tall\n"
        "weight$weight\n"
        "nationality$nationality\n";
  }
}

/// Sign up
class AuthenticationData {
  String? name;
  String? email;
  String? phone;
  String? password;
  String? mallID;
  String? deviceId;
  String? pin_code;
  String? designation;
  String? device_id;
  String? tall;
  String? weight;
  String? nationality;

  AuthenticationData(
      {this.email,
      this.name,
      this.password,
      this.phone,
      this.mallID,
      this.deviceId,
      this.weight,
      this.tall,
      this.pin_code,
      this.nationality,
      this.device_id,
      this.designation});
  getSignUpBody() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "mall_id": mallID,
      "device_id": deviceId
    };
  }

  getLoginBody() {
    return {"email": email, "password": password, "device_id": deviceId};
  }

  getUpdateBody() {
    return {
      "name": name,
      "phone": phone,
      "designation": designation,
      "pin_code": pin_code,
      "weight": weight,
      "tall": tall,
      "nationality": nationality,
    };
  }
}

class AuthenticationResult {
  bool success;
  String? message;
  UserData? data;
  AuthenticationResult({required this.success, this.message, this.data});
  successMessage(context) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        title: "loginTitle".tr(),
        desc: "loginDescSuccess".tr(),
        btnOkText: "ok".tr(),
        btnOkColor: Colors.red,
        btnOkOnPress: () {},
        onDissmissCallback: (type) {})
      ..show();
  }

  failMessage(context, mess) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.ERROR,
        dismissOnBackKeyPress: true,
        dismissOnTouchOutside: true,
        title: "loginTitle".tr(),
        desc: mess,
        btnOkText: "ok".tr(),
        btnOkColor: Colors.red,
        btnOkOnPress: () {},
        onDissmissCallback: (type) {})
      ..show();
  }

  successUpdateMessage(context) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        title: "edittitle".tr(),
        desc: "editDescSuccess".tr(),
        btnOkText: "ok".tr(),
        btnOkColor: Colors.green,
        btnOkOnPress: () {},
        onDissmissCallback: (type) {})
      ..show();
  }

  failUpdateMessage(context) {
    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.ERROR,
        dismissOnBackKeyPress: true,
        dismissOnTouchOutside: true,
        title: "edittitle".tr(),
        desc: "editDescFail".tr(),
        btnOkText: "ok".tr(),
        btnOkColor: Colors.green,
        btnOkOnPress: () {},
        onDissmissCallback: (type) {})
      ..show();
  }
}
