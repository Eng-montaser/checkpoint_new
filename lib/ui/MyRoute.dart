import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:checkpoint/model/MallData.dart';
import 'package:checkpoint/model/PointsData.dart';
import 'package:checkpoint/model/QuizData.dart';
import 'package:checkpoint/provider/AuthProvider.dart';
import 'package:checkpoint/provider/GetProvider.dart';
import 'package:checkpoint/provider/PostProvider.dart';
import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/ui/Timer.dart';
import 'package:checkpoint/widget/background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

const hintColor = Color(0xff787878);
const blueColor = Color(0xff00bde8);
const greenColor = Color(0xff6fb200);
const redColor = Color(0xffc0000d);

class MyRoute extends StatefulWidget {
  final String? shift_start;
  final String? shift_end;
  final String? tour;
  final String? actual;
  final String? accept;

  const MyRoute(
      {Key? key,
      this.shift_start,
      this.shift_end,
      this.tour,
      this.actual,
      this.accept})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MyRoute> {
  Location location = new Location();
  LocationData? _locationData;
  bool? _serviceEnabled, isLoading = false;
  UserPoints point =
      new UserPoints(assigned_points: 0, unScandPoints: 0, scandPoints: 0);

  PermissionStatus? _permissionGranted;
  List<String> photos = ['assets/images/logo2.png', 'assets/images/logo2.png'];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<GetProvider>(context, listen: false)
          .getPoints()
          .then((startResponse) async {
        if (startResponse != null) {
          setState(() {
            point = startResponse;
          });
        }
      });
    });
    init();
  }

  init() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      //setState(() {
      _locationData = currentLocation;
      //});
    });
  }

  String getTodayDate() {
    String mydate = '';
    mydate =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    return mydate;
  }

  List<QuizData> quizData = [
    ///encounter_incident
    new QuizData(
        questions: "Any Incident Encountered?",
        answer: false,
        yesExplanation: false,
        noExplanation: false,
        explanationText: new TextEditingController()),

    ///doors_closed
    new QuizData(
        questions: "Service doors closed and were in good condition?",
        answer: true,
        yesExplanation: false,
        noExplanation: true,
        explanationText: new TextEditingController()),

    ///back_of_house
    new QuizData(
        questions: "Back of house used properly?",
        answer: true,
        yesExplanation: false,
        noExplanation: true,
        explanationText: new TextEditingController())
  ];
  QuizDataBody? _quizDataBody;
  setQuizDataBody() {
    _quizDataBody = new QuizDataBody(
        encounter_incident: quizData[0].answer ? "yes" : "no",
        doors_closed: quizData[1].answer ? "yes" : "no",
        doors_closed_notes:
            quizData[1].noExplanation! || quizData[1].yesExplanation!
                ? quizData[1].explanationText!.text
                : null,
        back_of_house: quizData[2].answer ? "yes" : "no",
        back_of_house_notes:
            quizData[2].noExplanation! || quizData[2].yesExplanation!
                ? quizData[2].explanationText!.text
                : null,
        checkout_lat: "${_locationData?.latitude}",
        checkout_long: "${_locationData?.longitude}");
  }

  customAnswer(String answer, bool selected) {
    return Container(
        margin: EdgeInsets.symmetric(
          vertical: ScreenUtil().setHeight(5),
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.orange : Colors.white,
          border: Border.all(color: Color(0xfff1f1f1), width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        width: MediaQuery.of(context).size.width * 0.70,
        height: ScreenUtil().setHeight(40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              answer,
              style: FCITextStyle(color: selected ? Colors.white : Colors.black)
                  .bold20(),
            ),
            Icon(
              selected || selected ? Icons.check_circle : Icons.circle,
              color: selected || selected ? Colors.green[600] : Colors.grey,
              size: ScreenUtil().setSp(35),
            )
          ],
        ));
  }

  customExplanation(TextEditingController textEditingController) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ScreenUtil().setHeight(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xfff1f1f1), width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
      width: MediaQuery.of(context).size.width * 0.7,
      height: ScreenUtil().setHeight(100),
      child: TextField(
        controller: textEditingController,
        maxLines: 5,
        autofocus: false,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Explanation",
            hintStyle: FCITextStyle().normal20(),
            isDense: true),
        style: FCITextStyle().normal20(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var provider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: false,
      body: Background(
        show: false,
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    height: size.height * 0.15,
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
                                  style: FCITextStyle(color: Colors.white)
                                      .bold30(),
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
                            'MY ROUTE',
                            style: FCITextStyle(color: Colors.white).bold22(),
                          ),
                        )
                      ],
                    )),
                Container(
                  // height: size.height * 0.55,
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(20),
                        vertical: ScreenUtil().setHeight(30)),
                    child: Column(
                      //  mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setHeight(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        bottom: ScreenUtil().setHeight(10)),
                                    child: Icon(Icons.watch_later_outlined,
                                        size: ScreenUtil().setSp(35),
                                        color: greenColor),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(7),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${getTodayDate()}',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(height: 1),
                                      ),
                                      Text(
                                        widget.shift_start != null
                                            ? '${widget.shift_start!.split('T')[1].split('.')[0]}'
                                            : "00:00",
                                        style: FCITextStyle(color: hintColor)
                                            .normal20()
                                            .copyWith(height: 1.2),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        bottom: ScreenUtil().setHeight(10)),
                                    child: Icon(Icons.watch_later_outlined,
                                        size: ScreenUtil().setSp(35),
                                        color: redColor),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(7),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${getTodayDate()}',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(height: 1),
                                      ),
                                      Text(
                                        widget.shift_end != null
                                            ? '${widget.shift_end!.split(' ')[1].split('.')[0]}'
                                            : "00:00",
                                        style: FCITextStyle(color: hintColor)
                                            .normal20()
                                            .copyWith(height: 1.2),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(60),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: size.width * .25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Tour Duration',
                                      style: FCITextStyle(color: hintColor)
                                          .normal13()
                                          .copyWith(fontFamily: ''),
                                    ),
                                    Text(
                                      '${widget.tour}',
                                      style: FCITextStyle(color: hintColor)
                                          .normal13()
                                          .copyWith(fontFamily: ''),
                                    )
                                  ],
                                ),
                              ),
                              VerticalDivider(
                                color: hintColor,
                                width: ScreenUtil().setWidth(30),
                                thickness: .5,
                                endIndent: 12,
                                indent: 12,
                              ),
                              Container(
                                width: size.width * .25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Actual Duration',
                                      style: FCITextStyle(color: hintColor)
                                          .normal13()
                                          .copyWith(fontFamily: ''),
                                    ),
                                    Text(
                                      '${widget.actual}',
                                      style: FCITextStyle(color: hintColor)
                                          .normal13()
                                          .copyWith(fontFamily: ''),
                                    )
                                  ],
                                ),
                              ),
                              VerticalDivider(
                                color: hintColor,
                                width: ScreenUtil().setWidth(30),
                                thickness: .5,
                                endIndent: 12,
                                indent: 12,
                              ),
                              Container(
                                width: size.width * .25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Remaining',
                                      style: FCITextStyle(color: hintColor)
                                          .normal13()
                                          .copyWith(fontFamily: ''),
                                    ),
                                    Text(
                                      '${widget.accept}',
                                      style: FCITextStyle(color: hintColor)
                                          .normal13()
                                          .copyWith(fontFamily: ''),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(65),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyTimer(
                                                taskStatus: TaskStatus.Required,
                                                startTime:
                                                    '${provider.userData.shift_start?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                                endTime:
                                                    '${provider.userData.shift_end?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                              )));
                                },
                                child: Container(
                                  width: size.width * .25,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: blueColor,
                                            size: ScreenUtil().setSp(40),
                                          ),
                                          Text(
                                            '${point.assigned_points}',
                                            style:
                                                FCITextStyle(color: hintColor)
                                                    .normal25(),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Assigned',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(fontFamily: ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: hintColor,
                                width: ScreenUtil().setWidth(30),
                                thickness: .5,
                                endIndent: 12,
                                indent: 12,
                              ),
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyTimer(
                                                taskStatus: TaskStatus.Red,
                                                startTime:
                                                    '${provider.userData.shift_start?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                                endTime:
                                                    '${provider.userData.shift_end?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                              )));
                                },
                                child: Container(
                                  width: size.width * .25,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: greenColor,
                                            size: ScreenUtil().setSp(40),
                                          ),
                                          Text(
                                            '${point.scandPoints}',
                                            style:
                                                FCITextStyle(color: hintColor)
                                                    .normal25(),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Scanned',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(fontFamily: ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: hintColor,
                                width: ScreenUtil().setWidth(30),
                                thickness: .5,
                                endIndent: 12,
                                indent: 12,
                              ),
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyTimer(
                                                taskStatus: TaskStatus.Missed,
                                                startTime:
                                                    '${provider.userData.shift_start?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                                endTime:
                                                    '${provider.userData.shift_end?.replaceRange(4, 7, '') ?? '00:00:00'}',
                                              )));
                                },
                                child: Container(
                                  width: size.width * .25,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: redColor,
                                            size: ScreenUtil().setSp(40),
                                          ),
                                          Text(
                                            '${point.unScandPoints}',
                                            style:
                                                FCITextStyle(color: hintColor)
                                                    .normal25(),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'UnScanned',
                                        style: FCITextStyle(color: hintColor)
                                            .normal13()
                                            .copyWith(fontFamily: ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  //  height: size.height * 0.70,
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20)),
                  width: size.width,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        border: Border.all(color: Colors.white),
                        color: Color(0xff293e52)
                        /*boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 2.5,
                                  blurRadius: 5.5,
                                )
                              ],*/
                        ),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: quizData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
//                              decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.all(
//                                    Radius.circular(20),
//                                  ),
//                                  border: Border.all(color: Colors.white),
//                                  color: Color(0xff293e52)
//                                  /*boxShadow: [
//                                  BoxShadow(
//                                    color: Colors.black12,
//                                    spreadRadius: 2.5,
//                                    blurRadius: 5.5,
//                                  )
//                                ],*/
//                                  ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(15),
                                  vertical: ScreenUtil().setHeight(5)),
                              margin: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setHeight(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "${index + 1} ${quizData[index].questions}",
                                      style: FCITextStyle(color: Colors.white)
                                          .normal18(),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        quizData[index].answer = true;
                                        quizData[index].explanationText!.text =
                                            "";
                                      });
                                    },
                                    child: customAnswer(
                                        "Yes",
                                        quizData[index].answer == null
                                            ? false
                                            : quizData[index].answer
                                                ? true
                                                : false),
                                  ),
                                  quizData[index].yesExplanation! &&
                                          (quizData[index].answer != null &&
                                              quizData[index].answer)
                                      ? customExplanation(
                                          quizData[index].explanationText!)
                                      : Container(),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          quizData[index].answer = false;
                                          quizData[index]
                                              .explanationText!
                                              .text = "";
                                        });
                                      },
                                      child: customAnswer(
                                          "No",
                                          quizData[index].answer == null
                                              ? false
                                              : quizData[index].answer
                                                  ? false
                                                  : true)),
                                  quizData[index].noExplanation! &&
                                          (quizData[index].answer != null &&
                                              !quizData[index].answer)
                                      ? customExplanation(
                                          quizData[index].explanationText!)
                                      : Container(),
                                ],
                              ));
                        }),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(10)),
                    decoration: BoxDecoration(
                        color: Color(0xff2a4054),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(35),
                            topLeft: Radius.circular(35))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        mybutton(Icons.stop_circle_outlined, Color(0xff3ee58b),
                            false, 'End', () async {
                          setQuizDataBody();
                          AwesomeDialog(
                              context: context,
                              animType: AnimType.LEFTSLIDE,
                              headerAnimationLoop: false,
                              dialogType: DialogType.NO_HEADER,
                              dismissOnBackKeyPress: true,
                              dismissOnTouchOutside: true,
                              title: "",
                              desc: "endDay".tr(),
                              btnOkText: "yes".tr(),
                              btnOkColor: Color(0xff00d164),
                              btnOkOnPress: () async {
                                await Provider.of<PostProvider>(context,
                                        listen: false)
                                    .endTour(_quizDataBody!.getQuizDataBody())
                                    .then((value) {
                                  Navigator.of(context).pop(true);
                                });
                              },
                              btnCancelText: "no".tr(),
                              btnCancelColor: Colors.red,
                              btnCancelOnPress: () {},
                              onDissmissCallback: (type) {})
                            ..show();
                        }),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget mybutton(IconData icondata, Color color, bool isSmall, String text,
      Function() ontap,
      {double width = .3}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        ///height: 50,
        width: MediaQuery.of(context).size.width * width,
        padding: EdgeInsets.symmetric(
            //horizontal: ScreenUtil().setWidth(15),
            vertical: ScreenUtil().setHeight(10)),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icondata,
              color: Colors.white,
              size: isSmall ? ScreenUtil().setSp(15) : ScreenUtil().setSp(30),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(5),
            ),
            Text(
              '$text',
              style: isSmall
                  ? FCITextStyle(color: Colors.white).normal16()
                  : FCITextStyle(color: Colors.white).bold20(),
            ),
          ],
        ),
      ),
    );
  }
}
