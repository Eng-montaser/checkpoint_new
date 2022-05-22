import 'dart:async';
import 'dart:io';

import 'package:checkpoint/model/MallData.dart';
import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/GetProvider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:checkpoint/widget/button_animated.dart';
import 'package:checkpoint/widget/rounded_input_field.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../Home.dart';

class SignUp extends StatefulWidget {
  final GlobalKey<ScaffoldState>? registerScaffoldKey;
  SignUp({this.registerScaffoldKey});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  AnimationController? _loginButtonController;
  bool _isButtonLoading = false;
  TextEditingController _usernameController =
      new TextEditingController(text: '');
  TextEditingController _emailController = new TextEditingController(text: '');
  TextEditingController _passwordController =
      new TextEditingController(text: '');
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  TextEditingController _cpasswordController =
      new TextEditingController(text: '');
  MallData? _mallData;
  List<MallData>? malls;
//  String mallName;
//  int mallId;
  int? _registerValidate;
  var focusNode = FocusNode();
  String device_id = '';
  @override
  void dispose() {
    _loginButtonController!.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initPlatformState();
      await Provider.of<GetProvider>(context, listen: false)
          .getMallData()
          .then((value) {
        if (value != null)
          value.forEach((element) {
            print(element.name);
          });
        setState(() {
          malls = value;
        });
      });
    });
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
    return SingleChildScrollView(
      child: Column(
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
            height: ScreenUtil().setHeight(16),
          ),
          CustomTextInput(
            hintText: 'name'.tr(),
            controller: _usernameController,
            focusNode: _registerValidate == 1 ? focusNode : null,
          ),
          CustomTextInput(
            hintText: 'email'.tr(),
            controller: _emailController,
            focusNode: _registerValidate == 2 || _registerValidate == 3
                ? focusNode
                : null,
          ),
          CustomTextInput(
            hintText: 'password'.tr(),
            obscure: true,
            controller: _passwordController,
            focusNode: _registerValidate == 4 ? focusNode : null,
          ),
          CustomTextInput(
            hintText: 'cpassword'.tr(),
            obscure: true,
            controller: _cpasswordController,
            focusNode: _registerValidate == 5 || _registerValidate == 6
                ? focusNode
                : null,
          ),
          InkWell(
            onTap: () async {
              print("Validation Value :$_registerValidate");
              modalBottomSheetMenu(
                  context: context,
                  data: malls,
                  vacationName: (name) {
                    setState(() {
                      _mallData!.name = name;
                    });
                  },
                  vacationId: (mall_id) {
                    setState(() {
                      _mallData!.mallId = mall_id;
                    });
                  });
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
                color: Colors.white,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                vertical: ScreenUtil().setHeight(10),
              ),
              width: MediaQuery.of(context).size.width * 0.7,
              height: ScreenUtil().setHeight(55),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    _mallData!.name != null
                        ? _mallData!.name
                        : "chooseBranch".tr(),
                    style: FCITextStyle(color: primaryColor).bold20(),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: ScreenUtil().setSp(24),
                    color: primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(20),
          ),
          StaggerAnimation(
            titleButton: 'signup'.tr(),
            foreground: Colors.white,
            context: context,
            background: primaryColor,
            buttonController: _loginButtonController!.view,
            onTap: () async {
              setState(() {
                _registerValidate = registerValidate();
              });
              if (_registerValidate == 0) {
                await _playAnimation();
                AuthenticationData authenticationData = new AuthenticationData(
                    email: _emailController.text,
                    password: _passwordController.text,
                    name: _usernameController.text,
                    deviceId: device_id,
                    mallID: _mallData!.mallId.toString());
                print(authenticationData.getSignUpBody());
                await Provider.of<AuthProvider>(context, listen: false)
                    .register(authenticationData)
                    .then((value) {
                  if (value.success) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Home()),
                        (Route<dynamic> route) => false);
                  } else
                    value.failMessage(context, value.message);
                });
              }
              await _stopAnimation();
            },
          ),
          SizedBox(
            height: ScreenUtil().setHeight(24),
          ),
        ],
      ),
    );
  }

  int registerValidate() {
    if (_usernameController.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateEmpty".tr());
      return 1;
    }
    if (_emailController.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateEmpty".tr());
      return 2;
    }
    if (emailIsValid(_emailController.text)) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateValidEmail".tr());
      return 3;
    }
    if (_passwordController.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateEmpty".tr());
      return 4;
    }
    if (_cpasswordController.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidateEmpty".tr());
      return 5;
    }
    if (_passwordController.text != _cpasswordController.text) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("regValidatePassMatch".tr());
      return 6;
    }
    if (_mallData!.mallId == null) {
      _showScaffold("regValidateMall".tr());
      return 7;
    }
    return 0;
  }

  void _showScaffold(String message) {
    widget.registerScaffoldKey!.currentState!.showSnackBar(SnackBar(
      backgroundColor: Colors.grey,
      duration: Duration(milliseconds: 3000),
      content: Text(message,
          textAlign: TextAlign.center, style: FCITextStyle().normal16()),
    ));
  }
}
