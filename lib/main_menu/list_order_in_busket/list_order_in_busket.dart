import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'model_data_order_in_busket/model_data_order_in_busket.dart';

class ListOrderInBusket extends StatefulWidget {
  final String? tableId;
  final String? tableName;
  final String? orderId;
  final String? companyId;
  final String? branchId;
  const ListOrderInBusket({
    Key? key,
    required this.orderId,
    required this.tableName,
    required this.tableId,
    required this.companyId,
    required this.branchId,
  }) : super(key: key);

  @override
  _ListOrderInBusketState createState() => _ListOrderInBusketState();
}

class _ListOrderInBusketState extends State<ListOrderInBusket> {
  double totalPrice = 0;
  List<OrderInBusketDataModel> listProductDataInBusket = [];
  List qty = [];
  List<double> netAmount = [];
  List printReceiptFlag = [];
  List toppingPrice = [];
  List listRemark = [];
  bool loading = false;

  fetchProductDataInBusket() async {
    final url = '${UrlApi().url}get_product_data_in_busket';
    final body = jsonEncode({
      'order_id': widget.orderId,
      'table_id': widget.tableId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 || response.data.isNotEmpty) {
      setState(() {
        listProductDataInBusket = orderInBusketModelFromJson(
          jsonEncode(response.data),
        );
        loading = false;
      });

      for (var item in listProductDataInBusket) {
        totalPrice += item.orderdtNetAmnt!;
        toppingPrice.add(item.totalPriceTopping!);
        qty.add(item.orderdtQty!);
        netAmount.add(item.orderdtNetAmnt!);
        printReceiptFlag.add(item.billFlag);
      }
      totalPrice += double.parse(toppingPrice[0]);
    }
    AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchProductDataInBusket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ตะกร้าอาหาร',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                widget.tableName!,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            label: const Text(
              'ปิด',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: listProductsInCart(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffFFFFFF), width: 4),
              borderRadius: BorderRadius.circular(30)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ราคารวม',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                      '${NumberFormat.currency(name: '').format(totalPrice)} บาท',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listProductsInCart() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: listProductDataInBusket.length,
      itemBuilder: (context, indexs) {
        return SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xffbbdefb), width: 4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${indexs + 1}',
                              style: FontStyle().h2Style(0xff000000, 14),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  listProductDataInBusket[indexs].productName!,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                              Text(
                                'จำนวน ${qty[indexs]}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'ราคา ${NumberFormat.currency(name: '').format(netAmount[indexs])} บาท',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              listProductDataInBusket[indexs]
                                      .topping!
                                      .isNotEmpty
                                  ? const Text(
                                      'Topping',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    )
                                  : Container(),
                              Column(
                                children: List.generate(
                                  listProductDataInBusket[indexs]
                                      .topping!
                                      .length,
                                  (index) {
                                    return ListTile(
                                      title: Text(
                                          '${index + 1}. ${listProductDataInBusket[indexs].topping![index]['topping_name']} : ${listProductDataInBusket[indexs].topping![index]['topping_qty']}'),
                                      subtitle: Text(
                                          '    ราคา/หน่วย ${NumberFormat.currency(name: '').format(listProductDataInBusket[indexs].topping![index]['topping_price']!)} : รวม ${NumberFormat.currency(name: '').format(listProductDataInBusket[indexs].topping![index]['total_price_tpping']!)} บาท'),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            listProductDataInBusket[indexs].option!.isNotEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      'ตัวเลือกเพิ่มเติม',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    listProductDataInBusket[indexs]
                                        .option!
                                        .length,
                                    (index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                            '${listProductDataInBusket[indexs].option![index]['option_group_name']} : ${listProductDataInBusket[indexs].option![index]['option_name']}'),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 0, left: 1, right: 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  printReceiptFlag[indexs] == true
                                      ? Chip(
                                          label: const Text('พิมพ์สลิป'),
                                          backgroundColor: Colors.green[100],
                                        )
                                      : Chip(
                                          label: const Text('ไม่พิมพ์สลิป'),
                                          backgroundColor: Colors.green[100],
                                        ),
                                  Chip(
                                    label: Text(listProductDataInBusket[indexs]
                                        .locationTypeName!),
                                    backgroundColor: Colors.red[100],
                                  ),
                                  Chip(
                                    label: Text(listProductDataInBusket[indexs]
                                        .orderdtRemark!),
                                    backgroundColor: const Color(0xffe1bee7),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
