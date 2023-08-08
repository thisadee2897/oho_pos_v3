import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'model_data_restore_order/model_data_restore_order.dart';

class RestoreOrder extends StatefulWidget {
  final String? branchId;
  final String? companyId;
  final String? empId;
  const RestoreOrder({
    Key? key,
    required this.branchId,
    required this.companyId,
    required this.empId,
  }) : super(key: key);

  @override
  State<RestoreOrder> createState() => _RestoreOrderState();
}

class _RestoreOrderState extends State<RestoreOrder> {
  bool loading = true;
  List<RestoreOrderModel> restoreOrderData = [];
  String remark = 'ไม่มีหมายเหตุ';
  List reasonChangeStatusOrderData = [];
  int reasonChangeStatusOrderId = 0;
  fetchOrderHistoryData() async {
    final url = '${UrlApi().url}get_order_restore_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        remark = 'ไม่มีหมายเหตุ';
        restoreOrderData = restoreOrderModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future<List<RestoreOrderModel>> autocompleteTableOrder(String query) async {
    final url = '${UrlApi().url}get_order_restore_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        loading = false;
        restoreOrderData = restoreOrderModelFromJson(jsonEncode(response.data));
      });
    }
    AlertDialogs().progressDialog(context, loading);
    return restoreOrderData.where((order) {
      final tableName = order.tableName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return tableName.contains(queryLower);
    }).toList();
  }

  fetchReasonChangeStatusOrderData() async {
    final url = '${UrlApi().url}get_reason_change_status_order_data';
    final body = jsonEncode({
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        reasonChangeStatusOrderData = response.data;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  restoreOrder(String tableId, String orderhdId) async {
    final url = '${UrlApi().url}restore_order';
    final body = jsonEncode({
      'table_id': tableId,
      'orderhd_id': orderhdId,
      'emp_id': widget.empId,
      'remark': remark,
      'reason_change_status_order_id': reasonChangeStatusOrderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data[0]['status'] == true) {
      AlertDialogs().alertSuccess(context, 'คืนสถานะสำเร็จ');
      setState(() {
        reasonChangeStatusOrderId = 0;
        fetchOrderHistoryData();
        loading = false;
      });
    } else {
      AlertDialogs().alertWarning(context, 'โต๊ะไม่ว่าง');
      setState(() {
        reasonChangeStatusOrderId = 0;
        fetchOrderHistoryData();
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchReasonChangeStatusOrderData();
    fetchOrderHistoryData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          restoreOrderData.isNotEmpty
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TypeAheadField<RestoreOrderModel>(
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
                      suggestionsCallback: autocompleteTableOrder,
                      minCharsForSuggestions: 1,
                      itemBuilder: (context, RestoreOrderModel suggestion) {
                        return ListTile(
                          title: Text(
                            suggestion.tableName!,
                            style: FontStyle().h2Style(0xff000000, 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ออเดอร์ ${suggestion.orderhdDocuno}',
                                style: FontStyle().h2Style(0, 14),
                              ),
                              Text(
                                'มูลค่ารวม ${NumberFormat.currency(name: '').format(int.parse(suggestion.orderhdNetamnt!))}',
                                style: FontStyle().h2Style(0, 14),
                              )
                            ],
                          ),
                        );
                      },
                      onSuggestionSelected: (RestoreOrderModel suggestion) {
                        confirmRestoreOrder(
                          suggestion.orderhdDocuno!,
                          suggestion.tableName!,
                          suggestion.tableId!,
                          suggestion.orderhdId!,
                        );
                      },
                      noItemsFoundBuilder: (contex) => Center(
                        child: Text(
                          'ไม่พบข้อมูล',
                          style: FontStyle().h2Style(0, 20),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Expanded(
            child: restoreOrderData.isNotEmpty
                ? listOrder()
                : const Center(
                    child: Text(
                      'ไม่มีรายการออเดอร์',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget listOrder() {
    return ListView.builder(
      itemCount: restoreOrderData.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: ListTile(
            hoverColor: const Color(0xff4fc3f7),
            title: Text(
              '${restoreOrderData[index].orderhdDocuno}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${restoreOrderData[index].tableName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'จำนวนลูกค้า ${restoreOrderData[index].customerQty} คน',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'มูลค่ารวม ${NumberFormat.currency(name: '').format(
                    int.parse(restoreOrderData[index].orderhdNetamnt!),
                  )} บาท',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            trailing: Text(
              '${restoreOrderData[index].zoneName}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            onTap: () {
              confirmRestoreOrder(
                restoreOrderData[index].orderhdDocuno!,
                restoreOrderData[index].tableName!,
                restoreOrderData[index].tableId!,
                restoreOrderData[index].orderhdId!,
              );
            },
          ),
        );
      },
    );
  }

  confirmRestoreOrder(
    String orderDoc,
    String tableName,
    String tableId,
    String orderhdId,
  ) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'ยืนยันการคืนสถานะ : ${tableName}',
                  style: FontStyle().h2Style(0xff000000, 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'ORDER : ${orderDoc}',
                  style: FontStyle().h2Style(0xff000000, 16),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'เลือกเหตุผลในการคืนสถานะโต๊ะ',
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
                      reasonChangeStatusOrderData.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 60, top: 5),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Radio(
                                  value: int.parse(
                                    reasonChangeStatusOrderData[index]
                                            ['master_reason_status_order_id']
                                        .toString(),
                                  ),
                                  groupValue: reasonChangeStatusOrderId,
                                  onChanged: (values) {
                                    setState(() {
                                      reasonChangeStatusOrderId =
                                          int.parse(values.toString());
                                    });
                                  },
                                ),
                                Text(
                                  reasonChangeStatusOrderData[index]
                                      ['master_reason_status_order_name'],
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
            if (reasonChangeStatusOrderId == 0) {
              AlertDialogs()
                  .alertWarning(context, 'โปรดเลือกเหตุผลในการคืนสถานะโต๊ะ');
              return;
            }
            Navigator.of(context).pop();
            restoreOrder(tableId, orderhdId);
          },
        )
      ],
    ).show();
  }
}
