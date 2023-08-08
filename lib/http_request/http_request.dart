import 'package:dio/dio.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class HttpRequests {
  httpRequest(url, body, context, loading) async {
    AlertDialogs().progressDialog(context, loading);
    final response = await Dio().post(url, data: body).catchError((err) {
      AlertDialogs().progressDialog(context, false);
      snackBar(context, 'เกิดข้อผิดพลาดบางอย่าง เชื่อมต่ออีกครั้ง !');
    }).timeout(const Duration(seconds: 10), onTimeout: () async {
      return AlertDialogs().progressDialog(context, false);
      // return await snackBar(context, 'การเชื่อมต่อล่าช้า !');
    });
    return response;
  }

  Future snackBar(context, String desc) async {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(desc),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.black54,
        action: SnackBarAction(
          label: 'ตกลง',
          onPressed: () {
            // Hide the snackbar before its duration ends
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Phoenix.rebirth(context);
          },
        ),
      ),
    );
  }
}
