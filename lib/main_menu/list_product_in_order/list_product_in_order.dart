// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_brace_in_string_interps, implementation_imports, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/list_product_in_order/list_product_widget.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/src/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../CounterProvider.dart';
import 'model_data_product_in_order/autocomplete_table_data.dart';
import 'model_data_product_in_order/model_data_product_in_order.dart';

class ListProductInOrder extends StatefulWidget {
  final String? orderId;
  final String? orderDocuno;
  final bool? menuActionActive;
  final String? branchId;
  final String? userId;
  final String? tableName;
  final String? empId;

  final String? tableId;
  final String? companyId;

  const ListProductInOrder({
    Key? key,
    this.orderId,
    required this.orderDocuno,
    this.menuActionActive,
    this.branchId,
    required this.tableName,
    required this.empId,
    required this.tableId,
    required this.userId,
    required this.companyId,
  }) : super(key: key);

  @override
  _ListProductInOrderState createState() => _ListProductInOrderState();
}

class _ListProductInOrderState extends State<ListProductInOrder> {
  final textCtl = TextEditingController();

  clearTextInput() {
    textCtl.clear();
  }

  bool loading = true;
  int total = 0;
  List<ListProductInOrderDataModel> listProductData = [];
  List<TableDataModel> tableData = [];
  List reasonCancelData = [];
  List reasonMoveOrderData = [];
  int reasonCancelId = 0;
  int reasonMoveOrderId = 0;
  String? newTableId;
  String? newOrderhdId;
  String? newTableName;
  String remark = "ไม่มีหมายเหตุ";
  bool? authority;
  bool isCheckedAllProduct = false;
  bool check = false;
  List orderdtid = [];
  void toggleSelectAll() {
    setState(() {
      isCheckedAllProduct = !isCheckedAllProduct;
      for (var product in listProductData) {
        product.checked = isCheckedAllProduct;
      }
    });
  }

  updateOrderStatus(List<dynamic> listoderID) async {
    print(listoderID);
    final url = '${UrlApi().url}update_order_status';
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'order_dt_id': listoderID
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        fetchProductDataInOrder();
      });
      await AlertDialogs().progressDialog(context, loading);
    }
  }

  fetchProductDataInOrder() async {
    final url = '${UrlApi().url}get_product_data_in_order';
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        listProductData = listProductInOrderModelFromJson(
          jsonEncode(response.data),
        );
        remark = 'ไม่มีหมายเหตุ';
        total = 0;
        loading = false;
      });
      await AlertDialogs().progressDialog(context, loading);
      for (var item in listProductData) {
        total += int.parse(item.orderdtQty!);
      }
    }
  }

  fetchDataAuthority() async {
    final url = '${UrlApi().url}get_data_authority';
    final body = jsonEncode({
      'user_id': widget.userId,
      'company_id': widget.companyId,
      "menu_id": 96,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty) {
      setState(() {
        authority = response.data['status_menu'];
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  fetchReasonCancelData() async {
    final url = '${UrlApi().url}get_reason_cancel_data';
    final body = jsonEncode({
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        reasonCancelData = response.data;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  fetchReasonMoveOrder() async {
    final url = '${UrlApi().url}get_reason_move_order_data';
    final body = jsonEncode({
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        reasonMoveOrderData = response.data;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  updateStatusProductData(orderDtId, int statusId) async {
    final url = '${UrlApi().url}update_status_product_data';
    final body = jsonEncode({
      'orderdt_id': orderDtId,
      'status_id': statusId,
      'emp_id_cancel': widget.empId,
      'remark': remark,
      'reason_cancel_id': reasonCancelId,
      'orderhd_id': widget.orderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data['message'] == true) {
      setState(() {
        reasonCancelId = 0;
        loading = false;
      });
      fetchProductDataInOrder();
    } else {
      cancelOrderNotSuccess();
      setState(() {
        loading = false;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  updateProductDataQty(orderDtId, qty) async {
    final url = '${UrlApi().url}update_product_qty';
    final body = jsonEncode({
      'orderdt_id': orderDtId,
      'qty': qty,
      'emp_id_cancel': widget.empId,
      'remark': remark,
      'reason_cancel_id': reasonCancelId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        reasonCancelId = 0;
        loading = false;
      });
      fetchProductDataInOrder();
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  Future<List<TableDataModel>> autocompleteTableData(String query) async {
    final url = '${UrlApi().url}autocomplete_table_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'table_id': widget.tableId,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    setState(() {
      loading = false;
      tableData = tableDataModelFromJson(jsonEncode(response.data));
    });

    AlertDialogs().progressDialog(context, loading);
    return tableData.where((table) {
      final productName = table.tableName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return productName.contains(queryLower);
    }).toList();
  }

  moveProductDataAll(String orderdtId) async {
    final url = '${UrlApi().url}move_product_data_all';
    final body = jsonEncode({
      'old_table_id': widget.tableId,
      'new_table_id': newTableId,
      'old_orderhd_id': widget.orderId,
      'new_orderhd_id': newOrderhdId,
      'orderdt_id': orderdtId,
      'remark': remark,
      'emp_id': widget.empId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'reason_move_order_id': reasonMoveOrderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data['message'] == true) {
      setState(() {
        context.read<CounterProvider>().deleteCountProductInOrder(1);
        loading = false;
      });
      fetchProductDataInOrder();
    } else {
      cancelOrderNotSuccess();
      setState(() {
        loading = false;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  moveProductDataQty(String orderdtId, int qty) async {
    final url = '${UrlApi().url}move_product_data_qty';
    final body = jsonEncode({
      'old_table_id': widget.tableId,
      'new_table_id': newTableId,
      'old_orderhd_id': widget.orderId,
      'new_orderhd_id': newOrderhdId,
      'orderdt_id': orderdtId,
      'qty': qty,
      'remark': remark,
      'emp_id': widget.empId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'reason_move_order_id': reasonMoveOrderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data['message'] == true) {
      setState(() {
        //context.read<CounterProvider>().deleteCountProductInOrder(1);
        loading = false;
      });
      fetchProductDataInOrder();
    } else {
      cancelOrderNotSuccess();
      setState(() {
        loading = false;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchReasonMoveOrder();
    fetchReasonCancelData();
    fetchDataAuthority();
    fetchProductDataInOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.orderDocuno!,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(
                  'จำนวน ${listProductData.length} รายการ ${total} ชิ้น',
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                value: isCheckedAllProduct,
                onChanged: (bool? value) {
                  setState(() {
                    isCheckedAllProduct = value!;
                    for (var product in listProductData) {
                      product.checked = isCheckedAllProduct;
                    }
                  });
                },
              ),
              const Text('เลือกทั้งหมด'),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  print("check :$check");
                  print("isCheckedAllProduct :$isCheckedAllProduct");
                  if (check == false && isCheckedAllProduct == false) {
                    return;
                  } else if (check == true && isCheckedAllProduct == false) {
                    var newList = listProductData
                        .where((element) => element.checked == true)
                        .toList();
                    setState(() {
                      for (var product in newList) {
                        if (product.orderdtStatusId != '5') {
                          product.orderdtStatusId = '4';
                          product.checked = false;
                          check = false;
                          orderdtid.add(product.orderdtId);
                        }
                      }
                      print(orderdtid);
                      updateOrderStatus(orderdtid);
                    });
                  } else if (check == false && isCheckedAllProduct == true) {
                    var newList = listProductData
                        .where((element) => element.checked == true)
                        .toList();
                    setState(() {
                      for (var product in newList) {
                        if (product.orderdtStatusId != '5') {
                          product.orderdtStatusId = '4';
                          product.checked = false;
                          check = false;
                          orderdtid.add(product.orderdtId);
                        }
                      }
                      print(orderdtid);
                      updateOrderStatus(orderdtid);
                    });
                  }
                  var newList = listProductData
                      .where((element) => element.checked == true)
                      .toList();
                  setState(() {
                    for (var product in newList) {
                      if (product.orderdtStatusId != '5') {
                        product.orderdtStatusId = '4';
                        product.checked = false;
                        check = false;
                        orderdtid.add(product.orderdtId);
                      }
                    }
                    print(orderdtid);
                    updateOrderStatus(orderdtid);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: check == true || isCheckedAllProduct == true
                      ? Colors.green
                      : Colors.grey,
                ),
                child: const Text('เสิร์ฟแล้ว'),
              ),
              const SizedBox(width: 10),
            ],
          ),
          listProductData.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: listProductData.length,
                    itemBuilder: (context, index) {
                      final product = listProductData[index];
                      final bool isServed = product.orderdtStatusId == '4';
                      if (listProductData[index].orderdtStatusId != '5') {
                        return ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(35),
                          ),
                          child: Slidable(
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    if (authority == true &&
                                        listProductData[index].orderdtTypeId ==
                                            "1") {
                                      moveOrder(
                                        listProductData[index].productName!,
                                        listProductData[index].orderdtId!,
                                        listProductData[index].orderdtQty!,
                                      );
                                    }
                                  },
                                  backgroundColor: authority == true &&
                                          listProductData[index]
                                                  .orderdtTypeId ==
                                              "1"
                                      ? MyStyle().lightColor
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  icon: Icons.remove,
                                  label: 'ย้ายรายการอาหาร',
                                )
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                listProductData[index].orderdtStatusId == '2'
                                    ? SlidableAction(
                                        onPressed: (context) {
                                          statusUpdateAlert(
                                            3,
                                            listProductData[index],
                                            'กำลังปรุง',
                                          );
                                        },
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        icon: Icons.history_outlined,
                                        label: 'กำลังปรุง',
                                      )
                                    : SlidableAction(
                                        onPressed: (context) {
                                          updateStatusProductData(
                                              listProductData[index].orderdtId,
                                              4);
                                          // statusUpdateAlert(
                                          //   4,
                                          //   listProductData[index],
                                          //   'เสิร์ฟเเล้ว',
                                          // );
                                        },
                                        backgroundColor:
                                            const Color(0xFF21B7CA),
                                        foregroundColor: Colors.white,
                                        icon: Icons.check,
                                        label: 'เสริฟเเล้ว',
                                      ),
                                SlidableAction(
                                  onPressed: (context) {
                                    if (authority == true) {
                                      if (int.parse(listProductData[index]
                                              .orderdtQty!) >
                                          1) {
                                        confirmAlert(
                                          5,
                                          listProductData[index],
                                        );
                                      } else {
                                        statusUpdateAlert(
                                          5,
                                          listProductData[index],
                                          'ยกเลิก',
                                        );
                                      }
                                    }
                                  },
                                  backgroundColor: authority == true
                                      ? const Color(0xffff616f)
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  icon: Icons.cancel,
                                  label: 'ยกเลิก',
                                ),
                              ],
                            ),
                            child: ListProductWidget(
                              productData: listProductData[index],
                              toggleSelectAll: () {},
                              listProductData: listProductData,
                              updateParentCheck: (newCheck) {
                                setState(() {
                                  check =
                                      newCheck; // อัปเดตค่า check ใน ListProductInOrder
                                });
                              },
                            ),
                          ),
                        );
                      }
                      return ListProductWidget(
                        productData: product,
                        isCheckedAllProduct: isCheckedAllProduct,
                        toggleSelectAll: toggleSelectAll,
                        isServed: isServed,
                        listProductData: listProductData,
                        updateParentCheck: (newCheck) {
                          setState(() {
                            check = newCheck;
                          });
                        },
                      );
                    },
                  ),
                )
              : const Center(
                  child: Text(
                    'ไม่มีรายการอาหาร',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(40),
          topLeft: Radius.circular(40),
        ),
        child: BottomAppBar(
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.orange,
                        width: 10,
                      ),
                    ),
                  ),
                  child: Text('กำลังปรุง',
                      style: FontStyle().h2Style(0xff000000, 16)),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.green,
                        width: 10,
                      ),
                    ),
                  ),
                  child: Text('เสิร์ฟเเล้ว',
                      style: FontStyle().h2Style(0xff000000, 16)),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Color(0xffff616f), width: 10),
                    ),
                  ),
                  child: Text('ยกเลิก',
                      style: FontStyle().h2Style(0xff000000, 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  statusUpdateAlert(int statusId, listProductData, message) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Text(
                  'ยกเลิก ${listProductData.productName}',
                  style: FontStyle().h2Style(0xff000000, 16),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เลือกเหตุผลในการยกเลิก',
                    style: FontStyle().h2Style(0xff000000, 16),
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    spacing: 50,
                    runSpacing: 5,
                    runAlignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: List.generate(
                      reasonCancelData.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 0, top: 5),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Radio(
                                  value: int.parse(
                                    reasonCancelData[index]
                                            ['master_reason_cancel_order_id']
                                        .toString(),
                                  ),
                                  groupValue: reasonCancelId,
                                  onChanged: (values) {
                                    setState(() {
                                      reasonCancelId =
                                          int.parse(values.toString());
                                    });
                                  },
                                ),
                                Text(
                                  reasonCancelData[index]
                                      ['master_reason_cancel_order_name'],
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
          color: const Color(0xff4fc3f7),
          onPressed: () {
            if (reasonCancelId == 0) {
              AlertDialogs().alertWarning(
                  context, 'กรุณาเลือกเหตุผลที่ต้องการยกเลิกรายการอาหาร');
              return;
            }
            Navigator.of(context).pop();
            updateStatusProductData(listProductData.orderdtId, statusId);
          },
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
        )
      ],
    ).show();
  }

  confirmAlert(int statusId, listProductData) {
    int qty = 1;
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (statusId == 5) {
                          if (reasonCancelId == 0) {
                            AlertDialogs().alertWarning(context,
                                'กรุณาเลือกเหตุผลที่ต้องการยกเลิกรายการอาหาร');
                            return;
                          }
                        }
                        Navigator.pop(context);
                        updateStatusProductData(
                            listProductData.orderdtId, statusId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4fc3f7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'ยกเลิกทั้งหมด',
                        style: FontStyle().h2Style(0xffFFFFFF, 14),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ปิด ${listProductData.productName}',
                      style: FontStyle().h2Style(0xff000000, 16),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (qty != 1) {
                              qty--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove_circle),
                        color: const Color(0xffff616f),
                        iconSize: 50,
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${qty}',
                                style: FontStyle().h2Style(0xff000000, 25),
                              )
                            ]),
                      ),
                      IconButton(
                        onPressed: () {
                          if (int.parse(listProductData.orderdtQty) > qty) {
                            setState(() {
                              qty++;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.green,
                        iconSize: 50,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'เลือกเหตุผลในการยกเลิก',
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
                        reasonCancelData.length,
                        (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 0, top: 5),
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Radio(
                                    value: int.parse(
                                      reasonCancelData[index]
                                              ['master_reason_cancel_order_id']
                                          .toString(),
                                    ),
                                    groupValue: reasonCancelId,
                                    onChanged: (values) {
                                      setState(() {
                                        reasonCancelId =
                                            int.parse(values.toString());
                                      });
                                    },
                                  ),
                                  Text(
                                    reasonCancelData[index]
                                        ['master_reason_cancel_order_name'],
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
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                //   child: TextField(
                //     decoration: InputDecoration(
                //       enabledBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(30),
                //         borderSide:
                //             BorderSide(color: MyStyle().lightColor, width: 1),
                //       ),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(30),
                //       ),
                //       hintText: 'หมายเหตุ:',
                //     ),
                //     onChanged: (value) {
                //       setState(() {
                //         remark = value;
                //         if (remark == '') {
                //           remark = 'ไม่มีหมายเหตุ';
                //         }
                //       });
                //     },
                //   ),
                // ),
              ],
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
          color: const Color(0xff4fc3f7),
          onPressed: () {
            if (statusId == 5) {
              if (reasonCancelId == 0) {
                AlertDialogs().alertWarning(
                    context, 'กรุณาเลือกเหตุผลที่ต้องการยกเลิกรายการอาหาร');
                return;
              }
            }
            Navigator.of(context).pop();
            if (int.parse(listProductData.orderdtQty) == qty) {
              updateStatusProductData(listProductData.orderdtId, statusId);
            } else {
              updateProductDataQty(listProductData.orderdtId, qty);
            }
          },
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
        )
      ],
    ).show();
  }

  moveOrder(String message, String orderdtId, String orderdtQty) {
    int qty = 1;
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (newTableId == null && newOrderhdId == null) {
                        AlertDialogs().alertWarning(
                          context,
                          'โปรดระบุโต๊ะที่ต้องการย้ายรายการอาหาร',
                        );
                        return;
                      }
                      if (reasonMoveOrderId == 0) {
                        AlertDialogs().alertWarning(
                          context,
                          'โปรดเลือกเหตุผลในการย้ายรายการอาหาร',
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      moveProductDataAll(orderdtId);
                      // Navigator.pop(context);
                      // confirmMoveFoodItemAlert(
                      //   message,
                      //   orderdtId,
                      //   int.parse(orderdtQty),
                      //   int.parse(orderdtQty),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4fc3f7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'ย้ายทั้งหมด',
                      style: FontStyle().h2Style(0xffFFFFFF, 14),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (qty != 1) {
                            qty--;
                          }
                        });
                      },
                      icon: const Icon(Icons.remove_circle),
                      color: const Color(0xffff616f),
                      iconSize: 50,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${qty}',
                              style: FontStyle().h2Style(0xff000000, 25),
                            )
                          ]),
                    ),
                    IconButton(
                      onPressed: () {
                        if (int.parse(orderdtQty) > qty) {
                          setState(() {
                            qty++;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_circle),
                      color: Colors.green,
                      iconSize: 50,
                    ),
                  ],
                ),
              ),
              Text(
                'ค้นหาโต๊ะที่ต้องการย้าย',
                style: FontStyle().h2Style(0xff000000, 18),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TypeAheadField<TableDataModel>(
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
                  suggestionsCallback: autocompleteTableData,
                  minCharsForSuggestions: 1,
                  itemBuilder: (context, TableDataModel suggestion) {
                    return ListTile(
                      leading: Image.asset(
                        'assets/images/table.png',
                        width: 40,
                        height: 40,
                      ),
                      title: Text(
                        'โต๊ะ ${suggestion.tableName}',
                        style: FontStyle().h2Style(0xff000000, 16),
                      ),
                    );
                  },
                  onSuggestionSelected: (TableDataModel suggestion) {
                    clearTextInput();
                    setState(() {
                      newTableId = suggestion.tableId;
                      newOrderhdId = suggestion.orderId;
                      newTableName = 'โต๊ะ ${suggestion.tableName}';
                    });
                  },
                  noItemsFoundBuilder: (contex) => Center(
                    child:
                        Text('ไม่พบข้อมูล', style: FontStyle().h2Style(0, 20)),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Text(
                      'เลือกเหตุผลในการย้ายรายการอาหาร',
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
                      reasonMoveOrderData.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 0, top: 5),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Radio(
                                  value: int.parse(
                                    reasonMoveOrderData[index]
                                            ['master_reason_move_order_id']
                                        .toString(),
                                  ),
                                  groupValue: reasonMoveOrderId,
                                  onChanged: (values) {
                                    setState(() {
                                      reasonMoveOrderId =
                                          int.parse(values.toString());
                                    });
                                  },
                                ),
                                Text(
                                  reasonMoveOrderData[index]
                                      ['master_reason_move_order_name'],
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
          color: const Color(0xff4fc3f7),
          onPressed: () {
            if (newTableId == null && newOrderhdId == null) {
              AlertDialogs().alertWarning(
                context,
                'โปรดระบุโต๊ะที่ต้องการย้ายรายการอาหาร',
              );
              return;
            }
            if (reasonMoveOrderId == 0) {
              AlertDialogs().alertWarning(
                context,
                'โปรดเลือกเหตุผลในการย้ายรายการอาหาร',
              );
              return;
            }
            if (newTableId != null && qty == int.parse(orderdtQty)) {
              Navigator.of(context).pop();
              moveProductDataAll(orderdtId);
            } else if (newTableId != null && qty < int.parse(orderdtQty)) {
              Navigator.of(context).pop();
              moveProductDataQty(orderdtId, qty);
            }
          },
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
        )
      ],
    ).show();
  }

  cancelOrderNotSuccess() {
    Alert(
      closeFunction: () {
        Navigator.of(context)
          ..pop()
          ..pop();
      },
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.error,
      content: Text(
        'ออเดอร์นี้ถูกปิดไปเเล้ว',
        style: FontStyle().h2Style(0xff000000, 16),
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          color: Colors.transparent,
          onPressed: () {
            Navigator.of(context)
              ..pop()
              ..pop();
          },
          width: 120,
          radius: const BorderRadius.all(Radius.circular(30)),
          child: Text(
            "ตกลง",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
        )
      ],
    ).show();
  }
}
