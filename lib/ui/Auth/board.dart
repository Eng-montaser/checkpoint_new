import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../style/constants.dart';
import 'auth_page.dart';

class Board extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
                  Image.asset("assets/images/logo2.png",
                      fit: BoxFit.contain,
                      height: ScreenUtil().setHeight(300),
                      width: ScreenUtil().setWidth(300)),
                  SizedBox(
                    height: ScreenUtil().setHeight(20),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AuthPage(
                                    authType: AuthType.signUp,
                                  )));
                    },
                    child: Container(
                      height: ScreenUtil().setHeight(50),
                      width: size.width * .35,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "signup".tr(),
                          style: FCITextStyle(color: Colors.white).bold18(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(20),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AuthPage(
                                    authType: AuthType.login,
                                  )));
                    },
                    child: Container(
                      height: ScreenUtil().setHeight(50),
                      width: size.width * .35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "login".tr(),
                          style: FCITextStyle(color: primaryColor).bold18(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
