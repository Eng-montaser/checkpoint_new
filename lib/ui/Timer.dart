import 'package:checkpoint/model/PointsData.dart';
import 'package:checkpoint/provider/GetProvider.dart';
import 'package:checkpoint/provider/PostProvider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:checkpoint/widget/DateTimeLine/date_picker_widget.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

class MyTimer extends StatefulWidget {
  TaskStatus? taskStatus;
  String? startTime;
  String? endTime;
  MyTimer({this.taskStatus, this.startTime, this.endTime});
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<MyTimer> {
  List<PointsData>? _pointsDataList;
  List<PointsData>? _pointsDataListByDate;
  DatePickerController? _controller;
  @override
  void initState() {
    _controller = DatePickerController();
//    _controller.jumpToSelection();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.taskStatus != null)
        await Provider.of<GetProvider>(context, listen: false)
            .getAllPoints(widget.taskStatus)
            .then((value) {
          setState(() {
            _pointsDataList = value;
          });
          getPoint();
        });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Do Something here
      _controller!.animateToDate(DateTime.now());
    });
//    setState(() {
//      _controller.jumpToSelection();
//    });
  }

  getPoint() async {
    _pointsDataListByDate = [];
    _pointsDataList!.forEach((element) {
//       if(_selectedTime.difference(element.created_at).inDays == 0)
      if (_compareDate(_selectedTime, element.created_at))
        _pointsDataListByDate!.add(element);
    });
    _pointsDataList!.forEach((element) {});
    _pointsDataListByDate!.forEach((element) {});
  }

  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }

  DateTime _selectedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
//    var provider = Provider.of<AuthProvider>(context, listen: false);
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
                                Navigator.of(context).pop(false);
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
                          'Timer',
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
                      top: ScreenUtil().setHeight(50),
                      right: ScreenUtil().setWidth(50),
                      left: ScreenUtil().setWidth(50)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width - ScreenUtil().setWidth(100),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: (size.width -
                                          ScreenUtil().setWidth(100)) /
                                      4,
                                  child: Column(
                                    children: [
                                      Text("Start Time"),
                                      widget.startTime != null
                                          ? Text("${widget.startTime}")
                                          : Text("00:00")
                                    ],
                                  ),
                                ),
                                VerticalDivider(thickness: 1),
                                Divider(),
                                Container(
                                  alignment: Alignment.center,
                                  width: (size.width -
                                          ScreenUtil().setWidth(100)) /
                                      4,
                                  child: Column(
                                    children: [
                                      Text("End Time"),
                                      widget.endTime != null
                                          ? Text("${widget.endTime}")
                                          : Text("00:00")
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: DatePicker(
                            DateTime.now().subtract(Duration(days: 100)),
                            width: ScreenUtil().setWidth(50),

                            height: ScreenUtil().setHeight(90),
                            controller: _controller,
                            initialSelectedDate: DateTime.now(),
                            selectionColor: FCIColors.background(),
                            deactivatedColor: Colors.grey,

                            dateTextStyle: FCITextStyle().normal11(),
                            deactivatedDateStyle:
                                FCITextStyle(color: Colors.transparent)
                                    .normal13(),
                            selectedDateStyle:
                                FCITextStyle(color: Colors.white).normal12(),

                            dayTextStyle: FCITextStyle().normal10(),
                            deactivatedDayStyle:
                                FCITextStyle(color: Colors.transparent)
                                    .normal13(),
                            selectedDayStyle:
                                FCITextStyle(color: Colors.white).normal10(),

                            deactivatedMonthStyle:
                                FCITextStyle(color: Colors.transparent)
                                    .normal13(),
                            selectedMonthStyle:
                                FCITextStyle(color: Colors.white).normal12(),
                            monthTextStyle: FCITextStyle().normal10(),
//                            inactiveDates: [
//                              DateTime.now().add(Duration(days: 3)),
//                              DateTime.now().add(Duration(days: 4)),
//                              DateTime.now().add(Duration(days: 7))
//                            ],
                            onDateChange: (date) {
                              // New date selected
                              setState(() {
                                _selectedTime = date;
                              });
                              getPoint();
                            },
                          ),
                        ),
                        Divider(
                          thickness: 5,
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        widget.taskStatus == TaskStatus.Required
                            ? _pointsDataList != null
                                ? _pointsDataList!.length == 0
                                    ? Center(
                                        child: Text(
                                            "There is no points in ${_selectedTime.toString()}"),
                                      )
                                    : Container(
                                        height: size.height / 2,
                                        child: ListView.builder(
                                            itemCount: _pointsDataList!.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return timerLine(
                                                  _pointsDataList![index]);
                                            }),
                                      )
                                : loading()
                            : _pointsDataListByDate != null
                                ? _pointsDataListByDate!.length == 0
                                    ? Center(
                                        child: Text(
                                            "There is no points in ${_selectedTime.toString()}"),
                                      )
                                    : Container(
                                        height: size.height / 2,
                                        child: ListView.builder(
                                            itemCount:
                                                _pointsDataListByDate!.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return timerLine(
                                                  _pointsDataListByDate![
                                                      index]);
                                            }),
                                      )
                                : loading(),
//                        Container(
//                          height: size.height/2,
//                          child:  ListView.builder(
//                              itemCount: 20,
//                              itemBuilder: (BuildContext context,int  index){
//                                  if(index==0)
//                                    return timerLine(TaskStatus.Required);
//                                if(index==2)
//                                return timerLine(TaskStatus.Red);
//                                if(index==3)
//                                return  timerLine(TaskStatus.Missed);
//                                return  timerLine(TaskStatus.Required);
//                              }),
//                        ),

//                        Row(
//                          children: [
//                            Text("Today",style: FCITextStyle(color: FCIColors.taskText()).bold18(),),
//                          ],
//                        ),
//                        Container(
//                          height: ScreenUtil().setHeight(90*3),
//                          width: MediaQuery.of(context).size.width * 0.75,
//                          decoration: BoxDecoration(
//                              borderRadius: BorderRadius.all(Radius.circular(25)),
//                              color: FCIColors.taskBackGround()
//                          ),
//                          child: ListView.builder(
//                              itemCount: 3,
//                              itemBuilder: (BuildContext context,int  index){
//                                return Column(
//                                  children: [
//                                    task(),
//                                    if(index!=2)Divider()
//                                  ],
//                                );
//                              }),
//                        ),
//                        SizedBox(
//                          height: ScreenUtil().setHeight(15),
//                        ),
//                        Row(
//                          children: [
//                            Text("Old",style: FCITextStyle(color: FCIColors.taskText()).bold18(),),
//                          ],
//                        ),
//                        Container(
//                          height: ScreenUtil().setHeight(90*3),
//                          width: MediaQuery.of(context).size.width * 0.75,
//                          decoration: BoxDecoration(
//                              borderRadius: BorderRadius.all(Radius.circular(25)),
//                              color: FCIColors.taskBackGround()
//                          ),
//                          child: ListView.builder(
//                              itemCount: 3,
//                              itemBuilder: (BuildContext context,int  index){
//                                return Column(
//                                  children: [
//                                    task(),
//                                    if(index!=2)Divider()
//                                  ],
//                                );
//                              }),
//                        )
                      ],
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget timerLine(PointsData pointsData) {
    Color _statusColor;
    switch (pointsData.taskStatus) {
      case TaskStatus.Required:
        _statusColor = FCIColors.timerRequired();
        break;
      case TaskStatus.Red:
        _statusColor = FCIColors.timerRed();
        break;
      case TaskStatus.Missed:
        _statusColor = FCIColors.timerMissed();
        break;
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: ScreenUtil().setHeight(60),
            child: TimelineNode(
              indicator: CircleAvatar(
                backgroundColor: _statusColor,
                radius: 12,
              ),
              startConnector: SolidLineConnector(
                color: FCIColors.timerText(),
              ),
              endConnector: SolidLineConnector(
                color: FCIColors.timerText(),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                "#${pointsData.id}",
                style: FCITextStyle().normal12(),
              ),
              Text(
                  "${pointsData.created_at.hour}:${pointsData.created_at.minute}",
                  style: FCITextStyle().normal12()),
            ],
          ),
          FittedBox(
              child: Container(
//                    height: ScreenUtil().setHeight(height),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Text("${pointsData.name} ",
                      style: FCITextStyle().normal12())))
        ],
      ),
    );
  }

  @override
  void dispose() {
    PostProvider().dispose();
    GetProvider().dispose();
    super.dispose();
  }
}
