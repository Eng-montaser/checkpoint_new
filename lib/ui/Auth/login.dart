import 'dart:async';
import 'dart:io';

import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/CasheManger.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/ui/Auth/Profile/edit_profile.dart';
import 'package:checkpoint/ui/Home.dart';
import 'package:checkpoint/widget/button_animated.dart';
import 'package:checkpoint/widget/rounded_input_field.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../style/constants.dart';

class Login extends StatefulWidget {
  final GlobalKey<ScaffoldState>? loginScaffoldKey;
  Login({this.loginScaffoldKey});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  AnimationController? _loginButtonController;
  bool _isButtonLoading = false;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _emailController = new TextEditingController(text: '');
  TextEditingController _passwordController =
      new TextEditingController(text: '');
  int? _loginValidate;
  var focusNode = FocusNode();
  String device_id = '';
  @override
  void dispose() {
    _loginButtonController!.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    AuthProvider().dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  Future<void> initPlatformState() async {
    try {
      if (kIsWeb) {
        WebBrowserInfo webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
        setState(() {
          device_id = webBrowserInfo.vendor!;
        });
      } else {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidDeviceInfo =
              await deviceInfoPlugin.androidInfo;
          setState(() {
            device_id = androidDeviceInfo.androidId!;
          });
        } else if (Platform.isIOS) {
          IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
          setState(() {
            device_id = iosDeviceInfo.identifierForVendor!;
          });
        }
      }
    } on PlatformException {
      print('Failed to get platform version.');
    }

    if (!mounted) return;

    setState(() {
      //  _deviceData = deviceData;
    });
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        _isButtonLoading = true;
      });
      await _loginButtonController!.forward();
    } on TickerCanceled {}
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController!.reverse();
      setState(() {
        _isButtonLoading = false;
      });
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/location.png",
                fit: BoxFit.fill, width: ScreenUtil().setWidth(80)),
            SizedBox(
              width: ScreenUtil().setWidth(15),
            ),
            Text(
              "CHECK POINT",
              style: FCITextStyle(color: Colors.white).bold(40),
            ),
          ],
        ),
        SizedBox(
          height: ScreenUtil().setHeight(30),
        ),
        CustomTextInput(
          hintText: 'email'.tr(),
          controller: _emailController,
          focusNode:
              _loginValidate == 1 || _loginValidate == 2 ? focusNode : null,
        ),
        SizedBox(
          height: ScreenUtil().setHeight(20),
        ),
        CustomTextInput(
          hintText: 'password'.tr(),
          obscure: true,
          controller: _passwordController,
          focusNode: _loginValidate == 3 ? focusNode : null,
        ),
        SizedBox(
          height: 24,
        ),
        StaggerAnimation(
          titleButton: 'login'.tr(),
          context: context,
          foreground: Colors.white,
          background: primaryColor,
          buttonController: _loginButtonController!.view,
          onTap: () async {
            print('device Id: $device_id');
            setState(() {
              _loginValidate = loginValidate();
            });
            if (_loginValidate == 0) {
              await _playAnimation();
              AuthenticationData authenticationData = new AuthenticationData(
                  email: _emailController.text,
                  deviceId: device_id,
                  password: _passwordController.text);
              print(authenticationData.getLoginBody());
              await Provider.of<AuthProvider>(context, listen: false)
                  .login(authenticationData)
                  .then((value) async {
                print(value.success);
//                    print(value.data.printUserData());
                if (value.success) {
                  if (value.data!.is_updated!) {
                    await CacheManger().saveIsLogin(true);
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Home()),
                        (Route<dynamic> route) => false);
                  } else {
                    await CacheManger().saveIsLogin(false);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                  }
                } else
                  value.failMessage(context, value.message);
              });
            }
            await _stopAnimation();
          },
        ),
        SizedBox(
          height: ScreenUtil().setHeight(16),
        ),
      ],
    );
  }

  int loginValidate() {
    if (_emailController.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateEmpty".tr());
      return 1;
    }
    if (emailIsValid(_emailController.text)) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateValidEmail".tr());
      return 2;
    }
    if (_passwordController.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateEmpty".tr());
      return 3;
    }
    return 0;
  }

  void _showScaffold(String message) {
    widget.loginScaffoldKey!.currentState!.showSnackBar(SnackBar(
      backgroundColor: Colors.grey,
      duration: Duration(milliseconds: 3000),
      content: Text(message,
          textAlign: TextAlign.center, style: FCITextStyle().normal16()),
    ));
  }
}
