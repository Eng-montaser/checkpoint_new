import 'dart:io';

import 'package:checkpoint/chat/message_model.dart';
import 'package:checkpoint/model/IncidentsData.dart';
import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/provider/CasheManger.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Api {
  static final _api = Api._internal();

  factory Api() {
    return _api;
  }
  Api._internal();

  ///  Temporrary*****************************************

  ///*****************************************************
  String baseUrl = 'check-points.fsdmarketing.com';
  String path = '/api';
  Future<http.Response> httpGet(String endPath,
      {Map<String, String>? query}) async {
    String? token = await CacheManger().getToken();

    Uri uri = Uri.http(baseUrl, '$path/$endPath');
    if (query != null) {
      uri = Uri.http(baseUrl, '$path/$endPath', query);
    }
    return http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
  }

  Future<http.Response> httpPost(String endPath, Object body) async {
    String? token = await CacheManger().getToken();
    print(token);
    Uri uri = Uri.http(baseUrl, '$path/$endPath');
    return http.post(uri, body: body, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
  }

  Future<http.Response> httpPostWithFile(String endPath,
      {required File file, required AuthenticationData data}) async {
    String? token = await CacheManger().getToken();
    print(token);
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    Map<String, String> body = data.getUpdateBody();
    Uri uri = Uri.http(baseUrl, '$path/$endPath');
    var length = await file.length();
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields.addAll(body)
      ..files.add(
        http.MultipartFile('image', file.openRead(), length,
            filename: basename(file.path)),
      );
    return await http.Response.fromStream(await request.send());
  }

  Future<http.Response> httpPostAudioFile(String endPath,
      {required File file}) async {
    String? token = await CacheManger().getToken();
    print(token);
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    /* Map<String, String> body = {
      // 'body': file,
      'name': name,
      'phone': phone
    };*/
    Uri uri = Uri.http(baseUrl, '$path/$endPath');
    var length = await file.length();
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      //  ..fields.addAll(body)
      ..files.add(
        http.MultipartFile('file', file.openRead(), length,
            filename: basename(file.path)),
      );
    return await http.Response.fromStream(await request.send());
  }

  Future<http.Response> httpPostWithFiles(String endPath,
      {required IncidentsData incidentsData}) async {
    String? token = await CacheManger().getToken();
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    List<http.MultipartFile> temps = [];
    Uri uri = Uri.http(baseUrl, '$path/$endPath');

    for (var file in incidentsData.photos) {
      var length = await file.length();
      temps.add(http.MultipartFile('photos[]', file.openRead(), length,
          filename: basename(file.path)));
    }

    Map<String, String> data = {
      'name': incidentsData.name,
      'description': incidentsData.description,
    };
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields.addAll(data)
      ..files.addAll(temps);
    return await http.Response.fromStream(await request.send());
  }

  Future<http.Response> httpPostWithFileChat(String endPath,
      {required File file, required MessageModal message}) async {
    String? token = await CacheManger().getToken();
    file.length().then((value) => print('ppp ${value}'));
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    Map<String, String> body = {
      // 'body': file,
      'type': '${message.type}',
      'conversation_id': message.conversationId.toString()
    };
    Uri uri = Uri.http(baseUrl, '$path/$endPath');
    var length = await file.length();
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields.addAll(body)
      ..files.add(
        http.MultipartFile('body', file.openRead(), length,
            filename: basename(file.path)),
      );
    return await http.Response.fromStream(await request.send());
  }

  Future<http.Response> httpPatch(String endPath, Object body) async {
    String? token = await CacheManger().getToken();
    print(token);
    print(body);
    Uri uri = Uri.http(baseUrl, '$path/$endPath');
    return http.patch(uri, body: body, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
  }
}
