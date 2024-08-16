import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration inputStyle({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String fontFamily = 'Urbanist',
    Color? labelColor,
    Color? hintColor,
    Color? borderColor,
    double? borderWidth,
    Color? fillColor,
    bool? isFilled,
    EdgeInsetsGeometry? contentPadding
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: labelColor,
        fontFamily: fontFamily,
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: hintColor,
        fontFamily: fontFamily,
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: borderColor) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: borderColor) : null,
      // enabledBorder: OutlineInputBorder(
      //   borderSide: BorderSide(
      //     color: borderColor,
      //     width: borderWidth,
      //   ),
      //   borderRadius: BorderRadius.circular(8.0),
      // ),
      // focusedBorder: OutlineInputBorder(
      //   borderSide: BorderSide(
      //     color: borderColor,
      //     width: borderWidth,
      //   ),
      //   borderRadius: BorderRadius.circular(8.0),
      // ),
      // errorBorder: OutlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Colors.red,
      //     width: borderWidth,
      //   ),
      //   borderRadius: BorderRadius.circular(8.0),
      // ),
      // focusedErrorBorder: OutlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Colors.red,
      //     width: borderWidth,
      //   ),
      //   borderRadius: BorderRadius.circular(8.0),
      // ),
      // filled: isFilled,
      // fillColor: fillColor,
      contentPadding: contentPadding
    );
  }
}
