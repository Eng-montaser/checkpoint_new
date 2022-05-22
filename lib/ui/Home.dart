import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:checkpoint/chat/Contacts.dart';
import 'package:checkpoint/model/MallData.dart';
import 'package:checkpoint/model/PointsData.dart';
import 'package:checkpoint/model/SosData.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/GetProvider.dart';
import 'package:checkpoint/provider/PostProvider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:checkpoint/ui/Auth/Profile/Profile.dart';
import 'package:checkpoint/ui/Incident.dart';
import 'package:checkpoint/ui/MyRoute.dart';
import 'package:checkpoint/ui/Tasks.dart';
import 'package:checkpoint/ui/Timer.dart';
import 'package:checkpoint/widget/ButtonHome.dart';
import 'package:checkpoint/widget/CustomWidgets.dart';
import 'package:checkpoint/widget/ProgressHUD.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:checkpoint/widget/sound_recorder.dart';
import 'package:connectivity/connectivity.dart';
import 'package:easy_localization/easy_localization.dart' as T;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:provider/provider.dart';
import 'package:torch_light/torch_light.dart';

import 'maps.dart';

const hintColor = Color(0xff787878);
const blueColor = Color(0xff00bde8);
const greenColor = Color(0xff6fb200);
const redColor = Color(0xffc0000d);

class Home extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  bool _isStart = false, isLoading = false, flashOn = false;
  bool isPaused = false;
  SosData sosData = new SosData(long: '', lat: '');
  Location location = new Location();
  LocationData? _locationData;
  String? tour_status, endtime, tour_time;
  String _connectionStatus = 'Unknown';

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  connection_type myconnection_type = connection_type.none;

  UserPoints point =
          new UserPoints(assigned_points: 0, unScandPoints: 0, scandPoints: 0),
      gettenpoint =
          new UserPoints(assigned_points: 0, unScandPoints: 0, scandPoints: 0);
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  Duration actual = new Duration(), acceptable = new Duration();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<AuthProvider>(context, listen: false)
          .setUserDataFromCache();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<GetProvider>(context, listen: false)
          .isStart()
          .then((startResponse) async {
        if (startResponse != null) {
          setState(() {
            _isStart = startResponse.is_start;
            //_isEnd = !startResponse.is_start;
            tour_status = startResponse.tour_status;
            tour_time = startResponse.tour_time;
          });
          if (startResponse.tour_status == "start") {
            await Provider.of<GetProvider>(context, listen: false)
                .getPoints()
                .then((startResponse) async {
              if (startResponse != null) {
                setState(() {
                  point = startResponse;
                });
              }
            });
          }
        } else {
          setState(() {
            _isStart = false;
          });
        }
      });
      await Provider.of<GetProvider>(context, listen: false)
          .getPoints()
          .then((startResponse) async {
        if (startResponse != null) {
          setState(() {
            gettenpoint = startResponse;
          });
        }
      });
    });
    super.initState();
    initPermission();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  initPermission() async {
    bool check = await PH.Permission.location.isGranted;
    if (!check) {
      disclosureMessage(context);
      PermissionStatus status =
          (await PH.Permission.location.request()) as PermissionStatus;
      if (status != PermissionStatus.granted) {
        //throw LocationPermissionException("Microphone permission not granted");
      }
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        if (await APICacheManager().isAPICacheKeyExist("start_time")) {
          var starttime = await APICacheManager().getCacheData("start_time");
          if (starttime != null) {
            print('stst ${starttime.syncData}');
            setState(() {
              _isStart = true;
              tour_time = starttime.syncData;
              tour_status = "start";
            });
          }
        }
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  void execude() async {
    if (await APICacheManager().isAPICacheKeyExist("scanned_points")) {
      var scanned_points =
          await APICacheManager().getCacheData("scanned_points");
      if (scanned_points != null) {
        var scannedData = jsonDecode(scanned_points.syncData);

        await Provider.of<PostProvider>(context, listen: false)
            .offlineScan(jsonEncode(scannedData))
            .then((value) async {
          if (value != null && value != false) {
            showMessage(
                context, 'SCAN', '${value['message']}', value['success']);
            await APICacheManager().deleteCache("scanned_points");
          } else if (value != null && value == false)
            showMessage(context, 'SCAN', '${value['message']}', false);
          else
            showMessage(context, 'SCAN', 'scanfail'.tr(), false);
        });
      }
    }
    if (await APICacheManager().isAPICacheKeyExist("soses")) {
      var scanned_points = await APICacheManager().getCacheData("soses");
      if (scanned_points != null) {
        var scannedData = jsonDecode(scanned_points.syncData);
        print('Data from cache m $scannedData');
        await Provider.of<PostProvider>(context, listen: false)
            .offlineSos(jsonEncode(scannedData))
            .then((value) async {
          if (value != null && value == true) {
            showMessage(context, 'SOS Success', 'sossuccess'.tr(), true);
            await APICacheManager().deleteCache("soses");
          } else
            showMessage(context, 'SOS Fail', 'sosfail'.tr(), false);
        });
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          myconnection_type = connection_type.wifi;
        });
        Timer(Duration(milliseconds: 500), () {
          execude();
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          myconnection_type = connection_type.mobile;
        });
        Timer(Duration(milliseconds: 1000), () {
          execude();
        });
        break;
      case ConnectivityResult.none:
        setState(() {
          myconnection_type = connection_type.none;
        });
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  addSosToCache(SosData data) async {
    if (await APICacheManager().isAPICacheKeyExist("soses")) {
      var scanned_points = await APICacheManager().getCacheData("soses");
      if (scanned_points != null) {
        var scannedData = jsonDecode(scanned_points.syncData);
        scannedData.add(data.getBody());
        print('Data y cache m ${data.getBody()}');

        APICacheDBModel apiCacheDBModel =
            APICacheDBModel(key: 'soses', syncData: jsonEncode(scannedData));
        await APICacheManager().addCacheData(apiCacheDBModel);
      }
    } else {
      List<dynamic> scan = [];
      scan.add(data.getBody());
      print('Data n cache m ${data.getBody()}');

      APICacheDBModel apiCacheDBModel =
          APICacheDBModel(key: 'soses', syncData: jsonEncode(scan));
      await APICacheManager().addCacheData(apiCacheDBModel);
    }
    showOfflineMessage(
        context, 'Offline_SOS', 'Sos will be sent when connected');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AuthProvider? provider = Provider.of<AuthProvider>(context, listen: true);
    //var provider2 = Provider.of<PostProvider>(context, listen: true);
    calculateDur(provider);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: ProgressHUD(
        inAsyncCall: isLoading,
        child: Background(
          show: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    height: size.height * 0.25,
                    width: size.width * 0.7,
                    padding:
                        EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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
                        Container(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Profile()));
                                },
                                child: Container(
                                  width: size.width * 0.5,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomWidgets().CircleImage(
                                          networkImageUrl:
                                              provider.userData.image,
                                          assetsImagePath:
                                              'assets/images/man-300x300.png',
                                          radius: 30,
                                          fileImage: null),
                                      SizedBox(
                                        width: ScreenUtil().setWidth(20),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.contain,
                                            child: Container(
                                              width: size.width * 0.3,
                                              child: Text(
                                                '${provider.userData != null ? provider.userData.name != null ? provider.userData.name : '' : ''}',
                                                style: FCITextStyle(
                                                        color: Colors.white)
                                                    .bold16(),
                                              ),
                                            ),
                                          ),
                                          if (provider.userData != null)
                                            if (provider.userData.nationality !=
                                                    null ||
                                                provider.userData.nationality ==
                                                    "null")
                                              Text(
                                                "${provider.userData.nationality}",
                                                style: FCITextStyle(
                                                        color: Colors.white)
                                                    .normal13(),
                                              ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                Expanded(
                  child: Container(
                    // height: size.height * 0.55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100.0),
                        topRight: Radius.circular(100.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 2.5,
                          blurRadius: 5.5,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20),
                          top: ScreenUtil().setHeight(40),
                          bottom: ScreenUtil().setHeight(10)),
                      child: Column(
                        //  mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setHeight(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: ScreenUtil().setHeight(10)),
                                      child: Icon(CupertinoIcons.stopwatch_fill,
                                          size: ScreenUtil().setSp(35),
                                          color: greenColor),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(7),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${getTodayDate()}',
                                          style: FCITextStyle(color: hintColor)
                                              .normal13()
                                              .copyWith(height: 1),
                                        ),
                                        Text(
                                          tour_status != null &&
                                                  tour_status == "start"
                                              ? '${tour_time!.split('T')[1].split('.')[0]}'
                                              : '00:00',
                                          style: FCITextStyle(color: hintColor)
                                              .normal20()
                                              .copyWith(height: 1.2),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: ScreenUtil().setHeight(10)),
                                      child: Icon(CupertinoIcons.stopwatch_fill,
                                          size: ScreenUtil().setSp(35),
                                          color: redColor),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(7),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${getTodayDate()}',
                                          style: FCITextStyle(color: hintColor)
                                              .normal13()
                                              .copyWith(height: 1),
                                        ),
                                        Text(
                                          endtime != null
                                              ? '${endtime!.split(' ')[1].split('.')[0]}'
                                              : '00:00',
                                          style: FCITextStyle(color: hintColor)
                                              .normal20()
                                              .copyWith(height: 1.2),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(10),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(60),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  width: size.width * .25,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Tour Duration',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(fontFamily: ''),
                                      ),
                                      if (provider.userData.shift_hours != null)
                                        Text(
                                          '${Duration(hours: int.parse('${provider.userData.shift_hours}')).toString().split('.')[0]}',
                                          style: FCITextStyle(color: hintColor)
                                              .normal13()
                                              .copyWith(fontFamily: ''),
                                        )
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                  color: hintColor,
                                  width: ScreenUtil().setWidth(30),
                                  thickness: .5,
                                  endIndent: 12,
                                  indent: 12,
                                ),
                                Container(
                                  width: size.width * .25,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Actual Duration',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(fontFamily: ''),
                                      ),
                                      if (actual != null)
                                        Text(
                                          '${actual.toString().split('.')[0]}',
                                          style: FCITextStyle(color: hintColor)
                                              .normal13()
                                              .copyWith(fontFamily: ''),
                                        )
                                    ],
                                  ),
                                ),
                                VerticalDivider(
                                  color: hintColor,
                                  width: ScreenUtil().setWidth(30),
                                  thickness: .5,
                                  endIndent: 12,
                                  indent: 12,
                                ),
                                Container(
                                  width: size.width * .25,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Remaining',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(fontFamily: ''),
                                      ),
                                      acceptable != null
                                          ? Text(
                                              '${acceptable.toString().split('.')[0]}',
                                              style:
                                                  FCITextStyle(color: hintColor)
                                                      .normal13()
                                                      .copyWith(fontFamily: ''),
                                            )
                                          : Text(
                                              '${Duration(hours: int.parse(provider.userData.shift_hours!)).toString().split('.')[0]}',
                                              style:
                                                  FCITextStyle(color: hintColor)
                                                      .normal13()
                                                      .copyWith(fontFamily: ''))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(10),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(65),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  width: size.width * .25,
                                  child: InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyTimer(
                                                    taskStatus:
                                                        TaskStatus.Required,
                                                    startTime:
                                                        '${provider.userData.shift_start!.replaceRange(4, 7, '')}',
                                                    endTime:
                                                        '${provider.userData.shift_end!.replaceRange(4, 7, '')}',
                                                  )));
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_pin,
                                              color: blueColor,
                                              size: ScreenUtil().setSp(40),
                                            ),
                                            Text(
                                              '${point.assigned_points ?? 0}',
                                              style:
                                                  FCITextStyle(color: hintColor)
                                                      .normal25(),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Assigned',
                                          style: FCITextStyle(color: hintColor)
                                              .normal13()
                                              .copyWith(fontFamily: ''),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: hintColor,
                                  width: ScreenUtil().setWidth(30),
                                  thickness: .5,
                                  endIndent: 12,
                                  indent: 12,
                                ),
                                Container(
                                  width: size.width * .25,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyTimer(
                                                    taskStatus: TaskStatus.Red,
                                                    startTime:
                                                        '${provider.userData.shift_start?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                                    endTime:
                                                        '${provider.userData.shift_end?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                                  )));
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_pin,
                                              color: greenColor,
                                              size: ScreenUtil().setSp(40),
                                            ),
                                            Text(
                                              '${point.scandPoints ?? 0}',
                                              style:
                                                  FCITextStyle(color: hintColor)
                                                      .normal25(),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Scanned',
                                          style: FCITextStyle(color: hintColor)
                                              .normal13()
                                              .copyWith(fontFamily: ''),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: hintColor,
                                  width: ScreenUtil().setWidth(30),
                                  thickness: .5,
                                  endIndent: 12,
                                  indent: 12,
                                ),
                                Container(
                                  width: size.width * .25,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyTimer(
                                                    taskStatus:
                                                        TaskStatus.Missed,
                                                    startTime:
                                                        '${provider.userData.shift_start?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                                    endTime:
                                                        '${provider.userData.shift_end?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                                  )));
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_pin,
                                              color: redColor,
                                              size: ScreenUtil().setSp(40),
                                            ),
                                            Text(
                                              '${point.unScandPoints ?? 0}',
                                              style:
                                                  FCITextStyle(color: hintColor)
                                                      .normal25(),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'UnScanned',
                                          style: FCITextStyle(color: hintColor)
                                              .normal13()
                                              .copyWith(fontFamily: ''),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(20),
                          ),
                          Divider(
                            color: hintColor,
                            height: ScreenUtil().setHeight(20),
                            thickness: .3,
                            endIndent: 35,
                            indent: 35,
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(20),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonHome(
                                  color: tour_status == null ||
                                          tour_status == "end"
                                      ? Color(0xff00d164)
                                      : buttonFlash,
                                  text: "Start",
                                  icon: Icons.play_circle_outline_outlined,
                                  onpress: () async {
                                    _serviceEnabled =
                                        await location.serviceEnabled();

                                    if (!_serviceEnabled!) {
                                      AwesomeDialog(
                                          context: context,
                                          animType: AnimType.LEFTSLIDE,
                                          headerAnimationLoop: false,
                                          dialogType: DialogType.NO_HEADER,
                                          dismissOnBackKeyPress: true,
                                          dismissOnTouchOutside: true,
                                          title: "",
                                          desc:
                                              "You have to enable your location detector",
                                          btnOkText: "yes".tr(),
                                          btnOkColor: Colors.lightGreen,
                                          btnOkOnPress: () async {
                                            _serviceEnabled =
                                                await location.requestService();
                                            if (!_serviceEnabled!) {
                                              return;
                                            } else {
                                              _locationData =
                                                  await location.getLocation();
                                              await Provider.of<PostProvider>(
                                                      context,
                                                      listen: false)
                                                  .startTour({
                                                "checkin_lat":
                                                    "${_locationData?.latitude}",
                                                "checkin_long":
                                                    "${_locationData?.longitude}"
                                              }).then((value) async {
                                                if (value != null) {
                                                  setState(() {
                                                    _isStart = true;
                                                    endtime = null;
                                                    point = gettenpoint;
                                                    tour_status = "start";
                                                    tour_time = value;
                                                  });
                                                  APICacheDBModel
                                                      apiCacheDBModel =
                                                      APICacheDBModel(
                                                          key: 'start_time',
                                                          syncData: value);
                                                  await APICacheManager()
                                                      .addCacheData(
                                                          apiCacheDBModel);
                                                }
                                              });
                                            }
                                          },
                                          btnCancelText: "no".tr(),
                                          btnCancelColor: Colors.red,
                                          btnCancelOnPress: () {},
                                          onDissmissCallback: (type) {})
                                        ..show();
                                    } else {
                                      _locationData =
                                          await location.getLocation();
                                      if (tour_status == null ||
                                          tour_status == "end")
                                        AwesomeDialog(
                                            context: context,
                                            animType: AnimType.LEFTSLIDE,
                                            headerAnimationLoop: false,
                                            dialogType: DialogType.NO_HEADER,
                                            dismissOnBackKeyPress: true,
                                            dismissOnTouchOutside: true,
                                            title: "",
                                            desc: "startDay".tr(),
                                            btnOkText: "yes".tr(),
                                            btnOkColor: Color(0xff00d164),
                                            btnOkOnPress: () async {
                                              /* if (_isStart) {
                                              AwesomeDialog(
                                                  context: context,
                                                  animType: AnimType.LEFTSLIDE,
                                                  headerAnimationLoop: false,
                                                  dialogType: DialogType.ERROR,
                                                  dismissOnBackKeyPress: true,
                                                  dismissOnTouchOutside: true,
                                                  title: "",
                                                  desc: "startMess".tr(),
                                                  onDissmissCallback: (type) {})
                                                ..show();
                                            } else {
                                              print(
                                                  'data is${_locationData.latitude}');
                                            }*/
                                              await Provider.of<PostProvider>(
                                                      context,
                                                      listen: false)
                                                  .startTour({
                                                "checkin_lat":
                                                    "${_locationData!.latitude}",
                                                "checkin_long":
                                                    "${_locationData!.longitude}"
                                              }).then((value) async {
                                                if (value != null) {
                                                  setState(() {
                                                    _isStart = true;
                                                    tour_status = "start";
                                                    point = gettenpoint;
                                                    tour_time = value;
                                                  });
                                                  APICacheDBModel
                                                      apiCacheDBModel =
                                                      APICacheDBModel(
                                                          key: 'start_time',
                                                          syncData: value);
                                                  await APICacheManager()
                                                      .addCacheData(
                                                          apiCacheDBModel);
                                                }
                                              });
                                            },
                                            btnCancelText: "no".tr(),
                                            btnCancelColor: Colors.red,
                                            btnCancelOnPress: () {},
                                            onDissmissCallback: (type) {})
                                          ..show();
                                    }
                                  }),
                              SizedBox(
                                width: ScreenUtil().setWidth(30),
                              ),
                              ButtonHome(
                                  color: tour_status != null &&
                                          tour_status == "start"
                                      ? Color(0xff00d164)
                                      : buttonFlash,
                                  text: "End",
                                  icon: Icons.stop_circle_outlined,
                                  onpress: () {
                                    if (tour_status != null &&
                                        tour_status == "start")
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyRoute(
                                                    shift_end: endtime,
                                                    shift_start: tour_time,
                                                    accept: acceptable != null
                                                        ? '${acceptable.toString().split('.')[0]}'
                                                        : '${provider.userData.shift_hours ?? '0'}',
                                                    actual:
                                                        '${actual.toString().split('.')[0]}',
                                                    tour: provider
                                                        .userData.shift_hours,
                                                  ))).then((value) async {
                                        if (value != null) {
                                          if (value) {
                                            setState(() {
                                              _isStart = false;
                                              tour_status = null;
                                              tour_time = null;
                                              endtime =
                                                  DateTime.now().toString();
                                            });
                                            if (await APICacheManager()
                                                .isAPICacheKeyExist(
                                                    "start_time"))
                                              await APICacheManager()
                                                  .deleteCache("start_time");
                                          }
                                        }
                                      });
                                  }),
                            ],
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(25),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              tour_status != null && tour_status == "start"
                                  ? ButtonHome(
                                      color: buttonScan,
                                      text: "scan".tr(),
                                      icon: Icons.grid_view,
                                      onpress: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MapScreen()));
                                      })
                                  : ButtonHome(
                                      color: buttonFlash,
                                      text: "scan".tr(),
                                      icon: Icons.grid_view,
                                      onpress: () {}),
                              SizedBox(
                                width: ScreenUtil().setWidth(30),
                              ),
                              ButtonHome(
                                  color: buttonSOS,
                                  text: "incident".tr(),
                                  icon: Icons.menu_open_outlined,
                                  onpress: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                IncidentPage()));
                                  }),
                            ],
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(25),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonHome(
                                  color: buttonSOS,
                                  text: "Task",
                                  icon: Icons.check_box_sharp,
                                  onpress: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Tasks()));
                                  }),
                              SizedBox(
                                width: ScreenUtil().setWidth(30),
                              ),
                              ButtonHome(
                                  color:
                                      flashOn ? Color(0xff00d164) : buttonFlash,
                                  text: "Flash",
                                  icon: flashOn
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  onpress: () {
                                    setState(() {
                                      flashOn = !flashOn;
                                    });
                                    if (flashOn)
                                      TorchLight.enableTorch();
                                    else
                                      TorchLight.disableTorch();
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ///////startrecordd////////
                //if (_isRecording)

                ///////endrecordd////////
                Container(
                  height: ScreenUtil().setHeight(60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: size.width * .25,
                        child: InkWell(
                          onTap: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoActionSheet(
                                      title: Text(
                                        "select".tr(),
                                        style: FCITextStyle().bold16(),
                                      ),
                                      actions: _createListView(emergency_texts),
                                      cancelButton: CupertinoActionSheetAction(
                                        child: Text(
                                          "Cancel".tr(),
                                          style: FCITextStyle().bold16(),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.bell_solid,
                                color: Colors.white,
                                size: ScreenUtil().setSp(25),
                              ),
                              Text(
                                'SOS',
                                style: FCITextStyle(color: Colors.white)
                                    .normal13(),
                              )
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.white,
                        width: ScreenUtil().setWidth(30),
                        // thickness: .5,
                        endIndent: 12,
                        indent: 12,
                      ),
                      Container(
                        width: size.width * .25,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Contacts()));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.chat_bubble_2_fill,
                                color: Colors.white,
                                size: ScreenUtil().setSp(25),
                              ),
                              Text(
                                'Chat',
                                style: FCITextStyle(color: Colors.white)
                                    .normal13(),
                              )
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.white,
                        width: ScreenUtil().setWidth(30),
                        // thickness: .5,
                        endIndent: 12,
                        indent: 12,
                      ),
                      Container(
                        width: size.width * .25,
                        child: InkWell(
                          // onTap: onStartRecorderPressed(),
                          onTap: () {
                            showAlert2();
                            //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MySoundWidget()));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.mic_solid,
                                color: Colors.white,
                                size: ScreenUtil().setSp(25),
                              ),
                              Text(
                                'Push to talk',
                                style: FCITextStyle(color: Colors.white)
                                    .normal13(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ),
    );
  }

  int message_id = 0;
  String message_text = "";
  List<CupertinoActionSheetAction>? _createListView(
    //BuildContext context,
    List<Action_Messages> data,
  ) {
    Size size = MediaQuery.of(context).size;
    List<CupertinoActionSheetAction>? cupertinoActionSheetAction;
    if (data != null) {
      CupertinoActionSheetAction e = new CupertinoActionSheetAction(
        onPressed: () {},
        child: Container(),
      );
      cupertinoActionSheetAction = List.filled(data.length, e);
      for (int index = 0; index < data.length; index++) {
        cupertinoActionSheetAction[index] = new CupertinoActionSheetAction(
            //leading: new Icon(CupertinoIcons.directions_car),
            child: new Text(
              '${data[index].message}',
              style: FCITextStyle().normal16(),
            ),
            onPressed: () {
              Navigator.pop(context);
              message_id = data[index].id;
              message_text = data[index].message;
              if (message_id > 0 && message_text.isNotEmpty)
                AwesomeDialog(
                    context: context,
                    animType: AnimType.LEFTSLIDE,
                    headerAnimationLoop: false,
                    dialogType: DialogType.NO_HEADER,
                    dismissOnBackKeyPress: true,
                    dismissOnTouchOutside: true,
                    title: "",
                    desc: "sendSOS".tr(),
                    btnOkText: "yes".tr(),
                    btnOkColor: Color(0xff00d164),
                    btnOkOnPress: () async {
                      _locationData = await location.getLocation();
                      setState(() {
                        isLoading = true;
//
                        sosData = new SosData(
                          lat: '${_locationData!.latitude}',
                          long: '${_locationData!.longitude}',
                          message_id: data[index].id,
                          message_text: '${data[index].message}',
                        );
                      });
                      ConnectivityResult? result;
                      try {
                        result = await _connectivity.checkConnectivity();
                      } on PlatformException catch (e) {
                        print(e.toString());
                      }
                      if (result != ConnectivityResult.none) {
                        await Provider.of<PostProvider>(context, listen: false)
                            .sos(sosData)
                            .then((value) {
                          if (value != null && value == true) {
                            showMessage(
                                context, "SOS", "sossuccess".tr(), true);
                          } else
                            showMessage(context, "SOS", "sosfail".tr(), false);
                        });
                      } else {
                        print('ccca ${sosData.getBody()}');
                        addSosToCache(sosData);
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    btnCancelText: "no".tr(),
                    btnCancelColor: Colors.red,
                    btnCancelOnPress: () {},
                    onDissmissCallback: (type) {})
                  ..show();
            });
      }
    }
    return cupertinoActionSheetAction;
  }

  @override
  void dispose() {
    AuthProvider().dispose();
    GetProvider().dispose();
    PostProvider().dispose();
    _connectivitySubscription!.cancel();

    super.dispose();
  }

  String getTodayDate() {
    //print('${DateTime.now().toString()}');
    String mydate = '';
    mydate =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    return mydate;
  }

  void calculateDur(provider) {
    DateTime today = DateTime.now();
    if (tour_time != null &&
        provider?.userData?.shift_hours != null &&
        tour_status == "start") {
      actual = DateTime.now().difference(DateTime.parse(tour_time!));
//      DateTime endDate = new DateTime(today.year, today.month, today.day,
//          today.hour + int.parse('${provider?.userData?.shift_hours}'));
      DateTime endDate = new DateTime.now().add(
          Duration(hours: int.parse('${provider?.userData?.shift_hours}')));
      // actual = temp;
      acceptable = endDate.difference(DateTime.now().add(actual));
    } else {
      actual = new Duration(hours: 0, minutes: 0, seconds: 0);
      acceptable = new Duration(hours: 0, minutes: 0, seconds: 0);
      point =
          new UserPoints(assigned_points: 0, unScandPoints: 0, scandPoints: 0);
    }
  }

  void showAlert2() {
    // Size size = MediaQuery.of(buildContext).size;
    // recordDura();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              content: Container(
                // width: size.width,
                //height: size.height * .25,
                child: SimpleRecorder(
                  widgetAction: uploadSound,
                ),
              ),
            ));
  }

  Future uploadSound(String path, bool status) async {
    Navigator.of(context).pop();
    if (status) {
      setState(() {
        isLoading = true;
      });
      //print('lara1 $path');
      File sound = await File(path);
//    int ll = await sound.length();
//    print('adam ${ll}');

      await Provider.of<PostProvider>(context, listen: false)
          .sendAudioTalk(sound)
          .then((value) {
        if (!value) {
          showMessage(context, 'Error Talking', 'Failed to send talks', false);
        }
      });

      setState(() {
        isLoading = false;
      });
    }
  }
}
