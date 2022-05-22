import 'dart:convert';

import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:checkpoint/chat/search_page.dart';
import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/conversation_provider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/ui/Home.dart';
import 'package:checkpoint/ui/Tasks.dart';
import 'package:checkpoint/widget/background.dart';
//import 'package:connectivity/connectivity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'conversation_model.dart';
import 'message_model.dart';
import 'messages.dart';

class Contacts extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Contacts> with WidgetsBindingObserver {
  ///*************************
  ///  Variables
  TextEditingController searchText = TextEditingController();
  AnimationController? _sendButtonController;
  bool isLoading = false;
  UserData userprofile = new UserData();

  ///  **********************

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  ///**************************
  /// TabController

  // [{"id":2,"role_id":2,"name":"mohamed","phone":"01113985706","email":"mohamed4shim@gmail.com","avatar":"users\/default.png","fcm_token":"vghfhfhghhfhgd","email_verified_at":null,"settings":[],"created_at":"2021-06-06T10:55:27.000000Z","updated_at":"2021-06-06T12:34:51.000000Z"},{"id":3,"role_id":2,"name":"montaser hatem","phone":"01113985706","email":"mont@admin.com","avatar":"users\/default.png","fcm_token":null,"email_verified_at":null,"settings":[],"created_at":"2021-06-09T20:31:17.000000Z","updated_at":"2021-06-09T20:31:17.000000Z"}]
  ///***********************
  // List<SupervisorsData> supervisorData;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  UserData user = new UserData();
  AppLifecycleState? _notification;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        handleBackground();
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        // refresh();
        break;
    }
  }

  handleBackground() async {
    bool test = await APICacheManager().isAPICacheKeyExist('back_notify');
    if (test) {
      var temp = await APICacheManager().getCacheData('back_notify');
      if (temp != null) {
        var data = jsonDecode(temp.syncData);
        for (var m in data) {
          if (m['group'] != null) {
          } else {
            if (m['message'] != null) {
              var messageJson = json.decode(m['message']);
              var message = MessageModal.fromJson(messageJson);
              await Provider.of<ConversationProvider>(context, listen: false)
                  .addMessageToConversation(
                      message.conversationId!, message, true);
            }
          }
        }
        //  handleNotification(data);

      }
      APICacheManager().deleteCache('back_notify');
    }
  }

  refresh() async {
    await Provider.of<ConversationProvider>(context, listen: false)
        .concersations
        .clear;
    await Provider.of<ConversationProvider>(context, listen: false)
        .getConversations();
  }

  @override
  void initState() {
    FlutterAppBadger.removeBadge();
    WidgetsBinding.instance.addObserver(this);

    //setData();
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      // FlutterAppBadger.updateBadgeCount(1);
      print('coms1}');
      FlutterAppBadger.removeBadge();
      if (event.data['task'] != null)
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Tasks()));
    });

    FirebaseMessaging.onBackgroundMessage((message) async {
      print('coms2 ');
      handleNotification(message.data);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FlutterAppBadger.updateBadgeCount(1);
      print('coms ${message.data}');
      handleNotification(message.data);
      if (message.notification != null) {
        print('yeeeees ${message.notification}');
      }
    });
//    initConnectivity();
//    _connectivitySubscription =
//        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _firebaseMessaging.getToken().then((token) {
      // _firebaseMessaging.subscribeToTopic('group1');
      // print(token);
      if (token != null)
        Provider.of<AuthProvider>(context, listen: false).setFcmToken(token);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ConversationProvider>(context, listen: false)
          .getConversations();
//    await Provider.of<ConversationProvider>(context, listen: false)
//        .concersations.clear();
      await Provider.of<AuthProvider>(context, listen: false)
          .getUserData()
          .then((value) {
        if (value != null) {
          userprofile = value;
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    AuthProvider().dispose();
    ConversationProvider().dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    var provider = Provider.of<ConversationProvider>(context, listen: true);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Background(
          show: false,
          child: SingleChildScrollView(
            child: Column(
                // shrinkWrap: true,
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      height: size.height * 0.20,
                      width: size.width * 0.9,
                      padding:
                          EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            //  crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.home,
                                    color: Colors.white,
                                    size: ScreenUtil().setSp(35),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => Home()),
                                        (Route<dynamic> route) => false);
                                  }),
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
                                    style: FCITextStyle(color: Colors.white)
                                        .bold30(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(25),
                              )
                            ],
                          ),
                          Container(
                            child: Text(
                              'Chat',
                              style: FCITextStyle(color: Colors.white).bold22(),
                            ),
                          )
                        ],
                      )),
                  Container(
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
                    //  height: size.height / 4 - ScreenUtil().setHeight(15),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20),
                        vertical: ScreenUtil().setHeight(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(15),
                              vertical: ScreenUtil().setHeight(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(10),
                              // vertical: ScreenUtil().setHeight(15),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                              color: Colors.grey.shade200,
                            ),
                            child: TextFormField(
                              controller: searchText,
                              //  textAlign: TextAlign.center,
                              onSaved: (val) {},
                              decoration: new InputDecoration(
                                hintText: 'search'.tr(),
                                //hintStyle:
                                //   getTextStyles.textStyleLightGreyNormal16,
                                // labelStyle:
                                // getTextStyles.textStyleBlackNormal18,
                                border: InputBorder.none,
                                suffixIcon: Icon(
                                  Icons.search,
                                  size: ScreenUtil().setSp(30),
                                  color: Colors.black45,
                                ),
                              ),
                              // onChanged: onSearchTextChanged,
                            ),
                          ),
                          Container(
                            //   height: size.height * 3 / 4 - ScreenUtil().setHeight(15),
                            child:

                                ///********************
                                ///    Taps
                                ///********************
                                SizedBox(
                              height: size.height,
                              width: size.width,
                              child: Column(
                                children: <Widget>[
                                  provider.concersations != null
                                      ? provider.concersations.length > 0
                                          ? ListView.builder(
                                              physics: ClampingScrollPhysics(),
                                              itemCount: searchText
                                                      .text.isNotEmpty
                                                  ? provider.concersations
                                                      .where((element) =>
                                                          element.user!.name!
                                                              .contains(
                                                                  searchText
                                                                      .text))
                                                      .length
                                                  : provider
                                                      .concersations.length,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return InkWell(
                                                  onTap: () {
                                                    if (provider.concersations
                                                            .length >
                                                        0)
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Messages(
                                                                        data: provider.concersations.length >
                                                                                0
                                                                            ? provider.concersations[index]
                                                                            : null,
                                                                        myId: userprofile
                                                                            .id,
                                                                      ))).then(
                                                          (value) async {
//                                         await  Provider.of<ConversationProvider>(context, listen: false)
//                                              .getConversationsOffline();
                                                      });
                                                  },
                                                  child: provider
                                                              .concersations[
                                                                  index]
                                                              .user !=
                                                          null
                                                      ? messageWidget(provider
                                                          .concersations[index])
                                                      : Container(),
                                                );
                                              })
                                          : provider.busy
                                              ? CircularProgressIndicator()
                                              : Center(
                                                  child: Text('empty'.tr()))
                                      : Container(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () async {
            //  List<ConversationModel> conversation=await provider.concersations.toList();

            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchPage(
                          conversationModel: provider.concersations,
                        ))).then((value) {
              provider.concersations.clear();
              provider.getConversations();
            });
          }, // Switch tabs
          child: new Icon(Icons.person_add_alt_1_rounded,
              size: ScreenUtil().setSp(33), color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  messageWidget(ConversationModel conversationModel) {
    return Container(
        //   width: Size.infinite.width,
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(10),
                vertical: ScreenUtil().setHeight(0),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(10),
                          vertical: ScreenUtil().setHeight(5),
                        ),
                        height: ScreenUtil().setWidth(70),
                        width: ScreenUtil().setWidth(70),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: conversationModel.groupTitle != null
                                ? Image.asset(
                                    'assets/images/logo2.png',
                                    fit: BoxFit.contain,
                                  )
                                : CachedNetworkImage(
                                    //  height: ScreenUtil().setHeight(50),
                                    // width: ScreenUtil().setWidth(50),
                                    imageUrl:
                                        conversationModel.user?.image ?? '',
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Image.asset(
                                      'assets/images/defult_profile.png',
                                      fit: BoxFit.contain,
                                    ),
//                                                progressIndicatorBuilder: (context, url, downloadProgress) =>
//                                                    CircularProgressIndicator(value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/defult_profile.png',
                                      fit: BoxFit.contain,
                                    ),
                                  )),
                      ),
                      /*  if(conversationModel..online)Positioned(
                              top: 7,
                              right: 30,
                              child: Icon(
                                Icons.circle,
                                size: ScreenUtil().setSp(15),
                                color: Colors.greenAccent,
                              )),*/
                      if (conversationModel != null)
                        if (conversationModel.unread != null)
                          if (conversationModel.unread! > 0)
                            Positioned(
                                bottom: 0,
                                right: 30,
                                child: Center(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: ScreenUtil().setHeight(20),
                                    height: ScreenUtil().setHeight(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                      color: Color(0xff293e52),
                                    ),
                                    child: Text('${conversationModel.unread}',
                                        style: FCITextStyle(color: Colors.white)
                                            .normal13()),
                                  ),
                                )),
                      Positioned(
                          top: ScreenUtil().setHeight(8),
                          right: ScreenUtil().setWidth(15),
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenUtil().setWidth(15),
                            height: ScreenUtil().setWidth(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              color: Colors.green,
                            ),
                          ))
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${conversationModel.user?.name}',
                        style: FCITextStyle().normal18(),
                      ),
                      conversationModel
                                  .messages![
                                      conversationModel.messages!.length - 1]
                                  .type ==
                              0
                          ? Text(
                              conversationModel
                                          .messages![conversationModel
                                                  .messages!.length -
                                              1]
                                          .body!
                                          .length >
                                      30
                                  ? '${conversationModel.messages![conversationModel.messages!.length - 1].body!.substring(0, 30)}...'
                                  : '${conversationModel.messages![conversationModel.messages!.length - 1].body}',
                              style: FCITextStyle().normal16())
                          : Text(
                              'Media Message',
                            )
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                //vertical: ScreenUtil().setHeight(10),
              ),
              child: Row(
                children: [
                  if (conversationModel
                          .messages![conversationModel.messages!.length - 1]
                          .userId !=
                      conversationModel.user!.id)
                    Icon(
                      Icons.done,
                      size: ScreenUtil().setSp(17),
                      color: conversationModel
                                  .messages![
                                      conversationModel.messages!.length - 1]
                                  .read ==
                              1
                          ? Color(0xff293e52)
                          : Colors.grey,
                    ),
//                        Text(timeago.format(DateTime.parse(
//                            conversationModel.messages[conversationModel.messages.length-1].createdAt),locale:
//                        EasyLocalization.of(context).locale.languageCode),
//                          style: TextStyle(
//                            color: Colors.grey,
//                            fontSize: 12.0,
//                          ),),
                  Text(
                    '${getTimeFromDate(DateTime.parse(conversationModel.messages![conversationModel.messages!.length - 1].createdAt!))}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
              right: EasyLocalization.of(context)!.locale.languageCode == 'ar'
                  ? ScreenUtil().setWidth(80)
                  : ScreenUtil().setWidth(30),
              left: EasyLocalization.of(context)!.locale.languageCode == 'en'
                  ? ScreenUtil().setWidth(80)
                  : ScreenUtil().setWidth(10)),
          /* child: Divider(
            color: Colors.black,
            thickness: .5,
          ),*/
        )
      ],
    ));
  }

  var focusNode = FocusNode();

  void _showScaffold(String message) {
    _scaffoldKey.currentState!.showSnackBar(SnackBar(
      backgroundColor: Colors.blueAccent,
      duration: Duration(milliseconds: 1500),
      content: Text(message,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0)),
    ));
  }

  getTimeFromDate(DateTime? dateTime) {
    return "${dateTime?.hour}:${dateTime?.minute}";
  }

  handleNotification(data) async {
    if (data['group'] != null) {
      Provider.of<ConversationProvider>(context, listen: false)
          .concersations
          .clear();
      await Provider.of<ConversationProvider>(context, listen: false)
          .getConversations();
    } else {
      var messageJson = json.decode(data['message']);
      var message = MessageModal.fromJson(messageJson);
      Provider.of<ConversationProvider>(context, listen: false)
          .addMessageToConversation(message.conversationId!, message, true);
    }
  }
}

//////////////////////
