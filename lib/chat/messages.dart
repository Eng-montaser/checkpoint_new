import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:checkpoint/provider/conversation_provider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/widget/sound_recorder.dart';
import 'package:easy_localization/easy_localization.dart' as T;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
//import 'package:easy_localization/easy_localization.dart';
//import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import 'builditem.dart';
import 'conversation_model.dart';
import 'message_model.dart';

class Messages extends StatefulWidget {
  final ConversationModel? data;
  final int? myId;
  const Messages({Key? key, this.data, this.myId}) : super(key: key);
  @override
  _Messages createState() => _Messages(this.data!);
}

class _Messages extends State<Messages> {
  bool animat = false;
  FocusNode focusNode = FocusNode();
  final ConversationModel conversation;
  TextEditingController searchText = new TextEditingController();
  bool showSearch = false, showSound = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TextEditingController messageTextEditController = TextEditingController();
  int notify = 0;
  _Messages(
    this.conversation,
  );
  bool isLoading = false, showEmoji = false;

  int _limit = 20;
  final int _limitIncrement = 20;

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  GroupedItemScrollController _scrollController = GroupedItemScrollController();
  final globalScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showEmoji = false;
        });
      }
    });
    //  WidgetsBinding.instance.addObserver(this);
    conversation.unread = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      animat = true;
      _scrollController.scrollTo(
          index: conversation.messages!.length - 1,
          duration: Duration(milliseconds: 500),
          automaticAlignment: false);
      readMSG(conversation.id!);
      FirebaseMessaging.onMessage.listen((event) {
        var data = json.decode(event.data['message']);
        var notimessage = MessageModal.fromJson(data);
        {
          if (notimessage.conversationId == conversation.id) {
            _scrollController.scrollTo(
                index: conversation.messages!.length - 1,
                duration: Duration(milliseconds: 500),
                automaticAlignment: false);
          } else
            notify = notify + 1;
        }
      });
    });
  }

  @override
  void dispose() {
    //  WidgetsBinding.instance.removeObserver(this);

    itemPositionsListener.itemPositions.removeListener(() {});
    messageTextEditController.dispose();
    searchText.dispose();

    super.dispose();

    //UserProvider().dispose();
    ConversationProvider().dispose();
  }

  Future uploadSound(String path, bool status) async {
    setState(() {
      showSound = false;
    });
    if (status) {
      setState(() {
        isLoading = true;
        showSound = false;
      });
      //print('lara1 $path');
      File sound = await File(path);
      MessageModal message = MessageModal();
      message.conversationId = conversation.id;
      message.type = 2;
      message.read = 2;
      message.path = path;
      message.userId = widget.myId;
      message.createdAt = DateTime.now().toIso8601String();
      messageTextEditController.clear();
      // print('adam ${basename(sound.path)}');

      await Provider.of<ConversationProvider>(context, listen: false)
          .uploadSound(message, sound);
      messageTextEditController.clear();
      _scrollController.scrollTo(
          index: conversation.messages!.length + 10,
          duration: Duration(milliseconds: 500),
          automaticAlignment: false);
      setState(() {
        isLoading = false;
      });
    }
  }

  _onBackspacePressed() {
    messageTextEditController
      ..text = messageTextEditController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageTextEditController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.white),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: profilebar(),
        body: WillPopScope(
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = false;
              });
            } else
              Navigator.pop(context);
            return Future.value(false);
          },
          child: Column(
            children: [
              if (showSearch)
                TranslationAnimatedWidget.tween(
                  enabled: this.animat,
                  duration: Duration(milliseconds: 300),
                  translationDisabled: Offset(0, -50),
                  translationEnabled: Offset(0, 0),
                  child: OpacityAnimatedWidget.tween(
                    enabled: this.animat,
                    opacityDisabled: 0,
                    opacityEnabled: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20),
                        //vertical: ScreenUtil().setHeight(10),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(15),
                            vertical: ScreenUtil().setHeight(5)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Colors.grey[300],
                        ),
                        child: TextFormField(
                          controller: searchText,
                          //  textAlign: TextAlign.center,
                          onSaved: (val) {},
                          decoration: new InputDecoration(
                            hintText: 'search'.tr(),
                            hintStyle: FCITextStyle(color: Colors.grey[200])
                                .normal16(),
                            labelStyle: FCITextStyle().normal18(),
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
                    ),
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.only(bottom: ScreenUtil().setHeight(60)),
                      child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              showEmoji = false;
                              focusNode.unfocus();
                              focusNode.canRequestFocus = false;
                            });
                          },
                          child: buildListMessage()),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildInput(),
                              Offstage(
                                offstage: !showEmoji,
                                child: SizedBox(
                                  height: 250,
                                  child: EmojiPicker(
                                      onEmojiSelected:
                                          (Category category, Emoji emoji) {
                                        /*messageTextEditController.text =
                                            messageTextEditController.text +
                                                emoji.name;*/
                                        messageTextEditController
                                          ..text += emoji.emoji
                                          ..selection = TextSelection
                                              .fromPosition(TextPosition(
                                                  offset:
                                                      messageTextEditController
                                                          .text.length));
                                      },
                                      onBackspacePressed: _onBackspacePressed,
                                      config: Config(
                                          columns: 7,
                                          // Issue: https://github.com/flutter/flutter/issues/28894
                                          emojiSizeMax: 32 *
                                              (Platform.isIOS ? 1.30 : 1.0),
                                          verticalSpacing: 0,
                                          horizontalSpacing: 0,
                                          initCategory: Category.RECENT,
                                          bgColor: const Color(0xFFF2F2F2),
                                          indicatorColor: Colors.blue,
                                          iconColor: Colors.grey,
                                          iconColorSelected: Colors.blue,
                                          progressIndicatorColor: Colors.blue,
                                          backspaceColor: Colors.blue,
                                          skinToneDialogBgColor: Colors.white,
                                          skinToneIndicatorColor: Colors.grey,
                                          enableSkinTones: true,
                                          showRecentsTab: true,
                                          recentsLimit: 28,
                                          /*noRecentsText:  Text(
                                            'No Recents',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black26),
                                            textAlign: TextAlign.center,
                                          ),*/
                                          tabIndicatorAnimDuration:
                                              kTabScrollDuration,
                                          categoryIcons: const CategoryIcons(),
                                          buttonMode: ButtonMode.MATERIAL)),
                                ),
                              ),
                              // if (showEmoji)
                              /* Offstage(
                                offstage: showEmoji,
                                child: EmojiPicker(
                                  // rows: 3,
                                  // columns: 7,
                                  // bgColor: Color(0xff293e52),
                                  // recommendKeywords: ["grinning", "face"],
                                  // numRecommended: 10,
                                  config: Config(
                                    columns: 7,
                                    bgColor: Color(0xff293e52),
                                  ),
                                  onEmojiSelected: (emoji, category) {
                                    messageTextEditController.text =
                                        messageTextEditController.text +
                                            emoji.name;
                                  },
                                ),
                              )*/
                            ],
                          ),
                        )),
                  ], // ListView.builder(itemBuilder: (context,index)=>buildItems(),
                  // itemCount: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItems() {
    return Center(
      child: Text('Messages'),
    );
  }

  AppBar profilebar() {
    return AppBar(
      toolbarHeight: ScreenUtil().setHeight(100),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: InkWell(
        onTap: () {
          /*Provider.of<UserProvider>(context, listen: false)
              .setStatus("offline");*/
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(7)),
          padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setHeight(5),
              horizontal: ScreenUtil().setWidth(5)),
          margin: EdgeInsets.symmetric(
              vertical: ScreenUtil().setHeight(35),
              horizontal: ScreenUtil().setWidth(10)),
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.black,
            size: ScreenUtil().setSp(20),
          ),
        ),
      ),
      title: Container(
        height: ScreenUtil().setHeight(80),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
                // margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(15)),
//                padding: EdgeInsets.only(left: T.EasyLocalization.of(context).currentLocale.languageCode=='ar'? ScreenUtil().setWidth(10):ScreenUtil().setWidth(10),
//                    right: T.EasyLocalization.of(context).currentLocale.languageCode=='ar'? ScreenUtil().setWidth(10):ScreenUtil().setWidth(60)),
                decoration: BoxDecoration(
                    color: Color(0xff293e52),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: conversation.groupTitle != null
                          ? Image.asset(
                              'assets/images/logo2.png',
                              fit: BoxFit.contain,
                              color: Colors.white,
                              height: ScreenUtil().setWidth(50),
                              width: ScreenUtil().setWidth(50),
                            )
                          : CachedNetworkImage(
                              height: ScreenUtil().setWidth(50),
                              width: ScreenUtil().setWidth(50),
                              imageUrl: conversation.user?.image ?? '/',
                              fit: BoxFit.fill,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/defult_profile.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(5),
                          vertical: ScreenUtil().setHeight(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              '${conversation.user?.name}',
                              style: FCITextStyle(color: Colors.white)
                                  .normal14()
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            "offline".tr(),
                            style: FCITextStyle(color: Colors.white)
                                .normal14()
                                .copyWith(fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                //  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(5),ScreenUtil().setHeight(15),0,ScreenUtil().setHeight(15)),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                          onTap: () {},
                          child: IconBadge(
                            hideZero: true,
                            right: 0,
                            top: ScreenUtil().setHeight(15),
                            onTap: () {},
                            itemCount: notify,
                            badgeColor: Colors.red,
                            icon: Icon(
                              Icons.notifications_none_sharp,
                              size: ScreenUtil().setSp(35),
                              color: Colors.black,
                            ),
                          )
                          /*Stack(children: [
                     if (notify>=0)    Positioned(
                         top: 0,
                         left: 0,
                         child: Container(
                           height: 30,
                      width: 30,
                      // padding: EdgeInsets.all(5),
                       decoration: BoxDecoration(
                         color: Colors.red
                       ),
                            child: Center(child: Text('$notify',style: TextStyle(color: Colors.white,fontSize: 9),)),
                          )),
                          Image.asset('assets/images/bell.png')
                        ],),*/

                          ),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(3),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showSearch = !showSearch;
                          });
                        },
                        child: Icon(
                          Icons.search_outlined,
                          color: Colors.black,
                          size: ScreenUtil().setSp(30),
                        ),
                      ),
                    ),
                    /*Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset("assets/images/grid.png"),
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [],
    );
  }

  Widget buildInput() {
    return Container(
      padding: EdgeInsets.all(10),
      child: showSound
          ? SimpleRecorder(
              widgetAction: uploadSound,
            )
          : Row(
              children: <Widget>[
                // Button send image
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(1)),
                    child: IconButton(
                      icon: Icon(
                          showEmoji
                              ? Icons.keyboard
                              : Icons.emoji_emotions_outlined,
                          color: Colors.black54),
                      onPressed: () {
                        showEmoji
                            ? setState(() {
                                // focusNode.canRequestFocus = true;
                                FocusScope.of(context).requestFocus(focusNode);

                                showEmoji = !showEmoji;
                              })
                            : setState(() {
                                focusNode.unfocus();
                                focusNode.canRequestFocus = false;
                                showEmoji = !showEmoji;
                              });
                      },
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.grey[200],
                ),

                // Edit text
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: TextField(
                        focusNode: focusNode,
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: (value) {
                          //   onSendMessage(textEditingController.text, 0);
                        },
                        //style: FCITextStyle(color: Colors.grey[200]).normal18(),
                        controller: messageTextEditController,

                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'message.write'.tr(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Button send message
                Material(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(8)),
                    child: messageTextEditController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.send, color: Colors.black54),
                            /*  onPressed:_recording.status==RecordingStatus.Recording?null: () =>
                          onSendMessage(textEditingController.text, 0),*/
                            onPressed: () async {
                              MessageModal message = MessageModal();
                              message.conversationId =
                                  conversation.id; //print('hell');
                              //  FocusScope.of(context).requestFocus(FocusNode());

                              if (messageTextEditController.text.isEmpty)
                                return;
                              message.body =
                                  messageTextEditController.text.trim();
                              message.type = showEmoji ? 3 : 0;
                              message.read = 2;
                              message.userId = widget.myId;
                              message.createdAt =
                                  DateTime.now().toIso8601String();
                              messageTextEditController.clear();
                              // buildItem(conversation.messages.length, message);
                              //print('adam ${message.toJson()}');
                              await Provider.of<ConversationProvider>(context,
                                      listen: false)
                                  .storeMessage(message);
                              // if(_scrollController.isAttached)
                              _scrollController.scrollTo(
                                  index: conversation.messages!.length + 10,
                                  duration: Duration(milliseconds: 500),
                                  automaticAlignment: false);

                              setState(() {
                                showEmoji = false;
                              });
                            },
                            //color: Colors.white,
                          )
                        : Row(
                            children: [
                              Material(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  ),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 1.0),
                                  child: IconButton(
                                    icon: Icon(Icons.mic),
                                    onPressed: () {
                                      setState(() {
                                        showSound = true;
                                      });
                                    },
                                    color: Colors.black54,
                                  ),
                                ),
                                //  color: Colors.white,
                              ),
                              IconButton(
                                icon: Icon(CupertinoIcons.camera,
                                    color: Colors.black54),
                                /*  onPressed:_recording.status==RecordingStatus.Recording?null: () =>
                          onSendMessage(textEditingController.text, 0),*/
                                onPressed: () async {
                                  var imageData = await ImagePicker.platform
                                      .pickImage(source: ImageSource.camera);
                                  MessageModal message = MessageModal();
                                  message.conversationId = conversation.id;
                                  message.type = 1;
                                  message.read = 2;
                                  message.path = imageData?.path;
                                  message.userId = widget.myId;
                                  message.createdAt =
                                      DateTime.now().toIso8601String();
                                  messageTextEditController.clear();
                                  //print('adam ${message.toJson()}');
                                  await Provider.of<ConversationProvider>(
                                          context,
                                          listen: false)
                                      .pickCamera(
                                          message, File(imageData!.path));
                                  messageTextEditController.clear();
                                  _scrollController.scrollTo(
                                      index: conversation.messages!.length + 10,
                                      duration: Duration(milliseconds: 500),
                                      automaticAlignment: false);

                                  //print('hell');
                                },
                                //color: Colors.white,
                              ),
                              IconButton(
                                icon: Icon(Icons.attach_file,
                                    color: Colors.black54),
                                /*  onPressed:_recording.status==RecordingStatus.Recording?null: () =>
                          onSendMessage(textEditingController.text, 0),*/
                                onPressed: () async {
                                  var image = await ImagePicker.platform
                                      .pickImage(source: ImageSource.gallery);
                                  MessageModal message = MessageModal();
                                  message.conversationId = conversation.id;
                                  message.type = 1;
                                  message.read = 2;
                                  message.userId = widget.myId;
                                  message.path = image!.path;
                                  message.createdAt =
                                      DateTime.now().toIso8601String();
                                  messageTextEditController.clear();
                                  //print('adam ${message.toJson()}');
                                  await Provider.of<ConversationProvider>(
                                          context,
                                          listen: false)
                                      .pickImage(message, File(image.path));
                                  messageTextEditController.clear();
                                  _scrollController.scrollTo(
                                      index: conversation.messages!.length + 10,
                                      duration: Duration(milliseconds: 500),
                                      automaticAlignment: false);
                                },
                                // color: Colors.white,
                              )
                            ],
                          ),
                  ),
                ),
              ],
            ),
      width: double.infinity,
      // height: 50.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
    );
  }

  Widget buildListMessage() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overScroll) {
        overScroll.disallowGlow();

        return false;
      },
      child: StickyGroupedListView<MessageModal, DateTime>(
        // physics: ,
        physics: AlwaysScrollableScrollPhysics(),
        elements: searchText.text.isNotEmpty
            ? conversation.messages!
                .where(
                    (element) => element.body!.contains(searchText.text.trim()))
                .toList()
            : conversation.messages!,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
        order: StickyGroupedListOrder.ASC,
        // reverse: true,
        itemPositionsListener: itemPositionsListener,
        // initialScrollIndex:conversation.messages.length-1 ,
        groupBy: (MessageModal element) =>
            DateTime.parse(element.createdAt!.split('T')[0]),
        /* groupComparator: (DateTime value1, DateTime value2) =>
            value2.compareTo(value1),*/
        itemComparator: (MessageModal element1, MessageModal element2) =>
            element1.createdAt!.compareTo(element2.createdAt!),
        floatingHeader: true,
        groupSeparatorBuilder: (MessageModal element) => Container(
          height: ScreenUtil().setHeight(50),
          child: Align(
            alignment: Alignment.center,
            child: mydivider(element),
          ),
        ),
        //  physics: ScrollPhysics(),

        itemScrollController: _scrollController,
        indexedItemBuilder: (_, MessageModal element, int index) {
          conversation.unread = 0;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: BuildItem(
                document: element,
                myId: widget.myId,
                scaffoldKey: _scaffoldKey,
              ),
            ),
          );
        },
      ),
    );

    /* ListView.builder(

            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) =>
            buildItem(index, dataSet[index]),
            itemCount: dataSet.length,
            //reverse: true,
            controller: listScrollController,
          );*/
  }

  readMSG(int conversationId) async {
    //  if(!Provider.of<ConversationProvider>(context,listen: false).busy)
    Provider.of<ConversationProvider>(context, listen: false)
        .readMessage(conversationId);
    Provider.of<ConversationProvider>(context, listen: false)
        .readOffline(conversationId);
  }

  Widget mydivider(MessageModal element) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    String datecheck = '';
    if (DateTime.parse(element.createdAt!.split('T')[0]) == today) {
      datecheck = 'today'.tr();
    } else if (DateTime.parse(element.createdAt!.split('T')[0]) == yesterday) {
      datecheck = 'yesterday'.tr();
    } else
      datecheck = '${element.createdAt!.split('T')[0]}';
    return Row(children: <Widget>[
      Expanded(
        child: new Container(
            margin: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: Divider(
              color: Colors.black,
              height: 36,
              thickness: .4,
            )),
      ),
      Text(
        datecheck,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      Expanded(
        child: new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Divider(
              color: Colors.black,
              height: 36,
              thickness: .4,
            )),
      ),
    ]);
  }
/* getTimeFromDate(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute}";
  }*/
}
/*class Element {
  DateTime date;
  String message;
  bool me;

  Element(this.date, this.message,this.me);
}*/
