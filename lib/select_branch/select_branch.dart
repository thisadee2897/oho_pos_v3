import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/btn_logout/btn_logout.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/home/home.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/select_branch/model_data_select_branch/model_data_branch.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:page_transition/page_transition.dart';

class SelectBranch extends StatefulWidget {
  final String? empId;
  final String? userId;
  final String? userName;
  final String? companyId;
  final String? companyName;
  const SelectBranch({
    Key? key,
    required this.empId,
    required this.companyId,
    required this.userId,
    required this.userName,
    required this.companyName,
  }) : super(key: key);

  @override
  _SelectBranchState createState() => _SelectBranchState();
}

class _SelectBranchState extends State<SelectBranch> {
  bool loading = true;
  List<BranchDataModel> branchData = [];
  String branchId = '';
  String branchPrefix = '';
  bool? menuActionActive;

  // fetchDataAuthority() async {
  //   final url = '${UrlApi().url}get_data_authority';
  //   final body = jsonEncode({
  //     'user_id': widget.userId,
  //     'company_id': widget.companyId,
  //   });
  //   final response = await HttpRequests().httpRequest(url, body, context, true);

  //   if (response.data.isNotEmpty) {
  //     setState(() {
  //       menuActionActive = response.data[0]['role_group_menu_action_active'];
  //       loading = false;
  //     });
  //     fetchBranchData();
  //   } else {
  //     setState(() {
  //       menuActionActive = false;
  //       loading = false;
  //     });
  //     fetchBranchData();
  //   }
  //   await AlertDialogs().progressDialog(context, loading);
  // }

  fetchBranchData() async {
    final url = '${UrlApi().url}get_branch_data';
    final body = jsonEncode({
      'user_id': widget.userId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        branchData = branchModelFromJson(jsonEncode(response.data));
      });
      if (branchData.length == 1) {
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.bottomCenter,
              child: Home(
                branchId: branchData[0].branchId,
                branchName: branchData[0].branchName,
                branchPrefix: branchData[0].branchPrefix,
                empId: widget.empId,
                userName: widget.userName,
                companyId: widget.companyId,
                menuActionActive: menuActionActive,
                buffetActive: branchData[0].buffetActive,
                userId: widget.userId,
                alacarteActive: branchData[0].alacarteActive,
              ),
            ),
            (route) => false);
      }
    }
    AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchBranchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          widget.companyName!,
          style: FontStyle().h1Style(0xffFFFFFF, 20),
        ),
      ),
      body: branchData.isEmpty
          ? const Center(
              child: Text(
                'ไม่พบข้อมูลสาขา',
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
                      branchData.length,
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
                                  child: Text(
                                    branchData[index].branchName!,
                                    style: FontStyle().h2Style(0xff4fc3f7, 16),
                                  ),
                                ),
                                btnMain(
                                  branchData[index].branchId!,
                                  branchData[index].branchName!,
                                  branchData[index].branchPrefix!,
                                  branchData[index].branchTypeId!,
                                  branchData[index].buffetActive!,
                                  branchData[index].alacarteActive!,
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

  Container btnMain(String branchId, String branchName, String branchPrefix,
      int branchTypeId, bool buffetActive, bool alacarteActive) {
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
              builder: (context) => Home(
                branchId: branchId,
                branchName: branchName,
                branchPrefix: branchPrefix,
                empId: widget.empId,
                userName: widget.userName,
                companyId: widget.companyId,
                menuActionActive: menuActionActive,
                buffetActive: buffetActive,
                userId: widget.userId,
                alacarteActive: alacarteActive,
              ),
            ),
          );
        },
        child: Text(
          'ไปยังสาขา',
          style: FontStyle().h2Style(0xffFFFFFF, 14),
        ),
      ),
    );
  }
}
