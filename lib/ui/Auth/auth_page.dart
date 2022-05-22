import 'package:checkpoint/ui/Auth/signup.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:flutter/material.dart';

import '../../style/constants.dart';
import 'login.dart';

class AuthPage extends StatefulWidget {
  final AuthType? authType;
  AuthPage({this.authType});
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<ScaffoldState> registerScaffoldKey =
      new GlobalKey<ScaffoldState>();
  AuthType? _authType;
  @override
  void initState() {
    super.initState();
    _authType = widget.authType;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: registerScaffoldKey,
      body: Background(
        show: true,
        child: Container(
          height: size.height,
          width: size.width,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _authType == AuthType.login
                      ? Login(
                          loginScaffoldKey: registerScaffoldKey,
                        )
                      : SignUp(
                          registerScaffoldKey: registerScaffoldKey,
                        ),
//                  _authType==AuthType.login
//                      ? Column(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: <Widget>[
//                            Text(
//                              'or'.tr(),
//                              textAlign: TextAlign.center,
//                                style:FCITextStyle(color: Colors.white).bold25()
//                            ),
//                            SizedBox(
//                              height: ScreenUtil().setHeight(24),
//                            ),
//                            InkWell(
//                              onTap: () {
//                                setState(() {
//                                  _authType=AuthType.signUp;
//                                });
//                              },
//                              child: Container(
//                                height: ScreenUtil().setHeight(50),
//                                width: size.width * .70,
//                                decoration: BoxDecoration(
//                                  color: Colors.white,
//                                  borderRadius: BorderRadius.all(
//                                    Radius.circular(25),
//                                  ),
//                                  boxShadow: [
//                                    BoxShadow(
//                                      color: accentColor.withOpacity(0.2),
//                                      spreadRadius: 3,
//                                      blurRadius: 4,
//                                      offset: Offset(0, 3),
//                                    ),
//                                  ],
//                                ),
//                                child: Center(
//                                  child: Text(
//                                    "signup".tr(),
//                                    style: FCITextStyle(color: primaryColor)
//                                        .bold18(),
//                                  ),
//                                ),
//                              ),
//                            ),
//                          ],
//                        )
//                      : Column(
//                          //crossAxisAlignment: CrossAxisAlignment.stretch,
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Text(
//                              "or".tr(),
//                              textAlign: TextAlign.center,
//                                style:FCITextStyle(color: Colors.white).bold25()
//                            ),
//                            SizedBox(
//                              height: ScreenUtil().setHeight(10),
//                            ),
//                            InkWell(
//                              onTap: () {
//                                setState(() {
//                                  _authType=AuthType.login;
//                                });
//                              },
//                              child: Container(
//                                height: ScreenUtil().setHeight(50),
//                                width: size.width * .70,
//                                decoration: BoxDecoration(
//                                  color: Colors.white,
//                                  borderRadius: BorderRadius.all(
//                                    Radius.circular(25),
//                                  ),
//                                ),
//                                child: Center(
//                                  child: Text(
//                                    "login".tr(),
//                                    style: FCITextStyle(color: primaryColor)
//                                        .bold18(),
//                                  ),
//                                ),
//                              ),
//                            ),
//                          ],
//                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
