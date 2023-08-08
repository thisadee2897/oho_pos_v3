import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FontStyle {
  TextStyle h1Style(int textColor, double fontSize) => TextStyle(
        fontFamily: 'KanitBold',
        fontSize: fontSize,
        color: textColor != 0 ? Color(textColor) : const Color(0xff484848),
      );
  TextStyle h2Style(int textColor, double fontSize) => TextStyle(
        fontFamily: 'Kanit',
        fontSize: fontSize,
        color: textColor != 0 ? Color(textColor) : const Color(0xff484848),
      );
  TextStyle h3Style(int textColor, double fontSize) => TextStyle(
        fontFamily: 'Kanit',
        fontSize: fontSize,
        color: textColor != 0 ? Color(textColor) : const Color(0xff484848),
      );
}
