import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

class MallData {
  String name;
  int mallId;
  MallData({required this.mallId, required this.name});
  factory MallData.fromJson(Map<String, dynamic> json) {
    return MallData(mallId: json['id'], name: json['name']);
  }
}

void modalBottomSheetMenu({context, vacationName, vacationId, data}) {
  showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
            title: Text(
              "chooseBranch".tr(),
              style: FCITextStyle().bold16(),
            ),
            actions: _createListView(context, data, vacationName, vacationId),
            cancelButton: CupertinoActionSheetAction(
              child: Text(
                "Cancel".tr(),
                style: FCITextStyle().bold16(),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ));
}

List<CupertinoActionSheetAction> _createListView(
    BuildContext context, List<MallData> data, changeName, changeId) {
  Size size = MediaQuery.of(context).size;
  List<CupertinoActionSheetAction> cupertinoActionSheetAction = [];
  if (data != null) {
    CupertinoActionSheetAction e = new CupertinoActionSheetAction(
      onPressed: () {},
      child: Container(),
    );
    cupertinoActionSheetAction = List.filled(data.length, e);
    // List<CupertinoActionSheetAction>(data.length);
    for (int index = 0; index < data.length; index++) {
      cupertinoActionSheetAction[index] = new CupertinoActionSheetAction(
          //leading: new Icon(CupertinoIcons.directions_car),
          child: new Text(
            '${data[index].name}',
            style: FCITextStyle().normal18(),
          ),
          onPressed: () {
            changeName(data[index].name);
            changeId(data[index].mallId);
            Navigator.pop(context);
          });
    }
  }
  return cupertinoActionSheetAction;
}

class UserPoints {
  int? assigned_points;
  int? scandPoints;
  int? unScandPoints;
  UserPoints({this.assigned_points, this.scandPoints, this.unScandPoints});
  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
        assigned_points: json['assigned_points'].length,
        scandPoints: json['scandPoints'].length,
        unScandPoints: json['unScandPoints'].length);
  }
}
