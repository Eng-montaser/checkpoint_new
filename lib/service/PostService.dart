import 'dart:io';

import 'package:checkpoint/model/IncidentsData.dart';
import 'package:checkpoint/model/SosData.dart';
import 'package:checkpoint/model/UserData.dart';
import 'package:http/http.dart' as http;

import 'base_api.dart';

class PostService extends BaseApi {
  Future<http.Response> register(AuthenticationData authenticationData) async {
    return await api.httpPost("register", authenticationData.getSignUpBody());
  }

  Future<http.Response> login(AuthenticationData data) async {
    return await api.httpPost("login", data.getLoginBody());
  }

  Future<http.Response> logout() async {
    return await api.httpPost("logout", {});
  }

  Future<http.Response> startTour(data) async {
    return await api.httpPost("start_tour", data);
  }

  Future<http.Response> endTour(data) async {
    return await api.httpPost("end_tour", data);
  }

  Future<http.Response> sos(SosData sosData) async {
    print('mhm ${sosData.getBody()}');
    return await api.httpPost("sos", sosData.getBody());
  }

  Future<http.Response> sendIncidents(IncidentsData incidentsData) async {
    return await api.httpPostWithFiles("incidents",
        incidentsData: incidentsData);
  }

  Future<http.Response> pushToTalk(File file) async {
    return await api.httpPostAudioFile("talks", file: file);
  }

  Future<http.Response> scan(data) async {
    return await api.httpPost("scan", data);
  }

  Future<http.Response> offlineScan(data) async {
    return await api.httpPost("offline_scan", {"data": data.toString()});
  }

  Future<http.Response> offlineSos(data) async {
    return await api.httpPost("offline_sos", {"data": data.toString()});
  }
  /*Future<http.Response> updateUserData(file, AuthenticationData data) async {
    return file != null
        ? await api.httpPostWithFile("user/update",
            file: file, name: data.name, phone: data.phone)
        : await api.httpPost("user/update", data.getUpdateBody());
  }*/

  Future<http.Response> setFcmToken(String token) async {
    return await api.httpPost('fcm', {'fcm_token': token.toString()});
  }

  Future<http.Response> updateUserData(file, AuthenticationData data) async {
    return file != null
        ? await api.httpPostWithFile("user/update", file: file, data: data)
        : await api.httpPost("user/update", data.getUpdateBody());
  }

  Future<http.Response> receivedTask(
    int id,
  ) async {
    return await api
        .httpPatch("tasks/${id}", {"is_recived": '1', "status": "recived"});
  }

  Future<http.Response> updateTask(int id, String notes, String status) async {
    return await api
        .httpPatch("tasks/${id}", {"notes": notes, "status": status});
  }
}
