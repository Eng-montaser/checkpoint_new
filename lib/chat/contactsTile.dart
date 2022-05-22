import 'dart:convert';

import 'package:checkpoint/provider/conversation_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message_model.dart';

class ContactTile extends StatefulWidget {
  final MessageModal message;
  final int userId;
  final String? userName;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const ContactTile(
      {Key? key,
      required this.userId,
      required this.message,
      this.userName,
      this.scaffoldKey})
      : super(key: key);

  @override
  _ContactTileState createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  bool isload = false;
  bool _isJoined = false;
  void _showScaffold(String message) {
    widget.scaffoldKey?.currentState?.showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(milliseconds: 1500),
      content: Text(message,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
              '${widget.userName?.substring(0, 1)?.toUpperCase() ?? ''}',
              style: TextStyle(color: Colors.white))),
      title: Text('${widget.userName}',
          style: TextStyle(fontWeight: FontWeight.bold)),
      // subtitle: Text("Admin: $admin"),
      trailing: InkWell(
        onTap: () async {
          if (!_isJoined) {
            widget.message.body = 'يعطيك العافية اخى الكريم';
            widget.message.userId = widget.userId;
            setState(() {
              isload = true;
            });
            await Provider.of<ConversationProvider>(context, listen: false)
                .storeConversation(widget.message)
                .then((value) {
              isload = false;

              if (value.statusCode == 201) {
                _showScaffold('invited'.tr());
                _isJoined = true;
              } else {
                var data = jsonDecode(value.body);
                _showScaffold('${data['message']}');
              }
            });
          }
        },
        child: isload
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.red,
                ),
              )
            : _isJoined
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey,
                        border: Border.all(color: Colors.white, width: 1.0)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Text('invited'.tr(),
                        style: TextStyle(color: Colors.white)),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).primaryColor,
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Text('invite'.tr(),
                        style: TextStyle(color: Colors.white)),
                  ),
      ),
    );
  }
}
