import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AlertDialogs {
  Future snackBar(context, String desc) async {
    return SnackBar(
      content: Text(desc),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.black54,
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {
          // Hide the snackbar before its duration ends
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
  }

  alertWarning(context, String desc) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.warning,
      content: Text(
        desc,
        style: FontStyle().h2Style(0xff000000, 16),
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          child: Text(
            "ตกลง",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () => Navigator.pop(context),
          width: 120,
          radius: const BorderRadius.all(Radius.circular(30)),
        )
      ],
    ).show();
  }

  alertSuccess(context, String desc) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.success,
      content: Text(
        desc,
        style: FontStyle().h2Style(0xff000000, 16),
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          child: Text(
            "ตกลง",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () => Navigator.pop(context),
          width: 120,
          radius: const BorderRadius.all(
            Radius.circular(30),
          ),
        )
      ],
    ).show();
  }

  alertError(context, String desc) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.error,
      content: Text(
        desc,
        style: FontStyle().h2Style(0xff000000, 16),
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          child: Text(
            "ตกลง",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () => Navigator.pop(context),
          width: 120,
          radius: const BorderRadius.all(Radius.circular(30)),
        )
      ],
    ).show();
  }

  progressDialog(context, bool loading) {
    if (loading == true) {
      EasyLoading.show(status: 'โปรดรอ...');
    } else {
      EasyLoading.dismiss();
    }
  }
}
