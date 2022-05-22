import 'dart:io';

import 'package:checkpoint/chat/message_model.dart';
import 'package:http/http.dart' as http;

import 'base_api.dart';

class ConversationService extends BaseApi {
  Future<http.Response> getConversations() async {
    return await api.httpGet('conversations');
  }

  Future<http.Response> storeConversations(MessageModal message) async {
    return await api.httpPost('conversations', {
      'message': message.body,
      'type': '0',
      'user_id': message.userId.toString()
    });
  }

  Future<http.Response> storeMessage(MessageModal message) async {
    return await api.httpPost('messages', {
      'body': message.body,
      'type': '${message.type}',
      'conversation_id': message.conversationId.toString()
    });
  }

  Future<http.Response> readMessage(int id) async {
    return await api.httpPost('conversations/read', {'conversation_id': '$id'});
  }

  Future<http.Response> storeMessageImage(
      MessageModal message, File file) async {
    return await api.httpPostWithFileChat('messages',
        file: file, message: message);
  }
}
