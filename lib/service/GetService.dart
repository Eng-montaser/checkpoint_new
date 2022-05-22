import 'package:http/http.dart' as http;

import 'base_api.dart';

class GetService extends BaseApi {
  Future<http.Response> getMallData() async {
    return await api.httpGet('malls');
  }

  Future<http.Response> isStart() async {
    return await api.httpGet('is_start');
  }

  Future<http.Response> isEnd() async {
    return await api.httpGet('is_end');
  }

  Future<http.Response> getPoints() async {
    return await api.httpGet('points');
  }

  Future<http.Response> getUserData() async {
    return await api.httpGet('user/details');
  }

  Future<http.Response> searchtUser(String phone) async {
    return await api.httpGet('search', query: {'phone': phone});
  }

  Future<http.Response> getAllPoints() async {
    return await api.httpGet('points', query: {"all_data": '1'});
  }

  Future<http.Response> getTasks() async {
    return await api.httpGet('tasks');
  }
}
