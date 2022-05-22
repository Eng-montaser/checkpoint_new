import 'dart:io';

import 'package:checkpoint/model/IncidentsData.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/PostProvider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/widget/CustomWidgets.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:checkpoint/widget/button_animated.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../style/constants.dart';
import 'Auth/Profile/Profile.dart';

class IncidentPage extends StatefulWidget {
  @override
  _IncidentPageState createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage>
    with TickerProviderStateMixin {
  AnimationController? _incidentButtonController;
  TextEditingController nameController = new TextEditingController(text: '');
  TextEditingController descController = new TextEditingController(text: '');
  //FocusNode focusNode=new FocusNode();
  String _error = 'No Error Dectected';
  bool nameerror = false, descerror = false;
  List<File> photos = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<AuthProvider>(context, listen: false)
          .setUserDataFromCache();
    });
    _incidentButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    super.initState();
    nameController.addListener(() {
      nameerror = false;
      descerror = false;
    });
    descController.addListener(() {
      nameerror = false;
      descerror = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    AuthProvider().dispose();
    PostProvider().dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await _incidentButtonController!.forward();
    } on TickerCanceled {
      // printLog('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _incidentButtonController!.reverse();
    } on TickerCanceled {
      //  printLog('[_stopAnimation] error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var provider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Background(
        show: false,
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            style: FCITextStyle(color: Colors.white).bold30(),
                          ),
                        ],
                      ),
                      Container()
                    ],
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    height: size.height * 0.9,
                    width: size.width * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                            Text(
                                              "Dubai",
                                              style: FCITextStyle(
                                                      color: Colors.white)
                                                  .normal13(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                              FittedBox(
                                  child: Text(
                                      'Patrol Tour Report -Scanned Tags',
                                      style: FCITextStyle(color: Colors.white)
                                          .normal20())),
                              FittedBox(
                                fit: BoxFit.contain,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: ScreenUtil().setHeight(100),
                                  width: size.width * 0.7,
                                  child: Text(
                                    'Patrol Tour Report -Scanned Tags Patrol Tour Report -Scanned Tags Patrol Tour Report -Scanned Tags Patrol Tour Report -Scanned Tags Patrol Tour Report -Scanned Tags Patrol Tour Report -Scanned Tags',
                                    style: FCITextStyle(color: Colors.white)
                                        .normal11(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setHeight(5)),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xfff1f1f1), width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(10)),
                                width: MediaQuery.of(context).size.width * 0.70,
                                height: ScreenUtil().setHeight(50),
                                child: TextField(
                                  controller: nameController,
//                                enabled: enabled,
                                  //focusNode: focusNode,
//                                onSubmitted: (value) {},
                                  autofocus: false,
//                                obscureText: obscure ? true : false,
                                  style: FCITextStyle(color: Colors.white)
                                      .normal18(),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "incidentname".tr(),
                                    hintStyle: FCITextStyle(
                                            color: nameerror
                                                ? Colors.red
                                                : Colors.white)
                                        .normal18(),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: ScreenUtil().setHeight(5)),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xfff1f1f1), width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(10)),
                                width: MediaQuery.of(context).size.width * 0.70,
                                height: ScreenUtil().setHeight(100),
                                child: TextField(
                                  controller: descController,
//                                enabled: enabled,
                                  // focusNode: focusNode,
//                                onSubmitted: (value) {},
                                  minLines: 2,
                                  maxLines: 5,
                                  autofocus: false,
                                  style: FCITextStyle(color: Colors.white)
                                      .normal18(),
//                                obscureText: obscure ? true : false,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "description".tr(),
                                    hintStyle: FCITextStyle(
                                            color: descerror
                                                ? Colors.red
                                                : Colors.white)
                                        .normal18(),
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: ScreenUtil().setHeight(5)),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xfff1f1f1), width: 1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenUtil().setWidth(5)),
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
//                                height: ScreenUtil().setHeight(50),
                                  child: Stack(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical:
                                                ScreenUtil().setHeight(15),
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical:
                                                    ScreenUtil().setHeight(10)),
                                            height: ScreenUtil().setHeight(
                                                photos.length > 5
                                                    ? 100 + (100 * .4)
                                                    : 100),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Wrap(
                                                spacing: 6,
                                                direction: Axis.horizontal,
                                                runSpacing:
                                                    5, // gap between lines
                                                children: <Widget>[
                                                  ...photos
                                                      .map((tag) => Container(
                                                            width: ScreenUtil()
                                                                .setWidth(60),
                                                            height: ScreenUtil()
                                                                .setHeight(60),
                                                            child: Stack(
                                                              children: [
                                                                Positioned(
                                                                    top: -3,
                                                                    right: -3,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        photos.remove(
                                                                            tag);
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        color:
                                                                            buttonAdd,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    )),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              ScreenUtil().setHeight(5)),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Color(
                                                                            0xfff1f1f1),
                                                                        width:
                                                                            1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          ScreenUtil()
                                                                              .setWidth(2)),
                                                                  width: ScreenUtil()
                                                                      .setWidth(
                                                                          50),
                                                                  height: ScreenUtil()
                                                                      .setHeight(
                                                                          50),
                                                                  child: Image
                                                                      .file(
                                                                    tag,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    width: ScreenUtil()
                                                                        .setWidth(
                                                                            50),
                                                                    height: ScreenUtil()
                                                                        .setHeight(
                                                                            50),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ))
                                                      .toList(),
                                                ],
                                              ),
                                            ),
                                          )),
                                      Positioned(
                                          bottom: 5,
                                          right: 0,
                                          child: Transform.rotate(
                                            angle: 40,
                                            child: FloatingActionButton(
                                              backgroundColor:
                                                  buttonAdd.withOpacity(.3),
                                              // mini: true,
                                              onPressed: () {},
                                              child: IconButton(
                                                onPressed: loadAssets,

                                                // mini: true,
                                                //backgroundColor: buttonAdd,
                                                icon: Icon(
                                                  Icons.attachment_outlined,
                                                  color: buttonAdd,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ))
                                    ],
                                  )),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              StaggerAnimation(
                                titleButton: "createlog".tr(),
                                foreground: Colors.white,
                                context: context,
                                background: primaryColor,
                                buttonController:
                                    _incidentButtonController!.view,
                                onTap: () async {
                                  if (valid()) {
                                    _playAnimation();
                                    IncidentsData incidentsData =
                                        new IncidentsData(
                                            description: descController.text,
                                            name: nameController.text,
                                            photos: photos);
                                    await Provider.of<PostProvider>(context,
                                            listen: false)
                                        .sendIncidents(incidentsData)
                                        .then((value) {
                                      if (value != null && value != false) {
                                        showMessage(context, 'Success',
                                            '${value["message"]}', true);
                                        setState(() {
                                          nameController.text = '';
                                          descController.text = '';
                                          photos.clear();
                                        });
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      nameerror = true;
                                      descerror = true;
                                    });
                                  }
                                  _stopAnimation();
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ]),
        ),
      ),
    );
  }

  bool valid() {
    if (nameController.text.isNotEmpty && descController.text.isNotEmpty)
      return true;
    return false;
  }

  Future<void> loadAssets() async {
    /* FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      photos = result.paths.map((path) => File(path)).toList();
    } else {
      // User canceled the picker
    }*/
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FloatingActionButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            var image = await ImagePicker.platform
                                .pickImage(source: ImageSource.camera);
                            if (image != null) photos.add(File(image.path));
                          },
                          backgroundColor: Color(0xffd3396d),
                          child: Icon(
                            Icons.camera_alt,
                            size: 35,
                          )),
                      FloatingActionButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            var image = await ImagePicker.platform
                                .pickImage(source: ImageSource.gallery);
                            if (image != null) photos.add(File(image.path));
                          },
                          backgroundColor: Color(0xffac44cf),
                          child: Icon(
                            Icons.image,
                            size: 35,
                          )),
                    ],
                  ),
                ),
              ],
            ));
    /* List<Asset> images = [];
    String _error = 'No Error Dectected';
    List<Asset> resultList = [];
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 100,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "Fatto",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#293e52",
          actionBarTitle: "CheckPoint",
          allViewTitle: "AllPhotos".tr(),
          useDetailsView: false,
          startInAllView: true,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
    for (Asset asset in resultList) {
      print('ident ${asset.identifier}');
      final filePath =
          await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
      photos.add(File(filePath));
    }*/
  }
}
