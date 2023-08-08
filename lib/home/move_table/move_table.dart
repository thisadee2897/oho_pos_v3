import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/home/move_table/model_data_move_table/autocomplete_new_table.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'model_data_move_table/model_data_move_table.dart';

class MoveTable extends StatefulWidget {
  final String? branchId;
  final String? companyId;
  final String? empId;
  const MoveTable({
    Key? key,
    required this.branchId,
    required this.companyId,
    required this.empId,
  }) : super(key: key);

  @override
  _MoveTableState createState() => _MoveTableState();
}

class _MoveTableState extends State<MoveTable> {
  bool loading = true;
  final textCtl = TextEditingController();
  clearTextInput() {
    textCtl.clear();
  }

  String? newTableName;
  String? oldTableName;
  String? oldTableId;
  String? newTableId;
  String? orderhdId;
  String remark = 'ไม่มีหมายเหตุ';

  List<OrderDataInMoveTableModel> orderData = [];
  List<OrderDataInMoveTableModel> oldTableData = [];
  List<NewTable> newTableData = [];
  List reasonMoveTableData = [];
  int reasonMoveTableId = 0;

  fetchOrderDataInMoveTable() async {
    final url = '${UrlApi().url}get_order_data_in_move_table';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        orderData = orderDataInMoveTableModelFromJson(
          jsonEncode(response.data),
        );
        loading = false;
        remark = 'ไม่มีหมายเหตุ';
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  Future<List<NewTable>> autocompleteNewTable(String query) async {
    final url = '${UrlApi().url}autocomplete_empty_table';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        newTableData = newTableModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
    return newTableData.where((tableName) {
      final tableNames = tableName.tableName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return tableNames.contains(queryLower);
    }).toList();
  }

  Future<List<OrderDataInMoveTableModel>> autocompleteOldTable(
      String query) async {
    final url = '${UrlApi().url}get_order_data_in_move_table';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        oldTableData =
            orderDataInMoveTableModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
    return oldTableData.where((tableName) {
      final tableNames = tableName.tableName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return tableNames.contains(queryLower);
    }).toList();
  }

  moveTheTable(String oldTableId, String newTableId, String orderhdId) async {
    final url = '${UrlApi().url}move_table';
    final body = jsonEncode({
      'old_table_id': oldTableId,
      'new_table_id': newTableId,
      'orderhd_id': orderhdId,
      'emp_id': widget.empId,
      'remark': remark,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'reason_move_table_id': reasonMoveTableId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data['status'] == 1) {
      alertSuccess();
      setState(() {
        reasonMoveTableId = 0;
        newTableName = null;
        oldTableName = null;
        loading = false;
      });
      fetchOrderDataInMoveTable();
    } else {
      AlertDialogs().alertWarning(context, 'โต๊ะไม่ว่าง !!');
      setState(() {
        reasonMoveTableId = 0;
        newTableName = null;
        oldTableName = null;
        loading = false;
      });
      fetchOrderDataInMoveTable();
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  fetchReasonMoveTableData() async {
    final url = '${UrlApi().url}get_reason_move_table_data';
    final body = jsonEncode({
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        reasonMoveTableData = response.data;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchReasonMoveTableData();
    fetchOrderDataInMoveTable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: orderData.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () {
                return fetchOrderDataInMoveTable();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TypeAheadField<OrderDataInMoveTableModel>(
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      textFieldConfiguration: TextFieldConfiguration(
                        style: const TextStyle(fontFamily: 'Kanit'),
                        autofocus: false,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: BorderSide(
                                color: MyStyle().lightColor, width: 1),
                          ),
                          label: Text(
                            'ค้นหาหมายเลขโต๊ะ',
                            style: FontStyle().h2Style(0xff778899, 16),
                          ),
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                        ),
                      ),
                      suggestionsCallback: autocompleteOldTable,
                      minCharsForSuggestions: 1,
                      itemBuilder:
                          (context, OrderDataInMoveTableModel suggestion) {
                        return ListTile(
                          title: Text(
                            '${suggestion.tableName}',
                            style: FontStyle().h2Style(0xff000000, 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ออเดอร์ ${suggestion.orderDocuno}',
                                style: FontStyle().h2Style(0, 14),
                              ),
                              Text(
                                '${suggestion.firstName} ${suggestion.lastName}',
                                style: FontStyle().h2Style(0, 14),
                              )
                            ],
                          ),
                        );
                      },
                      onSuggestionSelected:
                          (OrderDataInMoveTableModel suggestion) {
                        setState(() {
                          orderhdId = suggestion.orderhdId;
                          oldTableId = suggestion.tableId;
                          oldTableName = '${suggestion.tableName}';
                        });
                        moveTableAlert(orderhdId!, oldTableId!);
                      },
                      noItemsFoundBuilder: (contex) => Center(
                        child: Text('ไม่พบออเดอร์ในโต๊ะที่ค้นหา',
                            style: FontStyle().h2Style(0, 20)),
                      ),
                    ),
                  ),
                  Expanded(child: listOrdersInMoveTable())
                ],
              ),
            )
          : const Center(
              child: Text(
                'ไม่มีรายการออเดอร์',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
    );
  }

  Widget listOrdersInMoveTable() {
    return ListView.builder(
      itemCount: orderData.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: ListTile(
            hoverColor: const Color(0xff4fc3f7),
            title: Text(
              '${orderData[index].tableName}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${orderData[index].orderDocuno}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                    '${orderData[index].firstName} ${orderData[index].lastName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ))
              ],
            ),
            trailing: Text('${orderData[index].zoneName}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                )),
            onTap: () {
              setState(() {
                orderhdId = orderData[index].orderhdId;
                oldTableId = orderData[index].tableId;
                oldTableName = orderData[index].tableName;
              });
              moveTableAlert(orderhdId!, oldTableId!);
            },
          ),
        );
      },
    );
  }

  moveTableAlert(String orderhdId, String oldTableId) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ค้นหาโต๊ะที่ต้องการย้าย',
                style: FontStyle().h2Style(0xff000000, 18),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 5),
                child: TypeAheadField<NewTable>(
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  textFieldConfiguration: TextFieldConfiguration(
                    style: const TextStyle(fontFamily: 'Kanit'),
                    controller: textCtl,
                    autofocus: false,
                    decoration: InputDecoration(
                      label: newTableName != null
                          ? Text(
                              newTableName!,
                              style: FontStyle().h2Style(0xff778899, 16),
                            )
                          : Text(
                              'ค้นหาโต๊ะ',
                              style: FontStyle().h2Style(0xff778899, 16),
                            ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide:
                            BorderSide(color: MyStyle().lightColor, width: 1),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                      ),
                    ),
                  ),
                  suggestionsCallback: autocompleteNewTable,
                  minCharsForSuggestions: 1,
                  itemBuilder: (context, NewTable suggestion) {
                    return ListTile(
                      title: Text(
                        '${suggestion.tableName}',
                        style: FontStyle().h2Style(0xff000000, 16),
                      ),
                    );
                  },
                  onSuggestionSelected: (NewTable suggestion) {
                    clearTextInput();
                    setState(() {
                      newTableName = '${suggestion.tableName}';
                      newTableId = suggestion.tableId;
                    });
                  },
                  noItemsFoundBuilder: (contex) => Center(
                    child: Text('ไม่พบโต๊ะที่ค้นหา',
                        style: FontStyle().h2Style(0, 14)),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'เลือกเหตุผลในการย้ายโต๊ะ',
                      style: FontStyle().h2Style(0xff000000, 16),
                    ),
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    spacing: 50,
                    runSpacing: 5,
                    runAlignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: List.generate(
                      reasonMoveTableData.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 0, top: 5),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Radio(
                                  value: int.parse(
                                    reasonMoveTableData[index]
                                            ['master_reason_move_table_id']
                                        .toString(),
                                  ),
                                  groupValue: reasonMoveTableId,
                                  onChanged: (values) {
                                    setState(() {
                                      reasonMoveTableId =
                                          int.parse(values.toString());
                                    });
                                  },
                                ),
                                Text(
                                  reasonMoveTableData[index]
                                      ['master_reason_move_table_name'],
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
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
          color: Colors.transparent,
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            if (newTableName == null) {
              AlertDialogs()
                  .alertWarning(context, 'โปรดระบุโต๊ะที่ต้องการย้าย');
              return;
            }
            if (reasonMoveTableId == 0) {
              AlertDialogs()
                  .alertWarning(context, 'โปรดเลือกเหตุผลในการย้ายโต๊ะ');
              return;
            }
            Navigator.of(context).pop();
            moveTheTable(oldTableId, newTableId!, orderhdId);
            // confirmMoveTableAlert(
            //   oldTableName,
            //   newTableName,
            //   oldTableId,
            //   newTableId,
            //   orderhdId,
            // );
          },
        )
      ],
    ).show();
  }

  confirmMoveTableAlert(
    oldTableName,
    newTableName,
    oldTableId,
    newTableId,
    orderhdId,
  ) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Text(
                'ย้ายโต๊ะ',
                style: FontStyle().h2Style(0xff000000, 18),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'จาก ${oldTableName}',
                          style: FontStyle().h2Style(0xff000000, 18),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_right,
                      size: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          'ไปยัง ${newTableName}',
                          style: FontStyle().h2Style(0xff000000, 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: MyStyle().lightColor, width: 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: 'หมายเหตุ:',
                  ),
                  onChanged: (value) {
                    setState(() {
                      remark = value;
                      if (remark == '') {
                        remark = 'ไม่มีหมายเหตุ';
                      }
                    });
                  },
                ),
              ),
            ],
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
          color: Colors.transparent,
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            if (newTableId != null) {
              Navigator.of(context).pop();
              moveTheTable(oldTableId, newTableId, orderhdId);
            }
          },
        )
      ],
    ).show();
  }

  alertSuccess() {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.success,
      content: Text(
        'ย้ายโต๊ะสำเร็จ',
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          width: 120,
          radius: const BorderRadius.all(Radius.circular(30)),
        )
      ],
    ).show();
  }
}
