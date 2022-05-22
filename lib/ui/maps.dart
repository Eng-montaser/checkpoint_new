import 'dart:async';
import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:checkpoint/model/SosData.dart';
import 'package:checkpoint/provider/PostProvider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/widget/ProgressHUD.dart';
import 'package:connectivity/connectivity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:provider/provider.dart';

import '../style/constants.dart';
import 'Home.dart';
import 'Incident.dart';

class MapScreen extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<MapScreen> {
  // data
  //Completer<GoogleMapController> _controller = Completer();
  bool showScan = false;
//  static final CameraPosition _kGooglePlex = CameraPosition(
//    target: LatLng(37.42796133580664, -122.085749655962),
//    zoom: 14.4746,
//  );
  String _scanBarcode = 'Unknown';
  String _connectionStatus = 'Unknown';
  connection_type myconnection_type = connection_type.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  SosData sosData = new SosData(long: '', lat: '');
  Location location = new Location();
  LocationData? _locationData;
  bool? _serviceEnabled, isLoading = false;
  PermissionStatus? _permissionGranted;
  @override
  void initState() {
    super.initState();

    init();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
  }

  @override
  void dispose() {
    PostProvider().dispose();
    _connectivitySubscription!.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
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
        print('Data from cache m $scannedData');
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
        // execude();
        break;
      case ConnectivityResult.mobile:
        setState(() {
          myconnection_type = connection_type.mobile;
        });
        //execude();
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

  init() async {
    initPermission();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      _locationData = currentLocation;
      /* sosData = new SosData(
          lat: '${currentLocation.latitude}',
          long: '${currentLocation.longitude}');*/ // Use current location
    });
  }

  // functions

  // building the search page widget
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        appBar: AppBar(
          //  backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false);
            },
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.white,
            ),
          ),
          title: Row(
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
          elevation: 0.0,
        ),
        body: ProgressHUD(
          inAsyncCall: isLoading!,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/Group 20.png'),
                        fit: BoxFit.cover),
                    color: showScan ? Colors.white : Colors.transparent,
                    //borderRadius: BorderRadius.circular(25)
                  ),
                  height: size.height * .40,
                  width: size.width,
                  child:
                      /*showScan
                      ? ElevatedButton(
                          onPressed: () => scanQR(),
                          child: Text('Start QR scan'))
                      : */
                      Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: Image.asset("assets/images/qrcode.png",
                            fit: BoxFit.fill,
                            height: ScreenUtil().setHeight(200),
                            width: ScreenUtil().setWidth(200)),
                      ),
                    ],
                  ),
//                        : _buildQrView(context, status: false),
                ),
                Container(
                  child: button(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget button() {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(30)),
              decoration: BoxDecoration(
                  color: Color(0xff2a4054),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25))),
              child: Column(
                children: [
                  mybutton(Icons.grid_view, Color(0xff3ee58b), false,
                      /* showScan ? 'stopscan'.tr() :*/ 'startscan'.tr(),
                      () async {
                    scanQR();
                    setState(() {
                      showScan = !showScan;
                    });
                  }),
                  SizedBox(
                    height: ScreenUtil().setHeight(15),
                  ),
                  Text(
                    'checkponit'.tr(),
                    style: FCITextStyle(color: Colors.white).normal16(),
                  )
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(15),
            ),
            Text(
              'barcodedone'.tr(),
              style: FCITextStyle(color: Colors.black87).bold16(),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(15),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${'starttime'.tr()}\n${TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute).format(context)}',
                  style: FCITextStyle(color: Colors.black45).normal14(),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(40)),
                  color: Colors.black26,
                  width: 1,
                  height: 50,
                ),
                Text(
                  '${'scanstatus'.tr()}\n${showScan ? 'scanning'.tr() : 'notscanning'.tr()}',
                  style: FCITextStyle(color: Colors.black45).normal14(),
                ),
              ],
            ),
            SizedBox(
              height: ScreenUtil().setHeight(35),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                mybutton(Icons.menu_open_outlined, Color(0xffe53e3e), true,
                    'incident'.tr(), incidentAction,
                    width: .25),
                SizedBox(
                  width: ScreenUtil().setWidth(25),
                ),
                mybutton(Icons.email, Color(0xff7b8d8d), true, 'SOS', sosAction,
                    width: .25)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget mybutton(IconData icondata, Color color, bool isSmall, String text,
      Function() ontap,
      {double width = .35}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        ///height: 50,
        width: MediaQuery.of(context).size.width * width,
        padding: EdgeInsets.symmetric(
            //horizontal: ScreenUtil().setWidth(15),
            vertical: ScreenUtil().setHeight(5)),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icondata,
              color: Colors.white,
              size: isSmall ? ScreenUtil().setSp(15) : ScreenUtil().setSp(30),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(5),
            ),
            Text(
              '$text',
              style: isSmall
                  ? FCITextStyle(color: Colors.white).normal16()
                  : FCITextStyle(color: Colors.white).bold20(),
            ),
          ],
        ),
      ),
    );
  }

  incidentAction() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => IncidentPage()));
  }

  int action_id = 0;
  String action_text = "";
  sosAction() async {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
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
    /* ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.NO_HEADER,
        dismissOnBackKeyPress: true,
        dismissOnTouchOutside: true,
        title: "",
        desc: "sosconfirm".tr(),
        btnOkText: "yes".tr(),
        btnOkColor: Colors.lightGreen,
        btnOkOnPress: () async {
          setState(() {
            isLoading = true;
          });
          print('hheree $myconnection_type');

          if (result != ConnectivityResult.none) {
            print('hheree $myconnection_type');
            await Provider.of<PostProvider>(context, listen: false)
                .sos(sosData)
                .then((value) {
              if (value != null && value == true) {
                showMessage(context, 'SOS Success', 'sossuccess'.tr(), true);
              } else
                showMessage(context, 'SOS Fail', 'sosfail'.tr(), false);
            });
          } else {
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
      ..show();*/
  }

  List<CupertinoActionSheetAction>? _createListView(
    //BuildContext context,
    List<Action_Messages> data,
  ) {
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
              action_id = data[index].id;
              action_text = data[index].message;

              if (data[index].id > 0 && data[index].message.isNotEmpty)
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
                      sosData = new SosData(
                        lat: '${_locationData!.latitude}',
                        long: '${_locationData!.longitude}',
                        message_id: data[index].id,
                        message_text: '${data[index].message}',
                      );
                      setState(() {
                        isLoading = true;
//
                      });
                      ConnectivityResult? result;
                      try {
                        result = await _connectivity.checkConnectivity();
                      } on PlatformException catch (e) {
                        print(e.toString());
                      }
                      if (result != ConnectivityResult.none) {
                        print('sssss ${sosData.getBody()}');
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

  Future<void> scanQR() async {
    _serviceEnabled = await location.serviceEnabled();
    ConnectivityResult? result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!_serviceEnabled!) {
      AwesomeDialog(
          context: context,
          animType: AnimType.LEFTSLIDE,
          headerAnimationLoop: false,
          dialogType: DialogType.NO_HEADER,
          dismissOnBackKeyPress: true,
          dismissOnTouchOutside: true,
          title: "",
          desc: "You have to enable your location detector",
          btnOkText: "yes".tr(),
          btnOkColor: Colors.lightGreen,
          btnOkOnPress: () async {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled!) {
              return;
            } else {
              _locationData = await location.getLocation();
              String barcodeScanRes;
              // Platform messages may fail, so we use a try/catch PlatformException.
              try {
                barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                    '#ff6666', 'Cancel', true, ScanMode.QR);
                print('ttt ${barcodeScanRes}');
              } on PlatformException {
                barcodeScanRes = 'Failed to get platform version.';
              }
              if (barcodeScanRes != null) {
                setState(() {
                  isLoading = true;
                });
                var data = {
                  "qr_text": "${barcodeScanRes}",
                  "lat": "${_locationData!.latitude}",
                  "long": "${_locationData!.longitude}"
                };

                if (result != ConnectivityResult.none) {
                  await Provider.of<PostProvider>(context, listen: false)
                      .scan(data)
                      .then((value) {
                    if (value != null && value != false) {
                      showMessage(context, 'SCAN', '${value['message']}',
                          value['success']);
                    } else if (value != null && value == false)
                      showMessage(
                          context, 'SCAN', '${value['message']}', false);
                    else
                      showMessage(context, 'SCAN', 'scanfail'.tr(), false);
                  });
                } else {
                  addToCache(data);
                }
                // controller.pauseCamera();
                setState(() {
                  isLoading = false;
                  showScan = false;
                });
              } else {
                //controller.resumeCamera();

                setState(() {});
              }
              // If the widget was removed from the tree while the asynchronous platform
              // message was in flight, we want to discard the reply rather than calling
              // setState to update our non-existent appearance.
              if (!mounted) return;

              setState(() {
                _scanBarcode = barcodeScanRes;
              });
            }
          },
          btnCancelText: "no".tr(),
          btnCancelColor: Colors.red,
          btnCancelOnPress: () {},
          onDissmissCallback: (type) {})
        ..show();
    } else {
      _locationData = await location.getLocation();

      String barcodeScanRes;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
        print('ttt ${barcodeScanRes}');
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }
      if (barcodeScanRes != null) {
        setState(() {
          isLoading = true;
        });
        var data = {
          "qr_text": "${barcodeScanRes}",
          "lat": "${_locationData!.latitude}",
          "long": "${_locationData!.longitude}"
        };
        if (result != ConnectivityResult.none) {
          await Provider.of<PostProvider>(context, listen: false)
              .scan(data)
              .then((value) {
            if (value != null && value != false) {
              showMessage(
                  context, 'SCAN', '${value['message']}', value['success']);
            } else if (value != null && value == false)
              showMessage(context, 'SCAN', '${value['message']}', false);
            else
              showMessage(context, 'SCAN', 'scanfail'.tr(), false);
          });
        } else {
          addToCache(data);
        }
        // controller.pauseCamera();
        setState(() {
          isLoading = false;
          showScan = false;
        });
      } else {
        //controller.resumeCamera();

        setState(() {});
      }
      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _scanBarcode = barcodeScanRes;
      });
    }
  }

  addToCache(data) async {
    if (await APICacheManager().isAPICacheKeyExist("scanned_points")) {
      var scanned_points =
          await APICacheManager().getCacheData("scanned_points");
      if (scanned_points != null) {
        var scannedData = jsonDecode(scanned_points.syncData);
        scannedData.add(data);
        APICacheDBModel apiCacheDBModel = APICacheDBModel(
            key: 'scanned_points', syncData: jsonEncode(scannedData));
        await APICacheManager().addCacheData(apiCacheDBModel);
      }
    } else {
      List<dynamic> scan = [];
      scan.add(data);
      APICacheDBModel apiCacheDBModel =
          APICacheDBModel(key: 'scanned_points', syncData: jsonEncode(scan));
      await APICacheManager().addCacheData(apiCacheDBModel);
    }
    showOfflineMessage(
        context, 'Offline_Scan', 'Reports will be sent when connected');
  }

  addSosToCache(SosData data) async {
    if (await APICacheManager().isAPICacheKeyExist("soses")) {
      var scanned_points = await APICacheManager().getCacheData("soses");
      if (scanned_points != null) {
        var scannedData = jsonDecode(scanned_points.syncData);
        scannedData.add(data.getBody());
        APICacheDBModel apiCacheDBModel =
            APICacheDBModel(key: 'soses', syncData: jsonEncode(scannedData));
        await APICacheManager().addCacheData(apiCacheDBModel);
      }
    } else {
      List<dynamic> scan = [];
      scan.add(data.getBody());
      APICacheDBModel apiCacheDBModel =
          APICacheDBModel(key: 'soses', syncData: jsonEncode(scan));
      await APICacheManager().addCacheData(apiCacheDBModel);
    }
    showOfflineMessage(
        context, 'Offline_SOS', 'Sos will be sent when connected');
  }
}

//import 'package:awesome_dialog/awesome_dialog.dart';
//import 'package:checkpoint/model/SosData.dart';
//import 'package:checkpoint/provider/PostProvider.dart';
//import 'package:checkpoint/style/FCITextStyles.dart';
//import 'package:easy_localization/easy_localization.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter/widgets.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:location/location.dart';
//import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:provider/provider.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
//
//import '../constants.dart';
//import 'Incident.dart';
//
//class MapScreen extends StatefulWidget {
//  @override
//  _SearchPageState createState() => _SearchPageState();
//}
//
//class _SearchPageState extends State<MapScreen> {
//  // data
//  //Completer<GoogleMapController> _controller = Completer();
//  bool showScan = false;
////  static final CameraPosition _kGooglePlex = CameraPosition(
////    target: LatLng(37.42796133580664, -122.085749655962),
////    zoom: 14.4746,
////  );
//
//  Barcode result;
//  QRViewController controller;
//  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//  SosData sosData = new SosData(long: '', lat: '');
//  Location location = new Location();
//  LocationData _locationData;
//  bool _serviceEnabled, isLoading = false;
//  PermissionStatus _permissionGranted;
//  @override
//  void initState() {
//    super.initState();
//    init();
//    // _getCurrentUserNameAndUid();
//  }
//
//  @override
//  void dispose() {
//    controller?.dispose();
//    super.dispose();
//  }
//
//  /*@override
//  void reassemble() {
//    super.reassemble();
//    if (Platform.isAndroid) {
//      controller?.pauseCamera();
//    }
//    controller?.resumeCamera();
//  }
//*/
//  init() async {
//    _serviceEnabled = await location.serviceEnabled();
//    if (!_serviceEnabled) {
//      _serviceEnabled = await location.requestService();
//      if (!_serviceEnabled) {
//        return;
//      }
//    }
//
//    _permissionGranted = await location.hasPermission();
//    if (_permissionGranted == PermissionStatus.denied) {
//      _permissionGranted = await location.requestPermission();
//      if (_permissionGranted != PermissionStatus.granted) {
//        return;
//      }
//    }
//
//    _locationData = await location.getLocation();
//    location.onLocationChanged.listen((LocationData currentLocation) {
//      _locationData = currentLocation;
//      sosData = new SosData(
//          lat: '${currentLocation.latitude}',
//          long: '${currentLocation.longitude}'); // Use current location
//    });
//  }
//
//  // functions
//
//  // building the search page widget
//  @override
//  Widget build(BuildContext context) {
//    Size size = MediaQuery.of(context).size;
//    return AnnotatedRegion<SystemUiOverlayStyle>(
//      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
//      child: Scaffold(
//        appBar: AppBar(
//          //  backgroundColor: Colors.white,
//          leading: IconButton(
//            onPressed: () {
//              Navigator.of(context).pop();
//            },
//            icon: Icon(
//              Icons.arrow_back_ios_outlined,
//              color: Colors.white,
//            ),
//          ),
//          title: Row(
//            crossAxisAlignment: CrossAxisAlignment.center,
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: [
//              Image.asset("assets/images/location.png",
//                  fit: BoxFit.fill,
////                          height: ScreenUtil().setHeight(200),
//                  width: ScreenUtil().setWidth(35)),
//              SizedBox(
//                width: ScreenUtil().setWidth(15),
//              ),
//              Text(
//                "CHECK POINT",
//                style: FCITextStyle(color: Colors.white).bold30(),
//              ),
//            ],
//          ),
//          elevation: 0.0,
//        ),
//        body: ModalProgressHUD(
//          inAsyncCall: isLoading,
//          child: Center(
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: [
//                Container(
//                  alignment: Alignment.center,
//
//                  decoration: BoxDecoration(
//                    image: DecorationImage(
//                        image: AssetImage('assets/images/Group 20.png'),
//                        fit: BoxFit.cover),
//                    color: showScan ? Colors.white : Colors.transparent,
//                    //borderRadius: BorderRadius.circular(25)
//                  ),
//                  height: size.height * .40,
//                  width: size.width,
//                  child: showScan
//                      ? _buildQrView(context)
//                      : Column(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: [
//                            ClipRRect(
//                              borderRadius:
//                                  BorderRadius.all(Radius.circular(15)),
//                              child: Image.asset("assets/images/qrcode.png",
//                                  fit: BoxFit.fill,
//                                  height: ScreenUtil().setHeight(200),
//                                  width: ScreenUtil().setWidth(200)),
//                            ),
//                          ],
//                        ),
////                        : _buildQrView(context, status: false),
//                ),
//                Container(
//                  child: button(),
//                ),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget button() {
//    return Expanded(
//      child: Align(
//        alignment: Alignment.bottomCenter,
//        child: Column(
//          children: [
//            Container(
//              width: double.infinity,
//              padding:
//                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(30)),
//              decoration: BoxDecoration(
//                  color: Color(0xff2a4054),
//                  borderRadius: BorderRadius.only(
//                      bottomRight: Radius.circular(25),
//                      bottomLeft: Radius.circular(25))),
//              child: Column(
//                children: [
//                  mybutton(Icons.grid_view, Color(0xff3ee58b), false,
//                      showScan ? 'stopscan'.tr() : 'startscan'.tr(), () async {
//                    // if (!showScan) this.controller.resumeCamera();
//                    setState(() {
//                      showScan = !showScan;
//                    });
//                  }),
//                  SizedBox(
//                    height: ScreenUtil().setHeight(15),
//                  ),
//                  Text(
//                    'checkponit'.tr(),
//                    style: FCITextStyle(color: Colors.white).normal16(),
//                  )
//                ],
//              ),
//            ),
//            SizedBox(
//              height: ScreenUtil().setHeight(15),
//            ),
//            Text(
//              'barcodedone'.tr(),
//              style: FCITextStyle(color: Colors.black87).bold16(),
//            ),
//            SizedBox(
//              height: ScreenUtil().setHeight(15),
//            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: [
//                Text(
//                  '${'starttime'.tr()}\n${TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute).format(context)}',
//                  style: FCITextStyle(color: Colors.black45).normal14(),
//                ),
//                Container(
//                  margin: EdgeInsets.symmetric(
//                      horizontal: ScreenUtil().setWidth(40)),
//                  color: Colors.black26,
//                  width: 1,
//                  height: 50,
//                ),
//                Text(
//                  '${'scanstatus'.tr()}\n${showScan ? 'scanning'.tr() : 'notscanning'.tr()}',
//                  style: FCITextStyle(color: Colors.black45).normal14(),
//                ),
//              ],
//            ),
//            SizedBox(
//              height: ScreenUtil().setHeight(35),
//            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: [
//                mybutton(Icons.menu_open_outlined, Color(0xffe53e3e), true,
//                    'incident'.tr(), incidentAction,
//                    width: .25),
//                SizedBox(
//                  width: ScreenUtil().setWidth(25),
//                ),
//                mybutton(Icons.email, Color(0xff7b8d8d), true, 'SOS', sosAction,
//                    width: .25)
//              ],
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget mybutton(
//      IconData icondata, Color color, bool isSmall, String text, Function ontap,
//      {double width = .35}) {
//    return InkWell(
//      onTap: ontap,
//      child: Container(
//        ///height: 50,
//        width: MediaQuery.of(context).size.width * width,
//        padding: EdgeInsets.symmetric(
//            //horizontal: ScreenUtil().setWidth(15),
//            vertical: ScreenUtil().setHeight(5)),
//        decoration: BoxDecoration(
//            color: color, borderRadius: BorderRadius.circular(25)),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: [
//            Icon(
//              icondata,
//              color: Colors.white,
//              size: isSmall ? ScreenUtil().setSp(15) : ScreenUtil().setSp(30),
//            ),
//            SizedBox(
//              width: ScreenUtil().setWidth(5),
//            ),
//            Text(
//              '$text',
//              style: isSmall
//                  ? FCITextStyle(color: Colors.white).normal16()
//                  : FCITextStyle(color: Colors.white).bold20(),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//
//  incidentAction() {
//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) => IncidentPage()));
//  }
//
//  sosAction() async {
//    AwesomeDialog(
//        context: context,
//        animType: AnimType.LEFTSLIDE,
//        headerAnimationLoop: false,
//        dialogType: DialogType.NO_HEADER,
//        dismissOnBackKeyPress: true,
//        dismissOnTouchOutside: true,
//        title: "",
//        desc: "sosconfirm".tr(),
//        btnOkText: "yes".tr(),
//        btnOkColor: Colors.lightGreen,
//        btnOkOnPress: () async {
//          setState(() {
//            isLoading = true;
//          });
//          await Provider.of<PostProvider>(context, listen: false)
//              .sos(sosData)
//              .then((value) {
//            if (value != null && value == true) {
//              showMessage(context, 'SOS Success', 'sossuccess'.tr(), true);
//            } else
//              showMessage(context, 'SOS Fail', 'sosfail'.tr(), false);
//          });
//          setState(() {
//            isLoading = false;
//          });
//        },
//        btnCancelText: "no".tr(),
//        btnCancelColor: Colors.red,
//        btnCancelOnPress: () {},
//        onDissmissCallback: (type) {})
//      ..show();
//  }
//
//  Widget _buildQrView(BuildContext context, {status = true}) {
//    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
//    var scanArea = (MediaQuery.of(context).size.width < 400 ||
//            MediaQuery.of(context).size.height < 400)
//        ? 180.0
//        : 350.0;
//    // To ensure the Scanner view is properly sizes after rotation
//    // we need to listen for Flutter SizeChanged notification and update controller
//    return QRView(
//      key: qrKey,
//      onQRViewCreated: _onQRViewCreated,
//      overlay: QrScannerOverlayShape(
//          borderColor: Colors.red,
//          borderRadius: 10,
//          borderLength: 30,
//          borderWidth: 10,
//          cutOutSize: scanArea),
//      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
//    );
//  }
//
//  void _onQRViewCreated(QRViewController controller) async {
//    setState(() {
//      this.controller = controller;
//    });
//    result = await controller.scannedDataStream.first;
//    if (result?.code != null) {
//      setState(() {
//        isLoading = true;
//      });
//      await Provider.of<PostProvider>(context, listen: false)
//          .scan("${result?.code}")
//          .then((value) {
//        if (value != null && value != false) {
//          showMessage(context, 'SCAN', '${value['message']}', value['success']);
//        } else if (value != null && value == false)
//          showMessage(context, 'SCAN', '${value['message']}', false);
//        else
//          showMessage(context, 'SCAN', 'scanfail'.tr(), false);
//      });
//      // controller.pauseCamera();
//      setState(() {
//        isLoading = false;
//        showScan = false;
//      });
//    } else {
//      //controller.resumeCamera();
//
//      setState(() {});
//    }
//  }
//
//  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
//    if (!p) {
//      ScaffoldMessenger.of(context).showSnackBar(
//        SnackBar(content: Text('no Permission')),
//      );
//    }
//  }
//}
