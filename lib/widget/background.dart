import 'package:easy_localization/easy_localization.dart' as T;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Background extends StatelessWidget {
  final Widget child;
  final bool show;
  const Background({
    Key? key,
    required this.child,
    this.show = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Image.asset(
                "assets/images/Group 20.png",
                width: size.width,
                fit: BoxFit.fill,
                height: size.height,
              ),
            ),
            if (show)
              Positioned(
                bottom: 0,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(5),
                      vertical: ScreenUtil().setWidth(5)),
                  child: InkWell(
                    onTap: () async {
                      await T.EasyLocalization.of(context)?.setLocale(
                          T.EasyLocalization.of(context)?.locale.languageCode ==
                                  'en'
                              ? Locale('ar', 'SA')
                              : Locale('en', 'US'));
                    },
                    child:
                        T.EasyLocalization.of(context)?.locale.languageCode ==
                                'en'
                            ? Image.asset(
                                "assets/images/arbutton.png",
                                width: ScreenUtil().setWidth(45),
                                height: ScreenUtil().setHeight(45),
                                fit: BoxFit.fill,
                              )
                            : Image.asset(
                                "assets/images/enbutton.png",
                                width: ScreenUtil().setWidth(45),
                                height: ScreenUtil().setHeight(45),
                                fit: BoxFit.fill,
                              ),
                  ),
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class RedClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height / 4.25);
    var firstControlPoint = new Offset(size.width / 4, size.height / 3);
    var firstEndPoint = new Offset(size.width / 2, size.height / 3 - 60);
    var secondControlPoint =
        new Offset(size.width - (size.width / 4), size.height / 4 - 65);
    var secondEndPoint = new Offset(size.width, size.height / 3 - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    throw UnimplementedError();
  }

  /*@override
  bool shouldReclip(CustomClipper oldClipper) {
    return null;
  }*/
}
