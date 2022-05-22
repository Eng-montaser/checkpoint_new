import 'package:checkpoint/model/UserData.dart';

import 'message_model.dart';

class ConversationModel {
  int? id;
  UserData? user;
  int? unread;
  String? createdAt;
  String? groupTitle;
  List<MessageModal>? messages;

  ConversationModel(
      {this.id,
      this.user,
      this.createdAt,
      this.messages,
      this.groupTitle,
      this.unread = 0});

  ConversationModel.fromJson(Map<String, dynamic> json) {
    if (json['group_title'] != null) {
      id = json['id'];
      unread = json['unread_messages'];
      groupTitle = json['group_title'];
      user = json['user'] != null
          ? new UserData.fromSearchJson(json['user'])
          : null;
      createdAt = json['created_at'];
      if (json['messages'] != null) {
        messages = [];
        json['messages'].forEach((v) {
          messages!.add(new MessageModal.fromJson(v));
        });
      }
    } else {
      id = json['id'];
      groupTitle = null;
      unread = json['unread_messages'];
      user = json['user'] != null
          ? new UserData.fromSearchJson(json['user'])
          : null;
      createdAt = json['created_at'];
      if (json['messages'] != null) {
        messages = [];
        json['messages'].forEach((v) {
          messages!.add(new MessageModal.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      ///data['user'] = this.user.toJson();
    }
    data['created_at'] = this.createdAt;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
