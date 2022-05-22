import 'dart:convert';

import 'package:checkpoint/model/MallData.dart';
import 'package:checkpoint/model/PointsData.dart';
import 'package:checkpoint/model/SosData.dart';
import 'package:checkpoint/model/TasksData.dart';
import 'package:checkpoint/model/UserData.dart';
import 'package:checkpoint/service/GetService.dart';
import 'package:checkpoint/service/api.dart';

import 'base_provider.dart';

class GetProvider extends BaseProvider {
  GetService _getService = GetService();
  Api _api = Api();
  Future<List<MallData>?> getMallData() async {
    List<MallData>? _mallData;
    setBusy(true);
    try {
      var response = await _getService.getMallData();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _mallData = [];
        data['data'].forEach((mall) => _mallData!.add(MallData.fromJson(mall)));
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      print(e);
      setBusy(false);
    }
    setBusy(false);
    return _mallData;
  }

  Future<IsStartData?> isStart() async {
    IsStartData? result;
    setBusy(true);
    try {
      var response = await _getService.isStart();

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        result = IsStartData.fromJson(data['data']);
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      print(e);
      setBusy(false);
    }
    setBusy(false);
    return result;
  }

  Future<bool?> isEnd() async {
    bool? result;
    List<MallData>? _mallData;
    setBusy(true);
    try {
      var response = await _getService.isEnd();
      print(response.statusCode);
      print(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        result = data['data']['data'];
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      print(e);
      setBusy(false);
    }
    setBusy(false);
    return result;
  }

  Future<UserPoints?> getPoints() async {
    UserPoints? points;
    setBusy(true);
    try {
      var response = await _getService.getPoints();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        points = UserPoints.fromJson(data['data']);
        //result=data['data']['data'];
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      print(e);
      setBusy(false);
    }
    setBusy(false);
    return points;
  }

  Future<List<UserData>> getUsers(String phone) async {
    List<UserData> userss = [];
    setBusy(true);
    var response = await _getService.searchtUser(phone);
    var data = jsonDecode(response.body);
    //print('addd ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      data.forEach((usrs) => userss.add(UserData.fromSearchJson(usrs)));

      notifyListeners();
      setBusy(false);
    }
    return userss;
  }

  Future<List<PointsData>> getAllPoints(TaskStatus? taskStatus) async {
    List<PointsData> pointsDataList = [];
    setBusy(true);
    try {
      var response = await _getService.getAllPoints();
      print(response.statusCode);
      print(response.body.toString());
      Map<dynamic, dynamic> da = jsonDecode(response.body);
      print(da["data"]);
      for (dynamic key in da.keys) {
//        if(key!="assigned_points") {
        print(key);
        print(da[key].toString());
//        }
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        switch (taskStatus) {
          case TaskStatus.Required:
            data['data']['assigned_points'].forEach((point) => pointsDataList
                .add(PointsData.fromJson(point, TaskStatus.Required)));
            /*  data['data']['scandPoints'].forEach((point) => pointsDataList
                .add(PointsData.fromJson(point, TaskStatus.Required)));
            data['data']['unScandPoints'].forEach((point) => pointsDataList
                .add(PointsData.fromJson(point, TaskStatus.Required)));*/
            break;
          case TaskStatus.Red:
            data['data']['scandPoints'].forEach((point) => pointsDataList
                .add(PointsData.fromJson(point, TaskStatus.Required)));
            break;
          case TaskStatus.Missed:
            data['data']['unScandPoints'].forEach((point) => pointsDataList
                .add(PointsData.fromJson(point, TaskStatus.Required)));
            break;
        }
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      print(e);
      setBusy(false);
    }
    setBusy(false);
    return pointsDataList;
  }

  Future<List<TasksData>> getTasks() async {
    List<TasksData> _tasksDataList = [];
    setBusy(true);
    try {
      var response = await _getService.getTasks();
      print(response.statusCode);
      print(response.body.toString());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data['data'].forEach(
            (taskData) => _tasksDataList.add(TasksData.fromJson(taskData)));
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      print(e);
      setBusy(false);
    }
    setBusy(false);
    return _tasksDataList;
  }
}
