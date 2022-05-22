import 'package:checkpoint/style/FCITextStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obsecure;
  final Widget suffixicon;
  final String initial;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> validate;
  final TextInputType inputType;
  const RoundedInputField(
      {Key key,
      this.hintText,
      this.icon,
      this.validate = null,
      this.suffixicon,
      this.obsecure = false,
      this.onChanged,
      this.inputType = TextInputType.text,
      this.initial = null,
      this.controller = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(10)),
    //  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(5)),
      width: MediaQuery.of(context).size.width * 0.8,
      /* decoration: BoxDecoration(
          color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
        ),*/
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validate,
        initialValue: initial,
       // cursorHeight: 20,
        style:
            TextStyle(height: 1,  color: Colors.black),
        obscureText: obsecure,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: new OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(29)),

          /* icon: Icon(
              icon,
              color: kPrimaryColor,
            ),*/
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(29.0),
            borderSide: BorderSide(
color: Colors.grey.shade300
              // width: 2.0,
            ),
          ),
          prefixIcon: Icon(
            icon,
          ),
          suffixIcon: suffixicon,
          // errorText: "jhjhjh",
          //  border: BorderRadius.circular(40)
        ),
      ),
    );
  }
}*/

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final IconData? leading;
  final Function(String?)? userTyped;
  final bool obscure;
  final FocusNode? focusNode;
  final TextInputType keyboard;
  final TextEditingController? controller;
  final Color? color;
  final bool enabled;
  final Widget? suffixicon;

  CustomTextInput({
    required this.hintText,
    this.leading,
    this.userTyped,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.color,
    this.suffixicon,
    this.controller,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(5)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xfff1f1f1), width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
      width: MediaQuery.of(context).size.width * 0.70,
      height: ScreenUtil().setHeight(50),
      child: TextField(
        onChanged: userTyped,
        keyboardType: keyboard,
        controller: controller,
        enabled: enabled,
        focusNode: focusNode,
        onSubmitted: (value) {},
        autofocus: false,
        obscureText: obscure ? true : false,
        decoration: InputDecoration(
            suffixIcon: suffixicon,
            icon: Icon(
              leading,
              color: color,
            ),
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: FCITextStyle().normal20(),
            isDense: true),
        style: FCITextStyle().normal20(),
      ),
    );
  }
}
