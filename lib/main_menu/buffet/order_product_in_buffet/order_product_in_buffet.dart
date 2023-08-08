import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:provider/src/provider.dart';
import '../../../CounterProvider.dart';
import 'model_data_order_product_in_buffet/model_location_type.dart';

class OrderProductInBuffet extends StatefulWidget {
  final String? orderId;
  final String? productId;
  final String? productName;
  final dynamic productPrice;
  final String? tableId;
  final String? tableTypeId;
  final String? empId;
  final String? companyId;
  final String? branchId;
  final String? buffethdId;
  final int? limitOrderdtQty;
  final int? balanchOrderdtQty;
  final int? allBalanchBuffetHdQty;
  final bool? orderInfinity;
  final bool? buffethdOrderInfinity;
  const OrderProductInBuffet({
    Key? key,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.orderId,
    required this.tableId,
    required this.tableTypeId,
    required this.empId,
    required this.companyId,
    required this.branchId,
    required this.buffethdId,
    required this.limitOrderdtQty,
    required this.balanchOrderdtQty,
    required this.allBalanchBuffetHdQty,
    required this.orderInfinity,
    required this.buffethdOrderInfinity,
  }) : super(key: key);

  @override
  _OrderProductInBuffetState createState() => _OrderProductInBuffetState();
}

class _OrderProductInBuffetState extends State<OrderProductInBuffet> {
  bool loading = false;
  List<LocationtypeDataInBuffetModel> locationTypeData = [];
  double totalPrice = 0;
  int qty = 1;
  int type = 1;
  int remarkId = 2;
  String remarkText = "ไม่มีหมายเหตุ";
  int selectedPrintreceipt = 1;
  bool printReceipt = true;
  fetchLocationTypyData() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_location_type_data';
    final body = jsonEncode({});
    final response = await HttpRequests().httpRequest(url, body, context, true);

    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        locationTypeData =
            locationTypeInBuffetModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  addProductDataInBuffet() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}add_product_data_in_buffet';
    final body = jsonEncode({
      'product_id': widget.productId,
      'order_id': widget.orderId,
      'product_price': widget.productPrice,
      'qty': qty,
      'total_price': totalPrice,
      'table_id': widget.tableId,
      'location_type': type,
      'remark_id': 0,
      'remark_text': remarkText,
      'print_receipt': printReceipt,
      'user_id': widget.empId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'buffethd_id': widget.buffethdId
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        totalPrice = 0;
        context.read<CounterProvider>().addValueCountProductInBusket(1);
        Navigator.of(context).pop();
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchLocationTypyData();
    totalPrice = widget.productPrice;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.productName}',
                style: FontStyle().h2Style(0xffFFFFFF, 20)),
            Text(
              '${NumberFormat.currency(name: '').format(widget.productPrice)} บาท',
              style: FontStyle().h2Style(0xffFFFFFF, 20),
            )
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            btnAddQtyProduct(),
            locationType(),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'ตัวเลือกเพิ่มเติม',
                style: FontStyle().h2Style(0xff000000, 18),
              ),
            ),
            noRemark(),
            slip(),
          ],
        ),
      ),
      bottomNavigationBar: addProduct(),
    );
  }

  Widget addProduct() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (loading) {
            null;
          } else {
            await addProductDataInBuffet();
          }
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: Container(
            height: 70,
            color: loading ? Colors.grey : MyStyle().lightColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_shopping_cart),
                      ],
                    ),
                  ),
                  Text(
                    'เพิ่มใส่ตะกร้า',
                    style: FontStyle().h2Style(0xffFFFFFF, 16),
                  ),
                  Text(
                    '${NumberFormat.currency(name: '').format(totalPrice)} บาท',
                    style: FontStyle().h2Style(0xffFFFFFF, 16),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding btnAddQtyProduct() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (qty != 1) {
                  qty--;
                  totalPrice -= widget.productPrice;
                }
              });
            },
            icon: const Icon(Icons.remove_circle),
            color: Colors.red,
            iconSize: 50,
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$qty',
                  style: FontStyle().h2Style(0xff000000, 25),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (qty < widget.allBalanchBuffetHdQty!) {
                if (qty < widget.limitOrderdtQty!) {
                  setState(() {
                    qty++;
                    totalPrice += widget.productPrice;
                  });
                }
              }
              if (widget.orderInfinity == true) {
                if (qty < widget.allBalanchBuffetHdQty!) {
                  setState(() {
                    qty++;
                    totalPrice += widget.productPrice;
                  });
                }
              }
              if (widget.buffethdOrderInfinity == true) {
                if (qty < widget.limitOrderdtQty! ||
                    widget.orderInfinity == true) {
                  setState(() {
                    qty++;
                    totalPrice += widget.productPrice;
                  });
                }
              }
            },
            icon: const Icon(Icons.add_circle),
            color: Colors.green,
            iconSize: 50,
          ),
        ],
      ),
    );
  }

  Padding slip() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff8470FF), width: 4),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Radio(
                      value: 1,
                      groupValue: selectedPrintreceipt,
                      onChanged: (int? values) {
                        setState(() {
                          selectedPrintreceipt = values!;
                          printReceipt = true;
                        });
                      },
                    ),
                    Text(
                      'พิมพ์สลิป',
                      style: FontStyle().h2Style(0xff000000, 14),
                    )
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: 2,
                      groupValue: selectedPrintreceipt,
                      onChanged: (int? values) {
                        setState(() {
                          selectedPrintreceipt = values!;
                          printReceipt = false;
                        });
                      },
                    ),
                    Text(
                      'ไม่พิมพ์สลิป',
                      style: FontStyle().h2Style(0xff000000, 14),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding noRemark() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: TextField(
        style: const TextStyle(fontFamily: 'Kanit'),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: MyStyle().prinaryColor, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          hintText: 'หมายเหตุ:',
        ),
        onChanged: (value) {
          setState(() {
            remarkText = value;
            if (remarkText == '') {
              remarkText = 'ไม่มีหมายเหตุ';
            }
          });
        },
      ),
    );
  }

  Padding locationType() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffbbdefb), width: 4),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            locationTypeData.length,
            (index) {
              setState(() {
                type = 1;
              });
              return Padding(
                padding: const EdgeInsets.only(right: 60),
                child: SizedBox(
                  width: 40,
                  child: Row(
                    children: [
                      Radio(
                        value:
                            int.parse(locationTypeData[index].locationTypeId!),
                        groupValue: 1,
                        onChanged: (int? values) => {null},
                      ),
                      Text(
                        locationTypeData[index].locationTypeName!,
                        style: FontStyle().h2Style(0xff000000, 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
