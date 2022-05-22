import 'dart:convert';

import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/service/GetService.dart';
import 'package:checkpoint/service/PostService.dart';
import 'package:easy_localization/easy_localization.dart';

import 'CasheManger.dart';
import 'base_provider.dart';

class AuthProvider extends BaseProvider {
  GetService _getService = GetService();
  PostService _postService = PostService();

  ///Cat And Products -------------------------------------
  UserData _userData = new UserData();
  UserData get userData => _userData;
  Future<bool?> setUserDataFromCache() async {
    bool? result;
    await CacheManger().getData(CacheType.userData).then((value) {
      print(":::::::::::::::");
      print(value.email);
      if (value.token != null) {
        _userData = value;
        result = true;
      } else {
        result = false;
      }
    });
    return result;
  }

  Future<AuthenticationResult> register(
      AuthenticationData authenticationData) async {
    AuthenticationResult authenticationResult;
    print(authenticationData.getSignUpBody());
    setBusy(true);
    try {
      var response = await _postService.register(authenticationData);
      print('ttt ${response.body}');
      var data = jsonDecode(response.body);
      print("Register Body :$data");
      if (response.statusCode == 200) {
        _userData = UserData.fromLoginJson(data);
        authenticationResult = AuthenticationResult(
            success: true, message: 'Success', data: _userData);
        await CacheManger().saveData(CacheType.userData, _userData);
        notifyListeners();
        setBusy(false);
      } else {
        if (data["message"] != null) {
          authenticationResult = AuthenticationResult(
            success: false,
            message: "${data["message"]}\n ${data["errors"]}",
          );
        } else {
          authenticationResult = AuthenticationResult(
            success: false,
            message: "loginDescFail".tr(),
          );
        }
      }
    } catch (e) {
      print("Try Fail: $e");
      authenticationResult = AuthenticationResult(
        success: false,
        message: "loginDescFail".tr(),
      );
      setBusy(false);
    }
    setBusy(false);
    return authenticationResult;
  }

  Future<AuthenticationResult> login(
      AuthenticationData authenticationData) async {
    AuthenticationResult authenticationResult;
    setBusy(true);
//    try {
    var response = await _postService.login(authenticationData);
    Map<dynamic, dynamic> da = jsonDecode(response.body);
    for (dynamic key in da.keys) {
      if (key != "token") {
        print(key);
        print(da[key].toString());
      }
    }
    print(response.statusCode);
    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      _userData = UserData.fromLoginJson(data);
      authenticationResult = new AuthenticationResult(
          success: true, message: "loginDescSuccess".tr(), data: _userData);
      await CacheManger().saveData(CacheType.userData, _userData);
      notifyListeners();
      setBusy(false);
    } else {
      if (data["message"] != null) {
        authenticationResult = AuthenticationResult(
          success: false,
          message: "${data["message"]}\n ${data["errors"]}",
        );
      } else {
        authenticationResult = AuthenticationResult(
          success: false,
          message: "loginDescFail".tr(),
        );
      }
    }
//    } catch (e) {
//      print("Try Fail: $e");
//      authenticationResult = AuthenticationResult(
//        success: false,
//        message: "loginDescFail".tr(),
//      );
//      setBusy(false);
//    }
    setBusy(false);
    return authenticationResult;
  }
//  Future<AuthenticationResult> login(
//      AuthenticationData authenticationData) async {
//    AuthenticationResult authenticationResult;
//    setBusy(true);
//    try {
//      var response = await _postService.login(authenticationData);
//
//      print(response.body);
//      var data = jsonDecode(response.body);
//
//      if (response.statusCode == 200) {
//        //  print(data['user']);
//        _userData = UserData.fromLoginJson(data);
//        authenticationResult = new AuthenticationResult(
//            success: true, message: "loginDescSuccess".tr(), data: _userData);
//        await CacheManger().saveData(CacheType.userData, _userData);
//        notifyListeners();
//        setBusy(false);
//      } else {
//        if (data["message"] != null) {
//          authenticationResult = AuthenticationResult(
//            success: false,
//            message: "${data["message"]}\n ${data["errors"]}",
//          );
//        } else {
//          authenticationResult = AuthenticationResult(
//            success: false,
//            message: "loginDescFail".tr(),
//          );
//        }
//      }
//    } catch (e) {
//      print("Try Fail: $e");
//      authenticationResult = AuthenticationResult(
//        success: false,
//        message: "loginDescFail".tr(),
//      );
//      setBusy(false);
//    }
//    setBusy(false);
//    return authenticationResult;
//  }

  Future<AuthenticationResult?> logout() async {
    AuthenticationResult? authenticationResult;
    setBusy(true);
    try {
      var response = await _postService.logout();
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print(response.body.toString());
      if (response.statusCode == 200) {
        authenticationResult =
            new AuthenticationResult(success: true, message: 'Success');
        CacheManger().removeData(CacheType.userData);
        notifyListeners();
        setBusy(false);
      } else {
        CacheManger().removeData(CacheType.userData);
        authenticationResult = AuthenticationResult(
          success: false,
          message: 'Fail',
        );
      }
    } catch (e) {
      setBusy(false);
    }
    setBusy(false);
    return authenticationResult;
  }

  Future<UserData?> getUserData() async {
    UserData? _userData;
    setBusy(true);
    try {
      var response = await _getService.getUserData();
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print("|||||||||");
      print(data);
      if (response.statusCode == 200) {
        _userData = UserData.fromLoginJson(data);
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      print(e);
      setBusy(false);
    }
    setBusy(false);
    return _userData;
  }

//  Future<AuthenticationResult> updateUserData(file, authenticationData) async {
//    AuthenticationResult authenticationResult;
//    setBusy(true);
//    try {
//      var response =
//          await _postService.updateUserData(file, authenticationData);
//      var data = jsonDecode(response.body);
//      print(response.statusCode);
//      print("|||||||||");
//      print(data);
//      if (response.statusCode == 200) {
//        _userData.updateUserData(data);
//        authenticationResult = new AuthenticationResult(
//            success: true, message: 'Success', data: _userData);
//        CacheManger().saveData(CacheType.userData, _userData);
//        notifyListeners();
//        setBusy(false);
//      } else {
//        authenticationResult = AuthenticationResult(
//          success: false,
//          message: 'Fail',
//        );
//      }
//    } catch (e) {
//      print(e);
//      setBusy(false);
//    }
//    setBusy(false);
//    return authenticationResult;
//  }
  Future<AuthenticationResult> updateUserData(
      file, AuthenticationData authenticationData) async {
    AuthenticationResult authenticationResult;
    setBusy(true);
//    try {
    print(authenticationData.getUpdateBody());
    var response = await _postService.updateUserData(file, authenticationData);
    var data = jsonDecode(response.body);
    print(response.statusCode);
    print("|||||||||");
    print(data);
    if (response.statusCode == 200) {
      _userData.updateUserData(data);
      authenticationResult = new AuthenticationResult(
          success: true, message: 'Success', data: _userData);
      CacheManger().saveData(CacheType.userData, _userData);
      notifyListeners();
      setBusy(false);
    } else {
      authenticationResult = AuthenticationResult(
        success: false,
        message: 'Fail',
      );
    }
//    } catch (e) {
//      print(e);
//      setBusy(false);
//    }
    setBusy(false);
    return authenticationResult;
  }

  Future<void> setFcmToken(String token) async {
    _postService.setFcmToken(token);
  }
}
