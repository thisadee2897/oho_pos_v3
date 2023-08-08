import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/btn_logout/btn_logout.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/helper/helper.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/login/login_page.dart';
import 'package:oho_pos_v3/select_branch/select_branch.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:page_transition/page_transition.dart';
import 'model_data_select_company/model_data_select_company.dart';

class SelectCompany extends StatefulWidget {
  const SelectCompany({Key? key}) : super(key: key);

  @override
  _SelectCompanyState createState() => _SelectCompanyState();
}

class _SelectCompanyState extends State<SelectCompany> {
  bool loading = true;
  String empId = '';
  String userId = '';
  String userName = '';
  String companyId = '';
  List<CompanyDataModel> companyData = [];

  getUserData() async {
    var pref = await Helper().getStored('userInformation');
    if (pref == '' || pref == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false);
    } else {
      List userData = jsonDecode(pref);
      setState(() {
        empId = userData[0]['emp_employeemasterid'].toString();
        userId = userData[0]['user_login_id'].toString();
        userName = userData[0]['firstname'] + ' ' + userData[0]['lastname'];
      });
      fetchCompanyhData(userId);
    }
  }

  fetchCompanyhData(String userId) async {
    final url = '${UrlApi().url}get_company_data';
    final body = jsonEncode({
      'user_id': userId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        companyData = companyModelFromJson(jsonEncode(response.data));
      });

      if (companyData.length == 1) {
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.bottomCenter,
              child: SelectBranch(
                userId: userId,
                empId: empId,
                userName: userName,
                companyId: companyData[0].companyId.toString(),
                companyName: companyData[0].companyName,
              ),
            ),
            (route) => false);
      }
    }
    AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'เลือกบริษัท',
          style: FontStyle().h1Style(0xffFFFFFF, 20),
        ),
      ),
      body: companyData.isEmpty
          ? const Center(
              child: Text(
                'ไม่พบข้อมูลบริษัท',
                style: TextStyle(fontSize: 20),
              ),
            )
          : Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.grey[200],
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 20,
                    runAlignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: List.generate(
                      companyData.length,
                      (index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                            child: Column(
                              children: [
                                showBranch(),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(companyData[index].companyName!,
                                      style:
                                          FontStyle().h2Style(0xff4fc3f7, 16)),
                                ),
                                btnMain(
                                  companyData[index].companyId!.toString(),
                                  companyData[index].companyName!,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: const BtnLogout(),
    );
  }

  Widget showBranch() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Image.asset(
        'assets/images/store.png',
        width: 40,
        height: 40,
      ),
    );
  }

  Container btnMain(String companyId, String companyName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
      ),
      height: 50,
      width: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: const Color(0xff4fc3f7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SelectBranch(
                userId: userId,
                empId: empId,
                userName: userName,
                companyId: companyId,
                companyName: companyName,
              ),
            ),
          );
        },
        child: Text(
          'เลือก',
          style: FontStyle().h2Style(0xffFFFFFF, 14),
        ),
      ),
    );
  }
}
