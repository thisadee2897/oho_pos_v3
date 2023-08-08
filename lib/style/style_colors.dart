import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MyStyle {
  Color darkColor = const Color(0xff0b75c3);
  Color prinaryColor = const Color(0xff039be5);
  Color lightColor = const Color(0xff4fc3f7);
  Color color = const Color(0xff81d4fa);
  MaterialColor kToDark = const MaterialColor(
    0xff039be5,
    <int, Color>{
      50: Color(0xffffc4ff), //10%
      100: Color(0xffb74c3a), //20%
      200: Color(0xffa04332), //30%
      300: Color(0xff89392b), //40%
      400: Color(0xff733024), //50%
      500: Color(0xff5c261d), //60%
      600: Color(0xff451c16), //70%
      700: Color(0xff2e130e), //80%
      800: Color(0xff170907), //90%
      900: Color(0xff000000), //100%
    },
  );

  AlertStyle alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
      side: const BorderSide(
        color: Colors.grey,
      ),
    ),
    animationDuration: const Duration(milliseconds: 200),
  );

  MyStyle();
}
