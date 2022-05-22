import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:checkpoint/chat/play_sound.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'full_photo.dart';
import 'message_model.dart';

class BuildItem extends StatefulWidget {
  final MessageModal? document;
  final int? myId;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const BuildItem({
    Key? key,
    this.document,
    this.myId,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  _ContactTileState createState() => _ContactTileState();
}

class _ContactTileState extends State<BuildItem> {
  @override
  Widget build(BuildContext context) {
    return Container(child: buildItem(widget.document!));
  }

  Widget buildItem(MessageModal document) {
    if (document.userId != widget.myId) {
      // Right (my message)
      ////print( _isChecked[index]);

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${document.sender_name}',
                style:
                    FCITextStyle().bold16().copyWith(color: Colors.lightBlue),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: ScreenUtil().setWidth(50),
              ),
              getMssageWidget(document)
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  getTimeFromDate(DateTime.parse(document.createdAt!)),
                  style: TextStyle(
                    // color: lightGrey,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.only(right: 50.0, bottom: 5.0),
          )
        ],
      );
    } else {
      // Left (peer message)
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              getMssageWidget(document),
              SizedBox(
                width: ScreenUtil().setWidth(50),
              ),
            ],
          ),

          // Time
          Container(
            child: Row(
              children: [
                Icon(
                  document.read == 2 ? Icons.watch_later_outlined : Icons.done,
                  color: document.read == 1 ? Color(0xff293e52) : Colors.grey,
                  size: 18,
                ),
                Text(
                  getTimeFromDate(DateTime.parse(document.createdAt!)),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
  }

  Widget getMssageWidget(MessageModal message) {
    switch (message.type) {
      case 0:
        return Flexible(
          child: Container(
            //  width: MediaQuery.of(context).size.width * 3 / 4,
            child: InkWell(
              onLongPress: () {
                _copyToClipboard(removeAllHtmlTags(message.body!));
              },
              child: Text(
                  //document.message,
                  '${removeAllHtmlTags(message.body!)}',
                  style: FCITextStyle(color: Colors.white).normal14()),
            ),
            padding: EdgeInsets.all(10),
            //  width: 200.0,
            decoration: BoxDecoration(
                color: Color(0xff293e52),
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.only(left: 10.0),
          ),
        );
        break;
      case 1:
        return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: message.read != 2
                ? InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FullPhoto(url: message.path!)));
                    },
                    child: CachedNetworkImage(
                      height: ScreenUtil().setHeight(100),
                      width: ScreenUtil().setWidth(100),
                      imageUrl: message.path ?? '/',
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/place.png',
                        fit: BoxFit.fill,
                        height: ScreenUtil().setHeight(100),
                        width: ScreenUtil().setWidth(100),
                      ),
//                                                progressIndicatorBuilder: (context, url, downloadProgress) =>
//                                                    CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/place.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FullPhoto(url: message.path!)));
                    },
                    child: Image.file(
                      File(message.path!),
                      height: ScreenUtil().setHeight(100),
                      width: ScreenUtil().setWidth(100),
                      fit: BoxFit.fill,
                    ),
                  ));
        break;
      case 2:
        return Container(
          child: message.read == 2
              ? getEmptySound()
              : MySoundPlayer(filePath: message.path!),
        );
      case 3:
        return Flexible(
          child: Container(
            //  width: MediaQuery.of(context).size.width * 3 / 4,
            child: Text(
                //document.message,
                '${removeAllHtmlTags(message.body!)}',
                style: FCITextStyle(color: Colors.white).normal30()),
            padding: EdgeInsets.all(10),
            //  width: 200.0,
            decoration: BoxDecoration(
                color: Color(0xff293e52),
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.only(left: 10.0),
          ),
        );
        break;
      default:
        return Container();
    }
  }

  getTimeFromDate(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute}";
  }

  Widget getEmptySound() {
    return Row(
      children: <Widget>[
        Container(
          child: Center(
            child: FloatingActionButton(
              clipBehavior: Clip.hardEdge,
              backgroundColor: Color(0xff293e52),
              elevation: 1,
              onPressed: () {},
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        Container(
            child: Slider(
                value: 0,
                min: 0.0,
                max: 100,
                activeColor: Color(0xff293e52),
                inactiveColor: Color(0xff293e52).withOpacity(.2),
                onChanged: (double value) async {},
                divisions: 1)),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    widget.scaffoldKey?.currentState?.showSnackBar(SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }
}
