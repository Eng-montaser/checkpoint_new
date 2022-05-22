import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/CasheManger.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/ui/Auth/auth_page.dart';
import 'package:checkpoint/widget/CustomWidgets.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:easy_localization/easy_localization.dart' as T;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../style/constants.dart';
import 'edit_profile.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool showpin = false;
  String pincode = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    AuthProvider().dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var provider = Provider.of<AuthProvider>(context, listen: false);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        body: Background(
          show: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              // vertical: ScreenUtil().setHeight(10),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        // top: ScreenUtil().setHeight(15),
                        right: ScreenUtil().setWidth(20),
                        left: ScreenUtil().setWidth(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/location.png",
                                fit: BoxFit.fill,
//                          height: ScreenUtil().setHeight(200),
                                width: ScreenUtil().setWidth(35)),
                            SizedBox(
                              width: ScreenUtil().setWidth(15),
                            ),
                            Text(
                              "CHECK POINT",
                              style: FCITextStyle(color: Colors.white).bold30(),
                            ),
                          ],
                        ),
                        Container()
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      ///-------------------- Edit Profile Button
                      Container(
                        alignment: Alignment.bottomLeft,
                        height: ScreenUtil().setHeight(180),
                        decoration: BoxDecoration(
                          color: PrimaryColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 2.5,
                              blurRadius: 5.5,
                            )
                          ],
                        ),
                        child: InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile()));
                          },
                          child: Container(
                            height: ScreenUtil().setHeight(50),
                            width: ScreenUtil().setWidth(90),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 2.5,
                                  blurRadius: 5.5,
                                )
                              ],
                            ),
                            child: Text(
                              "Edit".tr(),
                              style: FCITextStyle(color: primaryColor)
                                  .normal16()
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),

                      ///-------------------------------------end
                      ///-------------------- Edit Profile Button
                      Container(
                          alignment: Alignment.center,
                          //  height: ScreenUtil().setHeight(300),
                          padding: EdgeInsets.symmetric(
                            // horizontal: ScreenUtil().setWidth(60),
                            vertical: ScreenUtil().setHeight(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                '${provider.userData != null ? provider.userData.name != null ? provider.userData.name : '' : ''}',
                                style:
                                    FCITextStyle(color: Colors.white).bold22(),
                              ),
                              Text(
                                  '${provider.userData != null ? provider.userData.phone != null ? provider.userData.phone : '' : ''}',
                                  style: FCITextStyle(color: Colors.white)
                                      .bold22()),
                              SizedBox(
                                height: ScreenUtil().setHeight(10),
                              ),
                              CustomWidgets().CircleImage(
                                  networkImageUrl: provider.userData.image,
                                  assetsImagePath:
                                      'assets/images/man-300x300.png',
                                  radius: 70,
                                  fileImage: null),
                            ],
                          ))
                    ],
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(10)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(10),
                                  vertical: ScreenUtil().setHeight(10)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                color: Colors.grey[100],
                              ),
                              child: Icon(
                                Icons.language_rounded,
                                color: Colors.black54,
                                size: ScreenUtil().setSp(30),
                              ),
                            ),
                            Text(
                              "language".tr(),
                              style: FCITextStyle(color: Colors.white).bold16(),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            await T.EasyLocalization.of(context)!.setLocale(
                                T.EasyLocalization.of(context)!
                                            .locale
                                            .languageCode ==
                                        'en'
                                    ? Locale('ar', 'SA')
                                    : Locale('en', 'US'));

                            /* widget.model.changeLanguage(
                                T.EasyLocalization.of(context).locale);*/
                          },
                          child: Row(
                            children: [
                              Text(
                                "lang".tr(),
                                style:
                                    FCITextStyle(color: Colors.grey).normal18(),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_sharp,
                                color: buttonIncident,
                                size: ScreenUtil().setSp(30),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            showAlert(context);
                          },
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(10)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(10),
                                    vertical: ScreenUtil().setHeight(10)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  color: Colors.grey[100],
                                ),
                                child: Icon(
                                  Icons.lock_open_outlined,
                                  color: Colors.black54,
                                  size: ScreenUtil().setSp(30),
                                ),
                              ),
                              Text(
                                "pincode".tr(),
                                style:
                                    FCITextStyle(color: Colors.white).bold16(),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            showpin
                                ? Text(
                                    "${pincode}",
                                    style: FCITextStyle(color: Colors.grey)
                                        .normal18(),
                                  )
                                : Text(
                                    "####",
                                    style: FCITextStyle(color: Colors.grey)
                                        .normal18(),
                                  ),
                            SizedBox(
                              width: ScreenUtil().setWidth(7),
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    showpin = !showpin;
                                  });
                                },
                                child: Icon(
                                  showpin
                                      ? Icons.remove_red_eye_outlined
                                      : CupertinoIcons.eye_slash,
                                  color: Colors.grey,
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: InkWell(
                      onTap: () async {
                        await Provider.of<AuthProvider>(context, listen: false)
                            .logout()
                            .then((value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthPage(
                                        authType: AuthType.login,
                                      )));
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(10)),
                            padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(10),
                                vertical: ScreenUtil().setHeight(10)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              color: Colors.grey[100],
                            ),
                            child: Icon(
                              Icons.logout,
                              color: Colors.black54,
                              size: ScreenUtil().setSp(30),
                            ),
                          ),
                          Text(
                            'logout'.tr(),
                            style: FCITextStyle(color: Colors.white).bold16(),
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  void init() {
    CacheManger().getPinCode().then((value) => setState(() {
          if (value != null) pincode = value;
        }));
  }

  void showAlert(BuildContext buildContext) {
    Size size = MediaQuery.of(buildContext).size;
    bool valid = true;
    TextEditingController pincontroller = new TextEditingController(text: '');
    TextEditingController cpincontroller = new TextEditingController(text: '');
    showDialog(
      context: buildContext,
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
            /* Text(
              "confirmpin".tr(),
              style: FCITextStyle().bold18(),
            ),*/
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey)),
              child: TextField(
                textAlign: TextAlign.center,
                controller: pincontroller,
                maxLength: 4,
                keyboardType: TextInputType.number,
                style: FCITextStyle(color: valid ? Colors.black87 : Colors.red)
                    .normal16(),
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
              height: ScreenUtil().setHeight(10),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey)),
              child: TextField(
                textAlign: TextAlign.center,
                controller: cpincontroller,
                maxLength: 4,
                keyboardType: TextInputType.number,
                style: FCITextStyle(color: valid ? Colors.black87 : Colors.red)
                    .normal16(),
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
                  hintText: "centerpin".tr(),
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
                  onTap: () async {
                    if (pincontroller.text.length == 4 &&
                        cpincontroller.text == pincontroller.text) {
//                      await CacheManger().savePinCode(pincontroller.text);
                      setState(() {
                        pincode = pincontroller.text;
                      });
                      Navigator.pop(context, 0);
                    } else {
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
                      "update".tr(),
                      style: FCITextStyle(color: Colors.white).normal18(),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context, 0);
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
