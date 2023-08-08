import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CheckScore extends StatefulWidget {
  final String? companyId;
  const CheckScore({Key? key, required this.companyId}) : super(key: key);

  @override
  State<CheckScore> createState() => _CheckScoreState();
}

class _CheckScoreState extends State<CheckScore> {
  bool loading = true;
  String year = DateFormat('y').format(DateTime.now());
  final textCtl = TextEditingController();
  String phoneNumber = '';
  ScrollController? _scrollController;
  clearTextInput() {
    textCtl.clear();
  }

  List scoreData = [];
  List latestFoodListData = [];

  fetchScoreData() async {
    final url = '${UrlApi().url}get_score_data';
    final body = jsonEncode({
      'company_id': widget.companyId,
      'phone_number': phoneNumber,
      'year': year,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);

    if (response.data.isNotEmpty) {
      setState(() {
        scoreData = response.data;
        loading = false;
      });
      showData(
        '${scoreData[0]['arcustomer_name']}',
        '${scoreData[0]['point_quantity']}',
        '${scoreData[0]['arcustomer_code']}',
      );
    } else {
      AlertDialogs().alertWarning(context, 'ไม่พบข้อมูล');
      setState(() {
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchLatestFoodListData() async {
    final url = '${UrlApi().url}get_latest_foodlist_data';
    final body = jsonEncode({
      'company_id': widget.companyId,
      'phone_number': phoneNumber,
      'year': year,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    setState(() {
      latestFoodListData = response.data;
    });
    fetchScoreData();
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 500,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'ตรวจสอบเเต้มคงเหลือ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                inputPhoneNumber(),
                btnSearch(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container inputPhoneNumber() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: 300,
      child: TextField(
        controller: textCtl,
        maxLength: 10,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            phoneNumber = value.trim();
          });
        },
        textAlignVertical: TextAlignVertical.bottom,
        style: TextStyle(color: MyStyle().darkColor, fontFamily: 'Kanit'),
        decoration: InputDecoration(
          hintStyle: const TextStyle(
            fontFamily: 'Kanit',
          ),
          hintText: 'หมายเลขโทรศัพท์:',
          prefixIcon: Icon(
            Icons.search,
            color: MyStyle().darkColor,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              clearTextInput();
              setState(() {
                phoneNumber = '';
              });
            },
            icon: const Icon(
              Icons.cancel,
            ),
          ),
        ),
      ),
    );
  }

  Container btnSearch() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(top: 16.0),
      height: 60,
      width: 180,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: const Color(0xff4fc3f7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
        ),
        onPressed: () {
          if (phoneNumber == '') {
            AlertDialogs().alertWarning(
                context, 'โปรดระบุหมายเลขโทรศัพท์เพื่อค้นหาข้อมูล');
            return;
          }
          fetchLatestFoodListData();
        },
        child: const Text(
          'ค้นหา',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xffFFFFFF),
          ),
        ),
      ),
    );
  }

  showData(String name, String point, String code) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: [
          Text(
            'ชื่อลูกค้า : ${name}',
            style: FontStyle().h2Style(0xff000000, 16),
          ),
          Text(
            'Customer Code : ${code}',
            style: FontStyle().h2Style(0xff000000, 16),
          ),
          Text(
            'เเต้มคงเหลือ : ${point}',
            style: FontStyle().h2Style(0xff4caf50, 16),
          ),
          Text(
            'รายการอาหารที่ทานล่าสุด',
            style: FontStyle().h2Style(0xff000000, 16),
          ),
          latestFoodListData.isNotEmpty
              ? SizedBox(
                  child: Scrollbar(
                    controller: _scrollController,
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children:
                            List.generate(latestFoodListData.length, (index) {
                          return ListTile(
                            title: Text(
                              '${index + 1}. ${latestFoodListData[index]['saledt_master_product_billname']}',
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                )
              : const Text(
                  'ไม่มีรายการอาหารที่ทานล่าสุด',
                ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "ตกลง",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
          radius: const BorderRadius.all(Radius.circular(30)),
        )
      ],
    ).show();
  }
}
