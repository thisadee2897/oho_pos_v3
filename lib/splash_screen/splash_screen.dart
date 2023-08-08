import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/select_company/select_company.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:upgrader/upgrader.dart';
import '../helper/helper.dart';
import '../login/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PackageInfo? packageInfo;
  bool loading = true;
  final url =
      'https://play.google.com/store/apps/details?id=com.techcaresolution.OHO_ORDERING';

  getDataUser() async {
    var pref = await Helper().getStored('userInformation');
    if (pref != "" && pref != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SelectCompany()),
          (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    }
  }

  checkVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    final url = '${UrlApi().url}check_version';
    final body = jsonEncode({});
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data['version'] == packageInfo?.version) {
      getDataUser();
      setState(() {
        loading = false;
      });
    } else {
      confirmUpdate();
      setState(() {
        loading = false;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  void launchURL() async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  void initState() {
    // getDataUser();
    if (defaultTargetPlatform == TargetPlatform.android) {
      checkVersion();
    } else {
      getDataUser();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/oho_logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }

  confirmUpdate() {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.warning,
      content: Column(
        children: [
          Text(
            'มีเวอร์ชั่นที่ต้องอัพเดท !!',
            style: FontStyle().h2Style(0xff000000, 16),
          ),
        ],
      ),
      closeFunction: () {
        SystemNavigator.pop();
      },
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          onPressed: () {
            SystemNavigator.pop();
          },
          color: Colors.transparent,
        ),
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          child: Text(
            "อัพเดท",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            SystemNavigator.pop();
            launchURL();
          },
        )
      ],
    ).show();
  }
}
