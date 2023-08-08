// ignore_for_file: use_build_context_synchronously, unnecessary_import

import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart' as audioplayer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/helper/helper.dart';
import 'package:oho_pos_v3/home/restore_order/restore_order.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/login/login_page.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:oho_pos_v3/version/version.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'check_ score/check_score.dart';
import 'list_tables/list_tables.dart';
import 'move_table/move_table.dart';
import 'order_history/order_history.dart';
import 'package:badges/badges.dart' as badges;

class Home extends StatefulWidget {
  final String? userName;
  final String? branchId;
  final String? branchName;
  final String? branchPrefix;
  final String? empId;
  final String? companyId;
  final String? userId;
  final bool? menuActionActive;
  final bool? buffetActive;
  final bool? alacarteActive;
  const Home({
    Key? key,
    this.branchId,
    this.branchName,
    this.branchPrefix,
    this.empId,
    this.userName,
    this.companyId,
    this.userId,
    this.menuActionActive,
    this.buffetActive,
    this.alacarteActive,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  static List<Widget> widgetOptions = [];
  List requestData = [];
  bool loading = true;
  audioplayer.AudioPlayer audioPlayer = audioplayer.AudioPlayer();
  int countRequest = 0;
  late Timer _timer;
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  addWidget() {
    setState(() {
      widgetOptions = [
        ListTables(
          branchId: widget.branchId,
          branchPrefix: widget.branchPrefix,
          empId: widget.empId,
          companyId: widget.companyId,
          menuActionActive: widget.menuActionActive,
          buffetActive: widget.buffetActive,
          userId: widget.userId,
          alacarteActive: widget.alacarteActive,
        ),
        MoveTable(
          branchId: widget.branchId,
          companyId: widget.companyId,
          empId: widget.empId,
        ),
        RestoreOrder(
          branchId: widget.branchId,
          companyId: widget.companyId,
          empId: widget.empId,
        ),
        CheckScore(
          companyId: widget.companyId,
        ),
        OrderHistory(
          branchId: widget.branchId,
          companyId: widget.companyId,
        ),
      ];
    });
  }

  Future fetchRequestData() async {
    final url = '${UrlApi().url}get_request_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, false);
    if (response.statusCode == 200) {
      if (response.data.length > countRequest) {
        playAudio();
      }
      if (mounted) {
        setState(() {
          loading = false;
          countRequest = response.data.length;
          requestData = response.data;
          addWidget();
        });
      }
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future acknowledgeRequest(String requestId, String orderhdId) async {
    final url = '${UrlApi().url}acknowledge_request';
    final body = jsonEncode({
      'request_id': requestId,
      'orderhd_id': orderhdId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
      });
      fetchRequestData();
    }
    AlertDialogs().progressDialog(context, loading);
  }

  // Future playAudio() async {
  //   final player = audioplayer.AudioCache(prefix: 'assets/sounds/');
  //   final path = await player.load('Buzzer.mp3');
  //   await audioPlayer.play(path.path as audioplayer.Source, isLocal: true);
  // }
  Future playAudio() async {
  final player = audioplayer.AudioCache(prefix: 'assets/sounds/');
  final path = await player.load('Buzzer.mp3');
  await audioPlayer.play(path.path as audioplayer.Source);
}



  @override
  void initState() {
    fetchRequestData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchRequestData();
    });
    addWidget();
    super.initState();
  }

  @override
  void dispose() {
    _timer.isActive;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Row(
          children: [
            showLogo(),
            const Padding(
              padding: EdgeInsets.only(left: 0),
              child: Text(
                'OHO POS',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (requestData.isNotEmpty) {
                dialogRequest();
              }
            },
            icon: badges.Badge(
              // shape: BadgeShape.circle,
              position: badges.BadgePosition.topEnd(),
              badgeContent: Text(
                '${requestData.length}',
                style: FontStyle().h2Style(0xffFFFFFF, 14),
              ),
              // borderRadius: BorderRadius.circular(100),
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              menuAlert();
            },
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            label: Text(
              Version().version,
              style: const TextStyle(color: Colors.white),
            ),
          )
          // IconButton(
          //   icon: const Icon(Icons.account_circle),
          //   tooltip: '',
          //   onPressed: () {
          //     menuAlert();
          //   },
          // ),
        ],
      ),
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        child: BottomNavigationBar(
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Kanit',
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 12,
          ),
          backgroundColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.table_chart,
              ),
              label: 'โต๊ะ',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.remove,
              ),
              label: 'ย้ายโต๊ะ',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.timelapse,
              ),
              label: 'คืนสถานะ',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.check,
              ),
              label: 'เช็คเเต้ม',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.history_edu,
              ),
              label: 'ประวัติ',
              backgroundColor: Colors.white,
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  dialogRequest() {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  requestData.length,
                  (index) {
                    return ListTile(
                      title: Text(
                          '${index + 1}. โต๊ะ ${requestData[index]['master_table_name']}'),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: Text(
                            '${requestData[index]['master_request_name']}'),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          acknowledgeRequest(
                            requestData[index]['orderhd_request_id'],
                            requestData[index]['orderhd_id'],
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('รับทราบ'),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'ปิด',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: const Color(0xff4fc3f7),
        ),
      ],
    ).show();
  }

  Container showLogo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Image.asset(
        'assets/images/logo-2.png',
        width: 50,
      ),
    );
  }

  menuAlert() {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ผู้ใช้ : ${widget.userName}'),
          Text('สาขา : ${widget.branchName}'),
        ],
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          child: TextButton.icon(
            onPressed: () {
              Helper().setStored('userInformation', '');
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false);
            },
            icon: const Icon(
              Icons.logout,
              color: Color(0xffFFFFFF),
            ),
            label: Text(
              "ออกจากระบบ",
              style: FontStyle().h2Style(0xffFFFFFF, 16),
            ),
          ),
          onPressed: () {
            Helper().setStored('userInformation', '');
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false);
          },
          color: const Color(0xff4fc3f7),
        ),
      ],
    ).show();
  }
}
