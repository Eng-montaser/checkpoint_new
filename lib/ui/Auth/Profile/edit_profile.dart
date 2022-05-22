import 'dart:async';
import 'dart:io';

import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/CasheManger.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:checkpoint/widget/CustomWidgets.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:checkpoint/widget/button_animated.dart';
import 'package:checkpoint/widget/rounded_input_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';

import '../../Home.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with TickerProviderStateMixin {
  bool? isLoading;
  AnimationController? _loginButtonController;

  final GlobalKey<ScaffoldState> _updateScaffoldKey =
      GlobalKey<ScaffoldState>();
  var provider;
  @override
  void initState() {
    super.initState();
    setData();
    isLoading = false;
    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  setData() async {
    provider = Provider.of<AuthProvider>(context, listen: false);
    _nameTextEditingController =
        new TextEditingController(text: provider.userData.name);
    _phoneTextEditingController =
        new TextEditingController(text: provider.userData.phone);
    _pincontroller = new TextEditingController(
        text: provider.userData.pin_code == null ||
                provider.userData.pin_code == 'null'
            ? '1111'
            : provider.userData.pin_code);
    _designationTextEditingController =
        new TextEditingController(text: provider.userData.designation);
    _tallTextEditingController =
        new TextEditingController(text: provider.userData.tall);
    _weightTextEditingController =
        new TextEditingController(text: provider.userData.weight);
    _nationality = provider.userData.nationality != null
        ? provider.userData.nationality
        : '';
  }

  @override
  void dispose() {
    AuthProvider().dispose();
    super.dispose();
  }

  String phoneFormat(String phone) {
    String res = '';
    if (phone != null) if (phone.length > 8) {
      String first = phone.substring(0, 3);
      String last = phone.substring(6);
      String middle = phone.substring(3, 6);
      res = last + ' ' + middle + ' ' + first;
    }
    return res;
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController!.forward();
    } on TickerCanceled {
      // printLog('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController!.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      //  printLog('[_stopAnimation] error');
    }
  }

/*[٨:٢٠ ص، ٢٠٢١/١٠/٨] م.محمد رمضان: https://check-points.fsdmarketing.com/api/update  post
[٨:٢٢ ص، ٢٠٢١/١٠/٨] م.محمد رمضان: [
            'designation'=>'required',
            'phone'=>'required',
            'image'=>'required',
            'pin_code'=>'required'
        ]
[٨:٢٣ ص، ٢٠٢١/١٠/٨] م.محمد رمضان: ['weight','tall','nationality'] optional*/
  int? _updateValidate;
  var focusNode = FocusNode();
  File? imageData;
  TextEditingController? _nameTextEditingController;
  TextEditingController? _phoneTextEditingController;
  TextEditingController? _pincontroller;
  TextEditingController? _designationTextEditingController;
  TextEditingController? _tallTextEditingController;
  TextEditingController? _weightTextEditingController;
  String? _nationality;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
      child: SafeArea(
        child: Scaffold(
          key: _updateScaffoldKey,
          body: Background(
            show: false,
            child: SingleChildScrollView(
                // color: kPrimaryColor,
                child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height -
                    ScreenUtil().setHeight(120),
              ),
              child: IntrinsicHeight(
                child: Column(
//                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(15),
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
                                style:
                                    FCITextStyle(color: Colors.white).bold30(),
                              ),
                            ],
                          ),
                          Container()
                        ],
                      ),
                    ),
                    Container(),
                    InkWell(
                      onTap: () async {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) => CupertinoActionSheet(
                                  actions: [
                                    CupertinoActionSheetAction(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Camera",
                                            style:
                                                FCITextStyle(color: Colors.blue)
                                                    .bold20(),
                                          ),
                                          SizedBox(
                                            width: ScreenUtil().setWidth(20),
                                          ),
                                          Icon(
                                            Icons.camera_alt,
                                            size: ScreenUtil().setSp(35),
                                            color: Colors.blue,
                                          )
                                        ],
                                      ),
                                      isDefaultAction: true,
                                      onPressed: () async {
                                        Navigator.of(context).pop();

                                        var image = await ImagePicker.platform
                                            .pickImage(
                                                source: ImageSource.camera);
                                        if (image != null)
                                          imageData = File(image.path);
                                      },
                                    ),
                                    CupertinoActionSheetAction(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Gallery",
                                            style:
                                                FCITextStyle(color: Colors.blue)
                                                    .bold20(),
                                          ),
                                          SizedBox(
                                            width: ScreenUtil().setWidth(20),
                                          ),
                                          Icon(
                                            Icons.image,
                                            size: ScreenUtil().setSp(35),
                                            color: Colors.blue,
                                          )
                                        ],
                                      ),
                                      isDefaultAction: true,
                                      onPressed: () async {
                                        Navigator.of(context).pop();

                                        var image = await ImagePicker.platform
                                            .pickImage(
                                                source: ImageSource.gallery);

                                        if (image != null)
                                          imageData = File(image.path);
                                      },
                                    ),
                                  ],
                                ));
                      },
                      child: CustomWidgets().CircleImage(
                          networkImageUrl: provider.userData.image,
                          assetsImagePath: 'assets/images/man-300x300.png',
                          radius: 70,
                          fileImage: imageData),
                    ),
                    CustomTextInput(
                      hintText: "name".tr(),
                      leading: Icons.person,
                      obscure: false,
                      focusNode: _updateValidate == 2 ? focusNode : null,
                      controller: _nameTextEditingController,
                    ),
                    CustomTextInput(
                      hintText: "phone",
                      leading: Icons.phone_android,
                      obscure: false,
                      focusNode: _updateValidate == 3 ? focusNode : null,
                      controller: _phoneTextEditingController,
                    ),
                    CustomTextInput(
                      hintText: "designation",
                      leading: Icons.notes,
                      obscure: false,
                      focusNode: _updateValidate == 4 ? focusNode : null,
                      controller: _designationTextEditingController,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(5)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xfff1f1f1), width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      width: MediaQuery.of(context).size.width * 0.70,
                      height: ScreenUtil().setHeight(60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Pin Code",
                            style: FCITextStyle().normal20(),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.70 -
                                ScreenUtil().setWidth(120),
                            child: PinCodeTextField(
//                              autofocus: true,
                              controller: _pincontroller,
                              hideCharacter: true,
                              highlight: true,

                              highlightColor: Colors.grey,
                              defaultBorderColor: Colors.grey,
                              hasTextBorderColor: Colors.green,
                              highlightPinBoxColor: Colors.white,
                              maxLength: 4,
//                              hasError: hasError,
//                              maskCharacter: "😎",
                              onTextChanged: (text) {
                                setState(() {
//                                  hasError = false;
                                });
                              },
                              onDone: (text) {},
                              pinBoxWidth: ScreenUtil().setWidth(40),
                              pinBoxHeight: ScreenUtil().setHeight(50),
                              hasUnderline: false,
                              wrapAlignment: WrapAlignment.center,
                              pinBoxDecoration: ProvidedPinBoxDecoration
                                  .defaultPinBoxDecoration,
                              pinTextStyle: FCITextStyle().normal20(),
                              pinTextAnimatedSwitcherTransition:
                                  ProvidedPinBoxTextAnimation.scalingTransition,
//                    pinBoxColor: Colors.green[100],
                              pinTextAnimatedSwitcherDuration:
                                  Duration(milliseconds: 300),
//                    highlightAnimation: true,
                              highlightAnimationBeginColor: Colors.black,
                              highlightAnimationEndColor: Colors.white12,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(5)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xfff1f1f1), width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      width: MediaQuery.of(context).size.width * 0.70,
                      height: ScreenUtil().setHeight(50),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _tallTextEditingController,
                        // focusNode: focusNode,
                        onSubmitted: (value) {},
                        maxLength: 3,
                        autofocus: false,
                        decoration: InputDecoration(
                            suffixIcon: Text(
                              "CM",
                              style: FCITextStyle().bold18(),
                            ),
                            icon: Icon(
                              Icons.notes,
                              color: Colors.grey,
                            ),
                            counterText: "",
                            border: InputBorder.none,
                            hintText: "tall",
                            hintStyle: FCITextStyle().normal20(),
                            isDense: true),
                        style: FCITextStyle().normal20(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(5)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xfff1f1f1), width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10)),
                      width: MediaQuery.of(context).size.width * 0.70,
                      height: ScreenUtil().setHeight(50),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _weightTextEditingController,
                        // focusNode: focusNode,
                        onSubmitted: (value) {},
                        maxLength: 3,
                        autofocus: false,
                        decoration: InputDecoration(
                            suffixIcon: Text(
                              "KG",
                              style: FCITextStyle().bold18(),
                            ),
                            icon: Icon(
                              Icons.notes,
                              color: Colors.grey,
                            ),
                            counterText: "",
                            border: InputBorder.none,
                            hintText: "weight",
                            hintStyle: FCITextStyle().normal20(),
                            isDense: true),
                        style: FCITextStyle().normal20(),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        showCountryPicker(
                          context: context,
                          //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).
                          exclude: <String>['KN', 'MF'],
                          //Optional. Shows phone code before the country name.
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            setState(() {
                              _nationality = country.name;
                            });
                            print('Select country: ${country.displayName}');
                          },
                          // Optional. Sets the theme for the country list picker.
                          countryListTheme: CountryListThemeData(
                            // Optional. Sets the border radius for the bottomsheet.
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40.0),
                              topRight: Radius.circular(40.0),
                            ),

                            // Optional. Styles the search field.
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              hintText: 'Start typing to search',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      const Color(0xFF8C98A8).withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        );
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
                              _nationality != null
                                  ? '$_nationality'
                                  : "choose nationality",
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
                      height: ScreenUtil().setHeight(50),
                    ),
                    StaggerAnimation(
                      titleButton: "Edit".tr(),
                      foreground: Colors.white,
                      context: context,
                      background: primaryColor,
                      buttonController: _loginButtonController!.view,
                      onTap: () async {
                        _updateValidate = updateValidate();
                        if (_updateValidate == 0) {
                          print("Okay");
                          await _playAnimation();
                          AuthenticationData authenticationData =
                              new AuthenticationData(
                                  name: _nameTextEditingController!.text,
                                  phone: _phoneTextEditingController!.text,
                                  designation:
                                      _designationTextEditingController!.text,
                                  pin_code: _pincontroller!.text,
                                  tall: _tallTextEditingController!.text,
                                  weight: _weightTextEditingController!.text,
                                  nationality:
                                      _nationality != null ? _nationality : '');
                          await Provider.of<AuthProvider>(context,
                                  listen: false)
                              .updateUserData(imageData, authenticationData)
                              .then((response) async {
                            if (response.success) {
                              await CacheManger().saveIsLogin(true);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => Home()),
                                  (Route<dynamic> route) => false);
//                              response.successUpdateMessage(context);
////                              Timer(Duration(seconds: 3), () {
////                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
////                                    Profile()), (Route<dynamic> route) => false);
////                              });
                            } else {
                              response.failUpdateMessage(context);
                            }
                          });
                        }
                        await _stopAnimation();
                      },
                    ),

//                  Expanded(
//                    child: Align(
//                      alignment: Alignment.bottomCenter,
//                      child: Padding(
//                        padding: const EdgeInsets.symmetric(vertical: 10),
//                        child: Align(
//                          alignment: Alignment.bottomCenter,
//                          child: Column(
//                            mainAxisSize: MainAxisSize.min,
//                            children: [
//                              StaggerAnimation(
//                                titleButton: 'logout'.tr(),
//                                buttonController: _loginButtonController.view,
//                                onTap: () async {
//                                  if (!isLoading) {
//                                    await Provider.of<AuthProvider>(context,
//                                            listen: false)
//                                        .logout();
//                                    Navigator.of(context)
//                                        .pushNamedAndRemoveUntil('splash',
//                                            (Route<dynamic> route) => false);
//                                  }
//                                },
//                              ),
//                              Padding(
//                                padding: const EdgeInsets.only(
//                                  top: 15.0,
//                                ),
//                                child: Text(
//                                  'V.0.0.1',
//                                  style: TextStyle(
//                                      fontSize: 20,
//                                      fontWeight: FontWeight.bold),
//                                ),
//                              )
//                            ],
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
                  ],
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }

  int updateValidate() {
    if (imageData == null && provider.userData.image == null) {
      _showScaffold("Image required");
      return 1;
    }
    if (_nameTextEditingController!.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("Name required");
      return 2;
    }
    if (_phoneTextEditingController!.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("Phone required");
      return 3;
    }
    if (_designationTextEditingController!.text.isEmpty) {
      focusNode = new FocusNode();
      focusNode.requestFocus();
      _showScaffold("Designation required");
      return 4;
    }
    if (_pincontroller!.text.isEmpty || _pincontroller!.text.length != 4) {
//      focusNode = new FocusNode();
//      focusNode.requestFocus();
      _showScaffold("Pin Code required");
      return 5;
    }
    print("Validate");
    return 0;
  }

  void _showScaffold(String message) {
    _updateScaffoldKey.currentState!.showSnackBar(SnackBar(
      backgroundColor: Colors.grey,
      duration: Duration(milliseconds: 3000),
      content: Text(message,
          textAlign: TextAlign.center, style: FCITextStyle().normal16()),
    ));
  }
}
