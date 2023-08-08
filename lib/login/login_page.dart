import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/helper/helper.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/select_company/select_company.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:oho_pos_v3/version/version.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Size? screen;
  String? username;
  String? password;
  bool statusRedEye = true;
  bool loading = true;

  login() async {
    if (username == null || username == "") {
      AlertDialogs().alertWarning(context, 'กรุณากรอก Username');
      return;
    }
    if (password == null || password == "") {
      AlertDialogs().alertWarning(context, 'กรุณากรอก Password');
      return;
    }
    final url = '${UrlApi().url}login';
    final body = jsonEncode({
      'username': username,
      'password': password,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty && response.statusCode == 200) {
      setState(() {
        loading = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SelectCompany()),
          (route) => false);
      Helper().setStored('userInformation', jsonEncode(response.data));
    } else if (response.data.isEmpty && response.statusCode == 200) {
      AlertDialogs().alertError(context, 'Username/Password ไม่ถูกต้อง');
      setState(() {
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/top_icon.png',
              width: 200,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/images/bottom_left.png',
              width: 150,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bottom_right.png',
              width: 200,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showLogo(screen),
                Text(
                  'เข้าสู่ระบบ',
                  style: FontStyle().h1Style(0xff0b75c3, 30),
                ),
                inputUsername(screen),
                inputPassword(screen),
                buildLogin(screen),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    Version().version,
                    style: FontStyle().h2Style(0xff000000, 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      Text(
                        '© Copyright Tech Care Solution.',
                        style: FontStyle().h2Style(0xff000000, 16),
                      ),
                      Text(
                        'All Rights Reserved',
                        style: FontStyle().h2Style(0xff000000, 16),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container showLogo(size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Image.asset(
        'assets/images/oho_logo.png',
        width: size.width < 800 ? size.width * 0.3 : 150,
      ),
    );
  }

  Container inputUsername(size) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: size.width < 800 ? size.width * 0.8 : 600,
      decoration: BoxDecoration(
        border: Border.all(color: MyStyle().darkColor, width: 1),
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(35),
      ),
      child: TextField(
        inputFormatters: [
          UpperCaseTextFormatter(),
        ],
        onChanged: (value) {
          username = value.trim().toUpperCase();
        },
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(color: MyStyle().darkColor, fontFamily: 'Kanit'),
        decoration: const InputDecoration(
            hintStyle: TextStyle(
              color: Colors.black45,
              fontFamily: 'Kanit',
            ),
            hintText: 'Username:',
            prefixIcon: Icon(
              Icons.person,
            ),
            border: InputBorder.none),
      ),
    );
  }

  Container inputPassword(size) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: size.width < 800 ? size.width * 0.8 : 600,
      decoration: BoxDecoration(
        border: Border.all(color: MyStyle().darkColor, width: 1),
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(35),
      ),
      child: TextField(
        obscureText: statusRedEye,
        onChanged: (value) {
          password = value.trim();
        },
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(color: MyStyle().darkColor, fontFamily: 'Kanit'),
        decoration: InputDecoration(
            suffixIcon: IconButton(
              // color: MyStyle().darkColor,
              icon: statusRedEye
                  ? const Icon(
                      Icons.remove_red_eye,
                    )
                  : const Icon(
                      Icons.remove_red_eye_outlined,
                    ),
              onPressed: () {
                setState(() {
                  statusRedEye = !statusRedEye;
                });
              },
            ),
            hintStyle: const TextStyle(
              color: Colors.black45,
              fontFamily: 'Kanit',
            ),
            hintText: 'Password:',
            prefixIcon: const Icon(
              Icons.lock,
            ),
            border: InputBorder.none),
      ),
    );
  }

  Container buildLogin(size) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(top: 16.0),
      height: 60,
      width: size.width < 800 ? size.width * 0.80 : 600,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // primary: const Color(0xff4fc3f7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
        ),
        onPressed: () {
          login();
        },
        child: Text(
          'LOGIN',
          style: FontStyle().h2Style(0xffFFFFFF, 20),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
