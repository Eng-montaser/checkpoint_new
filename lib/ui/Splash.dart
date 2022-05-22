import 'dart:async';

import 'package:checkpoint/provider/CasheManger.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:checkpoint/ui/Auth/auth_page.dart';
import 'package:checkpoint/ui/Home.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_auth_invisible/auth_strings.dart';
import 'package:flutter_local_auth_invisible/flutter_local_auth_invisible.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class Splash extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<Splash> {
  //SharedPreferences pref;
  TextEditingController pincontroller = new TextEditingController(text: '');
  //final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Timer(Duration(seconds: 2), () async {
        init();

        //print('sup $_supportState');
      });
    });
  }

  Future<void> _checkBiometrics() async {
    bool? canCheckBiometrics;
    try {
      canCheckBiometrics = await LocalAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await LocalAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<bool> _authenticate() async {
    const androidStrings = const AndroidAuthMessages(
        cancelButton: 'cancel',
        goToSettingsButton: 'settings',
        /*biometricHint: 'biometricHint',
        signInTitle: 'signInTitle',*/
        goToSettingsDescription: 'Please set up your Touch ID.',
        biometricNotRecognized: "Fingerprint NotRecognized",
        biometricRequiredTitle: 'Please reenable your Touch ID');
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await LocalAuthentication.authenticate(
          localizedReason: 'Let OS determine authentication method',
          useErrorDialogs: true,
          androidAuthStrings: androidStrings,
          //maxTimeoutMillis: 10000,
          stickyAuth: true);
      print('hhh $authenticated');
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return authenticated;
    }
    if (!mounted) return false;

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
    return authenticated;
  }

  Future<bool?> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      print('herem');

      authenticated = await LocalAuthentication.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      print('herem $authenticated');

      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return authenticated;
    }
    if (!mounted) return null;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
    return authenticated;
  }

  void _cancelAuthentication() async {
    await LocalAuthentication.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  void _showScaffold(String message) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(
      backgroundColor: Colors.grey,
      duration: Duration(milliseconds: 3000),
      content: Text(message,
          textAlign: TextAlign.center, style: FCITextStyle().normal16()),
    ));
  }

  init() async {
    bool? isLogin;
    isLogin = await CacheManger().getIsLogin();
    if (isLogin != null && isLogin) {
      /* String pincode = await CacheManger().getPinCode();
      if (pincode == null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => AuthPage(
                      authType: AuthType.login,
                    )),
            (Route<dynamic> route) => false);
//        await CacheManger().savePinCode('1111');
//        Navigator.of(context).pushAndRemoveUntil(
//            MaterialPageRoute(builder: (context) => Home()),
//            (Route<dynamic> route) => false);
      } else {
        showAlert(pincode, context);
      }*/
      await LocalAuthentication.canCheckBiometrics.then((isSupported) async {
        setState(() {
          _supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported;
        });
        if (isSupported) {
          // _showScaffold("Scan your fingerprint to authenticate or Face");
          bool auth = await _authenticate();
          if (auth)
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Home()),
                (Route<dynamic> route) => false);
          else {
            showMessage(context, 'try login', 'You are not authorized', false);
          }
        } else {
          String? pincode = await CacheManger().getPinCode();
          if (pincode == null) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => AuthPage(
                          authType: AuthType.login,
                        )),
                (Route<dynamic> route) => false);
//        await CacheManger().savePinCode('1111');
//        Navigator.of(context).pushAndRemoveUntil(
//            MaterialPageRoute(builder: (context) => Home()),
//            (Route<dynamic> route) => false);
          } else {
            showAlert(pincode, context);
          }
        }
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => AuthPage(
                    authType: AuthType.login,
                  )),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      body: Background(
        show: false,
        child: Align(
          alignment: _supportState != _SupportState.supported
              ? Alignment.center
              : Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/logo2.png",
                  fit: BoxFit.contain,
                  height: ScreenUtil().setHeight(300),
                  width: ScreenUtil().setWidth(300)),
              if (_supportState == _SupportState.supported)
                Container(
                  //height: size.height * .5,
                  margin: EdgeInsets.only(
                      top: ScreenUtil().setHeight(50),
                      bottom: ScreenUtil().setHeight(30)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: ScreenUtil().setHeight(150),
                            width: ScreenUtil().setWidth(150),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                    image: AssetImage(
                                  "assets/images/finger.jpeg",
                                ))),
                          ),
                          Text(
                            'OR',
                            style: FCITextStyle(color: Colors.white).bold20(),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(150),
                            width: ScreenUtil().setWidth(150),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                    image: AssetImage(
                                  "assets/images/face.jpeg",
                                ))),
                          ),
                        ],
                      ),
                      // if (!_isAuthenticating)
                      Container(
                        alignment: Alignment.bottomCenter,
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(50)),
                        child: MaterialButton(
                          elevation: 5,
                          disabledTextColor: Colors.transparent,
                          color: Colors.white,
                          padding: EdgeInsets.all(10),
                          onPressed: _isAuthenticating
                              ? null
                              : () async {
                                  if (!_isAuthenticating) {
//                                    _showScaffold(
//                                        "Scan your fingerprint to authenticate or Face");
                                    bool auth = await _authenticate();
                                    if (auth)
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) => Home()),
                                          (Route<dynamic> route) => false);
                                    else {
                                      showMessage(context, 'try login',
                                          'You are not authorized', false);
                                    }
                                  }
                                },
                          child: Text('Try again'),
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  void showAlert(String pin, BuildContext buildContext) {
    Size size = MediaQuery.of(buildContext).size;
    bool valid = true;
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        content: Container(
            // width: size.width,
            //height: size.height * .25,
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey)),
              child: TextField(
                textAlign: TextAlign.center,
                controller: pincontroller,
                maxLength: 4,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: FCITextStyle(color: valid ? Colors.black87 : Colors.red)
                    .bold18(),
                onSubmitted: (value) {},
                onChanged: (val) {
                  setState(() {
                    valid = true;
                  });
                },
                autofocus: false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  // fillColor: Colors.white,
                  counterText: '',
                  hintText: "enterpin".tr(),
                  hintStyle:
                      FCITextStyle(color: valid ? Colors.grey : Colors.red)
                          .normal16(),
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(25),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    if (pincontroller.text == pin)
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Home()),
                          (Route<dynamic> route) => false);
                    else {
                      setState(() {
                        valid = false;
                      });
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    // height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(100),
                    decoration: BoxDecoration(
                      color: Color(0xff00d164),
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      "verify".tr(),
                      style: FCITextStyle(color: Colors.white).normal18(),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context, 1);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    //height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(100),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      "cancel".tr(),
                      style: FCITextStyle(color: Colors.white).normal18(),
                    ),
                  ),
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}

//import 'dart:async';
//
//import 'package:checkpoint/constants.dart';
//import 'package:checkpoint/provider/CasheManger.dart';
//import 'package:checkpoint/style/FCITextStyles.dart';
//import 'package:checkpoint/ui/Home.dart';
//import 'package:checkpoint/widget/background.dart';
//import 'package:easy_localization/easy_localization.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
//
////import 'package:local_auth/local_auth.dart';
//
//import 'Auth/auth_page.dart';
//
//enum _SupportState {
//  unknown,
//  supported,
//  unsupported,
//}
//
//class Splash extends StatefulWidget {
//  @override
//  SplashScreenState createState() => SplashScreenState();
//}
//
//class SplashScreenState extends State<Splash> {
//  //SharedPreferences pref;
//  TextEditingController pincontroller = new TextEditingController(text: '');
//  /* final LocalAuthentication auth = LocalAuthentication();
//  _SupportState _supportState = _SupportState.unknown;
//  bool _canCheckBiometrics;
//  List<BiometricType> _availableBiometrics;
//  String _authorized = 'Not Authorized';
//  bool _isAuthenticating = false;*/
//  @override
//  void initState() {
//    super.initState();
//    WidgetsBinding.instance.addPostFrameCallback((_) async {
//      Timer(Duration(seconds: 2), () async {
//        init();
//
//        //print('sup $_supportState');
//      });
//    });
//  }
//
//  /*Future<void> _checkBiometrics() async {
//    bool canCheckBiometrics;
//    try {
//      canCheckBiometrics = await auth.canCheckBiometrics;
//    } on PlatformException catch (e) {
//      canCheckBiometrics = false;
//      print(e);
//    }
//    if (!mounted) return;
//
//    setState(() {
//      _canCheckBiometrics = canCheckBiometrics;
//    });
//  }
//
//  Future<void> _getAvailableBiometrics() async {
//    List<BiometricType> availableBiometrics;
//    try {
//      availableBiometrics = await auth.getAvailableBiometrics();
//    } on PlatformException catch (e) {
//      availableBiometrics = <BiometricType>[];
//      print(e);
//    }
//    if (!mounted) return;
//
//    setState(() {
//      _availableBiometrics = availableBiometrics;
//    });
//  }
//
//  Future<bool> _authenticate() async {
//    bool authenticated = false;
//    try {
//      setState(() {
//        _isAuthenticating = true;
//        _authorized = 'Authenticating';
//      });
//      authenticated = await auth.authenticate(
//          localizedReason: 'Let OS determine authentication method',
//          useErrorDialogs: true,
//          stickyAuth: true);
//      print('hhh $authenticated');
//      setState(() {
//        _isAuthenticating = false;
//      });
//    } on PlatformException catch (e) {
//      print(e);
//      setState(() {
//        _isAuthenticating = false;
//        _authorized = "Error - ${e.message}";
//      });
//      return authenticated;
//    }
//    if (!mounted) return false;
//
//    setState(
//        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
//    return authenticated;
//  }
//
//  Future<bool> _authenticateWithBiometrics() async {
//    bool authenticated = false;
//    try {
//      setState(() {
//        _isAuthenticating = true;
//        _authorized = 'Authenticating';
//      });
//      print('herem');
//
//      authenticated = await auth.authenticate(
//          localizedReason:
//              'Scan your fingerprint (or face or whatever) to authenticate',
//          useErrorDialogs: true,
//          stickyAuth: true,
//          biometricOnly: true);
//      print('herem $authenticated');
//
//      setState(() {
//        _isAuthenticating = false;
//        _authorized = 'Authenticating';
//      });
//    } on PlatformException catch (e) {
//      print(e);
//      setState(() {
//        _isAuthenticating = false;
//        _authorized = "Error - ${e.message}";
//      });
//      return authenticated;
//    }
//    if (!mounted) return null;
//
//    final String message = authenticated ? 'Authorized' : 'Not Authorized';
//    setState(() {
//      _authorized = message;
//    });
//    return authenticated;
//  }
//
//  void _cancelAuthentication() async {
//    await auth.stopAuthentication();
//    setState(() => _isAuthenticating = false);
//  }*/
//
//  init() async {
//    bool isLogin;
//    isLogin = await CacheManger().getIsLogin();
//    if (isLogin != null && isLogin) {
//      /*  await auth.isDeviceSupported().then((isSupported) async {
//        setState(() {
//          _supportState =
//              isSupported ? _SupportState.supported : _SupportState.unsupported;
//        });
//        if (isSupported) {
//          bool auth = await _authenticate();
//          if (auth)
//            Navigator.of(context).pushAndRemoveUntil(
//                MaterialPageRoute(builder: (context) => Home()),
//                (Route<dynamic> route) => false);
//        } else {*/
//      String pincode = await CacheManger().getPinCode();
//      if (pincode == null) {
//        Navigator.of(context).pushAndRemoveUntil(
//            MaterialPageRoute(
//                builder: (context) => AuthPage(
//                      authType: AuthType.login,
//                    )),
//            (Route<dynamic> route) => false);
////        await CacheManger().savePinCode('1111');
////        Navigator.of(context).pushAndRemoveUntil(
////            MaterialPageRoute(builder: (context) => Home()),
////            (Route<dynamic> route) => false);
//      } else {
//        showAlert(pincode, context);
//      }
//      // }
//      // });
//    } else {
//      Navigator.of(context).pushAndRemoveUntil(
//          MaterialPageRoute(
//              builder: (context) => AuthPage(
//                    authType: AuthType.login,
//                  )),
//          (Route<dynamic> route) => false);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Background(
//        show: false,
//        child: Center(
//          child: Image.asset("assets/images/logo2.png",
//              fit: BoxFit.contain,
//              height: ScreenUtil().setHeight(300),
//              width: ScreenUtil().setWidth(300)),
//        ),
//      ),
//    );
//  }
//
//  void showAlert(String pin, BuildContext buildContext) {
//    Size size = MediaQuery.of(buildContext).size;
//    bool valid = true;
//    showDialog(
//      context: buildContext,
//      barrierDismissible: false,
//      builder: (context) => AlertDialog(
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.all(Radius.circular(15))),
//        content: Container(
//            // width: size.width,
//            //height: size.height * .25,
//            child: Column(
//          mainAxisSize: MainAxisSize.min,
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: [
//            /* Text(
//              "confirmpin".tr(),
//              style: FCITextStyle().bold18(),
//            ),*/
//            Container(
//              decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(10),
//                  border: Border.all(color: Colors.grey)),
//              child: TextField(
//                textAlign: TextAlign.center,
//                controller: pincontroller,
//                maxLength: 4,
//                obscureText: true,
//                keyboardType: TextInputType.number,
//                style: FCITextStyle(color: valid ? Colors.black87 : Colors.red)
//                    .bold18(),
//                onSubmitted: (value) {},
//                onChanged: (val) {
//                  setState(() {
//                    valid = true;
//                  });
//                },
//                autofocus: false,
//                decoration: InputDecoration(
//                  border: InputBorder.none,
//                  // fillColor: Colors.white,
//                  counterText: '',
//                  hintText: "enterpin".tr(),
//                  hintStyle:
//                      FCITextStyle(color: valid ? Colors.grey : Colors.red)
//                          .normal16(),
//                ),
//              ),
//            ),
//            SizedBox(
//              height: ScreenUtil().setHeight(25),
//            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: [
//                InkWell(
//                  onTap: () {
//                    if (pincontroller.text == pin)
//                      Navigator.of(context).pushAndRemoveUntil(
//                          MaterialPageRoute(builder: (context) => Home()),
//                          (Route<dynamic> route) => false);
//                    else {
//                      setState(() {
//                        valid = false;
//                      });
//                    }
//                  },
//                  child: Container(
//                    alignment: Alignment.center,
//                    // height: ScreenUtil().setHeight(50),
//                    width: ScreenUtil().setWidth(100),
//                    decoration: BoxDecoration(
//                      color: Color(0xff00d164),
//                      borderRadius: BorderRadius.all(
//                        Radius.circular(15),
//                      ),
//                    ),
//                    child: Text(
//                      "verify".tr(),
//                      style: FCITextStyle(color: Colors.white).normal18(),
//                    ),
//                  ),
//                ),
//                InkWell(
//                  onTap: () {
//                    Navigator.pop(context, 1);
//                  },
//                  child: Container(
//                    alignment: Alignment.center,
//                    //height: ScreenUtil().setHeight(50),
//                    width: ScreenUtil().setWidth(100),
//                    decoration: BoxDecoration(
//                      color: Colors.red,
//                      borderRadius: BorderRadius.all(
//                        Radius.circular(15),
//                      ),
//                    ),
//                    child: Text(
//                      "cancel".tr(),
//                      style: FCITextStyle(color: Colors.white).normal18(),
//                    ),
//                  ),
//                )
//              ],
//            ),
//          ],
//        )),
//      ),
//    );
//  }
//}
