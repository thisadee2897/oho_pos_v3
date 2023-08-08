import 'package:flutter/material.dart';
import 'package:oho_pos_v3/helper/helper.dart';
import 'package:oho_pos_v3/login/login_page.dart';
import 'package:oho_pos_v3/style/style_colors.dart';

class BtnLogout extends StatelessWidget {
  const BtnLogout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Helper().setStored('userInformation', '');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
            (route) => false);
      },
      child: const Icon(Icons.logout),
      backgroundColor: MyStyle().prinaryColor,
      hoverColor: Colors.blue,
      tooltip: 'ออกจากระบบ',
    );
  }
}
