import 'package:checkpoint/model/TasksData.dart';
import 'package:checkpoint/provider/GetProvider.dart';
import 'package:checkpoint/provider/PostProvider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:checkpoint/widget/button_animated.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Tasks extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<Tasks> with TickerProviderStateMixin {
  List<TasksData>? _todayTasksDataList;
  List<TasksData>? _oldTasksDataList;
  @override
  void initState() {
    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<GetProvider>(context, listen: false)
          .getTasks()
          .then((value) {
        _todayTasksDataList = [];
        _oldTasksDataList = [];
        value.forEach((element) {
//       if(_selectedTime.difference(element.created_at).inDays == 0)
          if (_compareDate(DateTime.now(), element.created_at))
            _todayTasksDataList!.add(element);
          else
            _oldTasksDataList!.add(element);
        });
        setState(() {
//            _pointsDataList=value;
        });
      });
    });
    super.initState();
  }

  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Background(
        show: false,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  height: size.height * 0.20,
                  width: size.width * 0.9,
                  padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setHeight(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_outlined,
                                color: Colors.white,
                                size: ScreenUtil().setSp(35),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/location.png",
                                  fit: BoxFit.fill,
//                          height: ScreenUtil().setHeight(200),
                                  width: ScreenUtil().setWidth(35)),
                              SizedBox(
                                width: ScreenUtil().setWidth(15),
                              ),
                              Text(
                                "CHECK POINT",
                                style:
                                    FCITextStyle(color: Colors.white).bold30(),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(25),
                          )
                        ],
                      ),
                      Container(
                        child: Text(
                          'TASK',
                          style: FCITextStyle(color: Colors.white).bold22(),
                        ),
                      )
                    ],
                  )),
              Container(
                height: size.height * 0.75,
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100.0),
                    topRight: Radius.circular(100.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 2.5,
                      blurRadius: 5.5,
                    )
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.only(
                      top: ScreenUtil().setHeight(60),
                      right: ScreenUtil().setWidth(50),
                      left: ScreenUtil().setWidth(50)),
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        Row(
                          children: [
                            Text(
                              "Today",
                              style: FCITextStyle(color: FCIColors.taskText())
                                  .bold18(),
                            ),
                          ],
                        ),
                        _todayTasksDataList != null
                            ? _todayTasksDataList!.length == 0
                                ? Container(
                                    height: ScreenUtil().setHeight(50),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        color: FCIColors.taskBackGround()),
                                    child: Center(
                                      child: Text(
                                        "There is no points today",
                                        style: FCITextStyle(
                                                color: FCIColors.taskText())
                                            .normal13(),
                                      ),
                                    ))
                                : Container(
                                    height: ScreenUtil().setHeight(
                                        70 * _todayTasksDataList!.length),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        color: FCIColors.taskBackGround()),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: _todayTasksDataList!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            children: [
                                              task(index, true),
                                              if (index !=
                                                  _todayTasksDataList!.length -
                                                      1)
                                                Divider()
                                            ],
                                          );
                                        }),
                                  )
                            : loading(),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        if (_oldTasksDataList?.length != 0)
                          Row(
                            children: [
                              Text(
                                "Old",
                                style: FCITextStyle(color: FCIColors.taskText())
                                    .bold18(),
                              ),
                            ],
                          ),
                        _oldTasksDataList != null
                            ? _oldTasksDataList!.length == 0
                                ? Container()
                                : Container(
                                    height: ScreenUtil().setHeight(
                                        70 * _oldTasksDataList!.length),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        color: FCIColors.taskBackGround()),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: _oldTasksDataList!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            children: [
                                              task(index, false),
                                              if (index !=
                                                  _oldTasksDataList!.length - 1)
                                                Divider()
                                            ],
                                          );
                                        }),
                                  )
                            : loading(),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget task(int index, bool isToday) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                updateTaskStatus(context, index, isToday));
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Task ${index + 1}",
                  style: FCITextStyle(color: FCIColors.taskText()).bold16(),
                ),
                FittedBox(
                    child: Container(
//                    height: ScreenUtil().setHeight(height),
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Text(
                          "${isToday ? _todayTasksDataList![index].description : _oldTasksDataList![index].description}",
                          style: FCITextStyle(color: FCIColors.taskText())
                              .normal13(),
                        )))
              ],
            ),
            Checkbox(
              value: true,
              onChanged: (val) {},
              activeColor: getStatusColor(isToday
                  ? _todayTasksDataList![index].taskStatus
                  : _oldTasksDataList![index].taskStatus),
            ),
          ],
        ),
      ),
    );
  }

  AnimationController? _loginButtonController;
  String? status;
  TextEditingController _notesController = new TextEditingController();
  Widget updateTaskStatus(context, int index, bool isToday) {
    Size size = MediaQuery.of(context).size;
    var getProvider = Provider.of<PostProvider>(context, listen: false);
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
      content: Container(
          width: size.width,
          height: size.shortestSide,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Task Status",
                style: FCITextStyle(color: accentColor).bold22(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          status = "done";
                        });
                      },
                      child: Container(
                        width: ScreenUtil().setWidth(120),
                        height: ScreenUtil().setHeight(40),
                        alignment: FractionalOffset.center,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: status == "done"
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white,
                              spreadRadius: 3,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                              color: status == "done"
                                  ? primaryColor
                                  : accentColor),
                          color: status == "done" ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Text(
                          "Done",
                          style: FCITextStyle(
                            color:
                                status == "done" ? Colors.white : accentColor,
                          ).bold18(),
                        ),
                      )),
                  SizedBox(
                    width: ScreenUtil().setWidth(20),
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          status = "rejected";
                        });
                      },
                      child: Container(
                        width: ScreenUtil().setWidth(120),
                        height: ScreenUtil().setHeight(40),
                        alignment: FractionalOffset.center,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: status == "rejected"
                                  ? primaryColor.withOpacity(0.2)
                                  : Colors.white,
                              spreadRadius: 3,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                              color: status == "rejected"
                                  ? primaryColor
                                  : accentColor),
                          color: status == "rejected"
                              ? primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Text(
                          "Rejected",
                          style: FCITextStyle(
                            color: status == "rejected"
                                ? Colors.white
                                : accentColor,
                          ).bold18(),
                        ),
                      )),
                ],
              ),
              Container(
                width: size.width,
                alignment: Alignment.center,
                height: ScreenUtil().setHeight(150),
                margin: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: accentColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(10),
                    right: ScreenUtil().setWidth(10)),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _notesController,
                  onSubmitted: (value) {},
                  autofocus: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "notes",
                    hintStyle: FCITextStyle(color: Colors.grey).normal18(),
                  ),
                ),
              ),
              StaggerAnimation(
                titleButton: 'Submit',
                context: context,
                foreground: Colors.white,
                background: primaryColor,
                buttonController: _loginButtonController!.view,
                onTap: () async {
                  await _playAnimation();
                  if (status != null) {
                    await Provider.of<PostProvider>(context, listen: false)
                        .updateTask(
                            isToday
                                ? _todayTasksDataList![index].id
                                : _oldTasksDataList![index].id,
                            _notesController.text,
                            status!)
                        .then((value) async {
                      if (value) {
                        setState(() {
                          _notesController.clear();
                          isToday
                              ? _todayTasksDataList![index].taskStatus =
                                  status == "done"
                                      ? TasksStatus.done
                                      : TasksStatus.rejected
                              : _oldTasksDataList![index].taskStatus =
                                  status == "done"
                                      ? TasksStatus.done
                                      : TasksStatus.rejected;
                          status = null;
                        });
                        await _stopAnimation();
                        Navigator.of(context).pop();
                      } else
                        await _stopAnimation();
                    });
                  }
                },
              ),
            ],
          )),
    );
  }

  bool _isButtonLoading = false;
  Future<Null> _playAnimation() async {
    try {
      setState(() {
        _isButtonLoading = true;
      });
      await _loginButtonController!.forward();
    } on TickerCanceled {}
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController!.reverse();
      setState(() {
        _isButtonLoading = false;
      });
    } on TickerCanceled {}
  }

  getStatusColor(TasksStatus tasksStatus) {
    switch (tasksStatus) {
      case TasksStatus.pending:
        return Colors.blue;
        break;
      case TasksStatus.done:
        return FCIColors.taskCheckBox();
        break;
      case TasksStatus.rejected:
        return Colors.red;
        break;
      case TasksStatus.received:
        return Colors.grey;
        break;
    }
  }

  @override
  void dispose() {
    PostProvider().dispose();
    GetProvider().dispose();
    super.dispose();
  }
}
