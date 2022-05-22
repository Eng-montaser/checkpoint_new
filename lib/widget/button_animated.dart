import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:checkpoint/style/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StaggerAnimation extends StatelessWidget {
  final VoidCallback onTap;
  final String titleButton;
  final Color? background;
  final Color? foreground;
  final BuildContext context;
  StaggerAnimation(
      {Key? key,
      required this.buttonController,
      required this.onTap,
      this.titleButton = 'Sign In',
      this.background,
      this.foreground,
      required this.context})
      : buttonSqueezeanimation = Tween(
          begin: MediaQuery.of(context).size.width * 0.70,
          end: 50.0,
        ).animate(
          CurvedAnimation(
            parent: buttonController,
            curve: const Interval(
              0.0,
              0.150,
            ),
          ),
        ),
        containerCircleAnimation = EdgeInsetsTween(
          begin: EdgeInsets.only(bottom: ScreenUtil().setHeight(30)),
          end: EdgeInsets.only(bottom: 0.0),
        ).animate(
          CurvedAnimation(
            parent: buttonController,
            curve: const Interval(
              0.500,
              0.800,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final Animation<double> buttonController;
  final Animation<EdgeInsets> containerCircleAnimation;
  final Animation buttonSqueezeanimation;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSqueezeanimation.value,
        height: ScreenUtil().setHeight(50),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
          color: background,
          borderRadius: BorderRadius.all(
              Radius.circular(buttonSqueezeanimation.value > 75.0 ? 25 : 25)),
        ),
        child: buttonSqueezeanimation.value > 75.0
            ? Text(titleButton,
                style: FCITextStyle(color: Colors.white).bold18())
            : CircularProgressIndicator(
                value: null,
                strokeWidth: 1.0,
                valueColor: AlwaysStoppedAnimation<Color>(foreground!),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: buttonController,
    );
  }
}
