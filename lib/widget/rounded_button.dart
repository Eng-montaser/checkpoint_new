import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundedButton extends StatelessWidget {
  final Function()? onTap;
  final Color? color;
  final String text;
  const RoundedButton({
    Key? key,
    required this.onTap,
    this.color,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // width: double.infinity,

        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(20),
            vertical: ScreenUtil().setHeight(5)),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
        child: Text(
          text,
          style: FCITextStyle(color: Colors.white).normal16(),
        ),
      ),
    );
  }
}
