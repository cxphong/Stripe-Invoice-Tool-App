import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight fontWeight;
  final String fontFamily;
  final TextAlign? align;

  const CustomText(
      {Key? key,
      required this.text,
      this.color,
      this.fontSize,
      this.fontWeight = FontWeight.normal,
      this.fontFamily = 'Urbanist',
      this.align = TextAlign.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
        ),
        textAlign: align);
  }
}
