import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget ButtonHome({icon, text, onpress, color}) {
  return InkWell(
    onTap: onpress,
    child: Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(8),
          vertical: ScreenUtil().setHeight(3)),
      // vertical: ScreenUtil().setHeight(5)),
      alignment: Alignment.center,
      //height: ScreenUtil().setHeight(60),
      width: ScreenUtil().setWidth(160),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: Colors.white,
              size: ScreenUtil().setSp(25),
            ),
          if (icon != null)
            SizedBox(
              width: ScreenUtil().setWidth(10),
            ),
          Text(
            text,
            style: FCITextStyle(color: Colors.white).normal22(),
          ),
        ],
      ),
    ),
  );
}
