import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:checkpoint/chat/conversation_model.dart';
import 'package:checkpoint/chat/message_model.dart';
import 'package:checkpoint/service/api.dart';
import 'package:checkpoint/service/conversation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_provider.dart';

class ConversationProvider extends BaseProvider {
  ConversationService _conversationService = ConversationService();
  List<ConversationModel> _concersations = [];
  List<ConversationModel> get concersations => _concersations;
  Api _api = Api();

  Future<List<ConversationModel>> getConversations() async {
    //if (_concersations.isNotEmpty) return ;
    _concersations = await getConversationsOffline();

    await getToken();
    setBusy(true);

    try {
      var response = await _conversationService.getConversations();
      // print('length &${response.body}');
      if (response.statusCode == 200) {
        _concersations = [];
        var data = jsonDecode(response.body);
        //   print('length &${data['data'][0]}');
        data['data'].forEach((conversation) =>
            _concersations.add(ConversationModel.fromJson(conversation)));
        //  _concersations=_concersations.reversed.toList();
        notifyListeners();
        setBusy(false);
        APICacheDBModel apiCacheDBModel =
            APICacheDBModel(key: 'conversations', syncData: response.body);
        await APICacheManager().addCacheData(apiCacheDBModel);
      } else if (response.statusCode == 401) {
        var data = jsonDecode(response.body);
        setMessage(data["message"]);
      } else {
        getConversationsOffline();
      }
    } catch (e) {
      setBusy(false);
    }
    setBusy(false);
    return _concersations;
  }

  Future<List<ConversationModel>> getConversationsOffline() async {
    //if (_concersations.isNotEmpty) return ;
    _concersations = [];
    setBusy(false);
    bool test = await APICacheManager().isAPICacheKeyExist('conversations');
    if (test) {
      var temp = await APICacheManager().getCacheData('conversations');
      if (temp != null) {
        var data = jsonDecode(temp.syncData);
        data['data'].forEach((conversation) =>
            _concersations.add(ConversationModel.fromJson(conversation)));
        //_concersations=_concersations.reversed.toList();
      }
    }

    // print('aaa ${_concersations.length}');
    notifyListeners();

    setBusy(false);
    return _concersations;
  }

  Future<bool> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString('access_token');
    if (token != null) {
      //_api.token = token;
      return true;
    }
    return false;
  }

  Future<void> storeMessage(MessageModal message) async {
    addMessageToConversation(message.conversationId!, message, false);
    notifyListeners();
    setBusy(true);
    try {
      Timer(Duration(milliseconds: 100), () async {
        var response = await _conversationService.storeMessage(message);
        print('sss ${response.body}');
        if (response.statusCode == 201) {
          var data = jsonDecode(response.body);
          setBusy(false);
          var conversation = _concersations.firstWhere(
              (conversation) => conversation.id == message.conversationId);
          int index = conversation.messages!.indexOf(message);
          conversation.messages!.removeAt(index);

//      message.read = data['data']['id'];
          addMessageToConversation(message.conversationId!,
              MessageModal.fromJson(data['data']), true);
          notifyListeners();
        }
      });
    } catch (e) {
      print('zaza $e');
    }

    setBusy(false);
  }

  Future<void> readMessage(int id) async {
    setBusy(true);
    var response = await _conversationService.readMessage(id);
    //print('kkk ${response.body}');

    setBusy(false);
  }

  Future<dynamic> pickImage(MessageModal message, File image) async {
    addMessageToConversation(message.conversationId!, message, false);
    notifyListeners();
    setBusy(true);
    // return;
    Timer(Duration(milliseconds: 100), () async {
      var response =
          await _conversationService.storeMessageImage(message, image);
      print('nnn ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        //print(data);
        var data = jsonDecode(response.body);
        //print(_user.toJson());
        setBusy(false);
        var conversation = _concersations.firstWhere(
            (conversation) => conversation.id == message.conversationId);
        int index = conversation.messages!.indexOf(message);
        conversation.messages!.removeAt(index);
        addMessageToConversation(
            message.conversationId!, MessageModal.fromJson(data['data']), true);
        notifyListeners();
        //return image;
      }
    });
    return image;
  }

  Future<dynamic> uploadSound(MessageModal message, File sound) async {
    addMessageToConversation(message.conversationId!, message, false);
    notifyListeners();
    setBusy(true);
    // return;
    Timer(Duration(milliseconds: 100), () async {
      var response =
          await _conversationService.storeMessageImage(message, sound);
      print('zzz ${response.body}');
      var data = jsonDecode(response.body);
      //  {"data":{"id":44,"body":"images\/messages\/103_1633993071_flutter_sound.mp4","read":false,"type":2,"path":"http:\/\/check-points.fsdmarketing.com\/storage\/images\/messages\/103_1633993071_flutter_sound.mp4","user_id":103,"user_name":"montaser","sender_name":"montaser","conversation_id":1,"created_at":"2021-10-11T22:57:51.000000Z"}}
      // {"data":{"id":46,"body":"images\/messages\/103_1633993302_b392c89e-e723-4b52-936c-cd1aadc60561364230930.jpg","read":false,"type":1,"path":"http:\/\/check-points.fsdmarketing.com\/storage\/images\/messages\/103_1633993302_b392c89e-e723-4b52-936c-cd1aadc60561364230930.jpg","user_id":103,"user_name":"montaser","sender_name":"montaser","conversation_id":1,"created_at":"2021-10-11T23:01:42.000000Z"}}
      if (response.statusCode == 201) {
        //print(data);
        var data = jsonDecode(response.body);
        //print(_user.toJson());
        setBusy(false);
        var conversation = _concersations.firstWhere(
            (conversation) => conversation.id == message.conversationId);
        int index = conversation.messages!.indexOf(message);
        conversation.messages!.removeAt(index);
        addMessageToConversation(
            message.conversationId!, MessageModal.fromJson(data['data']), true);
        notifyListeners();
        // return sound;
      }
    });
    return sound;
  }

  Future<dynamic> pickCamera(MessageModal message, File image) async {
    addMessageToConversation(message.conversationId!, message, false);
    notifyListeners();
    setBusy(true);
    // return;
    Timer(Duration(milliseconds: 100), () async {
      var response =
          await _conversationService.storeMessageImage(message, image);
      print('zzz ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        //print(data);
        var data = jsonDecode(response.body);
        //print(_user.toJson());
        setBusy(false);
        var conversation = _concersations.firstWhere(
            (conversation) => conversation.id == message.conversationId);
        int index = conversation.messages!.indexOf(message);
        conversation.messages!.removeAt(index);
        addMessageToConversation(
            message.conversationId!, MessageModal.fromJson(data['data']), true);
        // return image;
      }
    });

    return image;
  }

  Future<dynamic> storeConversation(MessageModal message) async {
    setBusy(true);
    var response = await _conversationService.storeConversations(message);
    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      setBusy(false);
      /* addMessageToConversation(
          message.conversationId, MessageModal.fromJson(data['data']));*/
    } else if (response.statusCode == 422) {
      var data = jsonDecode(response.body);
      //print('sss ${data}');
      setMessage(data["message"].toString());
    }
    setBusy(false);
    return response;
  }

  addMessageToConversation(
      int conversationId, MessageModal message, bool add) async {
    // print('in add ${_concersations.length}  id $conversationId');
    var x = _concersations
        .indexWhere((conversation) => conversation.id == conversationId);

    // print('conver $conversation');
    if (x > -1) {
      var conversation = _concersations
          .firstWhere((conversation) => conversation.id == conversationId);
      conversation.messages!.add(message);
      conversation.unread = conversation.unread! + 1;
      toTheTop(conversation);
      notifyListeners();
      if (add == true) {
        APICacheDBModel apiCacheDBModel = APICacheDBModel(
            key: 'conversations',
            syncData: jsonEncode({'data': _concersations}));
        await APICacheManager().addCacheData(apiCacheDBModel);
      }
    } else {
      await getConversations();
    }
  }

  readOffline(int id) async {
    // print('in add ${_concersations.length}  id $conversationId');
//    var dataarray = [];
//    bool test = await APICacheManager().isAPICacheKeyExist('conversations');
//    if (test) {
//      var temp = await APICacheManager().getCacheData('conversations');
//      //print('www ${temp.syncData}');
//      if (temp != null) {
//        var data = jsonDecode(temp.syncData);
//        data['data'].forEach((conversation) =>
//            dataarray.add(ConversationModel.fromJson(conversation)));
//        //_concersations=_concersations.reversed.toList();
//      }
//      var x =
//          await dataarray.indexWhere((conversation) => conversation.id == id);
//
//      // print('conver $conversation');
//      if (x > -1) {
//        var conversation =
//            dataarray.firstWhere((conversation) => conversation.id == id);
//        var temp = conversation.messages.forEach((message, index) {
//          conversation.messages[index].read = 1;
//        });
//        // toTheTop(conversation);
//        print('sss $conversation');
    APICacheDBModel apiCacheDBModel = APICacheDBModel(
        key: 'conversations', syncData: jsonEncode({'data': concersations}));
    await APICacheManager().addCacheData(apiCacheDBModel);

    notifyListeners();
  }

  toTheTop(ConversationModel conversation) {
    var index = _concersations.indexOf(conversation);

    for (var i = index; i > 0; i--) {
      var x = _concersations[i];
      _concersations[i] = _concersations[i - 1];
      _concersations[i - 1] = x;
    }
  }
}
