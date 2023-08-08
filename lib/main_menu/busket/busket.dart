import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/list_order_in_busket/list_order_in_busket.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:provider/src/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../CounterProvider.dart';
import 'model_data_busket/model_data_location_in_busket.dart';
import 'model_data_busket/model_data_product_in_busket.dart';
import 'model_data_busket/model_data_remark_in_busket.dart';

class Busket extends StatefulWidget {
  final String? tableId;
  final String? tableName;
  final String? orderId;
  final String? tableTypeId;
  final String? companyId;
  final String? branchId;
  final bool? buffetActive;
  final int? mainPage;
  final bool? alacarteActive;
  const Busket({
    Key? key,
    required this.tableId,
    required this.tableName,
    required this.orderId,
    required this.tableTypeId,
    required this.companyId,
    required this.branchId,
    required this.buffetActive,
    required this.mainPage,
    required this.alacarteActive,
  }) : super(key: key);

  @override
  _BusketState createState() => _BusketState();
}

class _BusketState extends State<Busket> {
  bool loading = true;
  List<ProductInBusketDataModel> productDataInBusket = [];
  List<RemarkInBusketDataModel> remarkDataInBusket = [];
  List<LocationTypeInBusketDataModel> locationTypeDataInBusket = [];

  int countNum = 1;
  int num = 1;
  double totalPrice = 0;
  List toppingPrice = [];
  int selectedChoiceRemark = 1;
  int type = 1;
  int selectedChoice = 1;
  int selectedChoice2 = 2;
  int selectedPrintreceipt = 0;
  bool printReceipt = true;
  List productInBusket = [];
  List product = [];

  // fetchProductDataInBusketForCount() async {
  //   context.read<CounterProvider>().resetCountProductInBusket();
  //   final url = '${UrlApi().url}get_product_data_in_busket';
  //   final body = jsonEncode({
  //     'order_id': widget.orderId,
  //     'table_id': widget.tableId,
  //     'company_id': widget.companyId,
  //     'branch_id': widget.branchId,
  //   });
  //   final response = await HttpRequests().httpRequest(url, body, context, true);
  //   if (response.statusCode == 200 || response.data.isNotEmpty) {
  //     setState(() {
  //       context
  //           .read<CounterProvider>()
  //           .addValueCountProductInBusket((productDataInBusket.length));

  //       loading = false;
  //     });
  //   }
  //   AlertDialogs().progressDialog(context, loading);
  // }

  fetchProductDataInBusket() async {
    productInBusket =
        Provider.of<CounterProvider>(context, listen: false).productInBusket;
    final url = '${UrlApi().url}get_product_data_in_busket';
    final body = jsonEncode({
      'order_id': widget.orderId,
      'table_id': widget.tableId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 || response.data.isNotEmpty) {
      if (productInBusket.isEmpty) {
        setState(() {
          productInBusket = [...response.data];
          var seen = Set<int>();
          product = productInBusket
              .where(
                (product) => seen.add(product['orderdt_id']),
              )
              .toList();
          Provider.of<CounterProvider>(context, listen: false)
              .setValueProductDataInBusket(product);
          productInBusket = product;
          productDataInBusket = productInBusketModelFromJson(
            jsonEncode(product),
          );
          totalPrice = 0;
          loading = false;
        });
      } else {
        setState(() {
          productInBusket = [...productInBusket, ...response.data];
          var seen = Set<int>();
          product = productInBusket
              .where(
                (product) => seen.add(product['orderdt_id']),
              )
              .toList();
          Provider.of<CounterProvider>(context, listen: false)
              .setValueProductDataInBusket(product);
          productInBusket = product;
          productDataInBusket = productInBusketModelFromJson(
            jsonEncode(product),
          );
          totalPrice = 0;
          loading = false;
        });
      }
      for (var item in productDataInBusket) {
        totalPrice += item.orderdtNetAmnt!;
        for (var items in item.topping!) {
          totalPrice += items['total_price_tpping'];
        }
      }
    }
    AlertDialogs().progressDialog(context, loading);
  }

  deleteProductDataInBusket(int orderDtId, int index) async {
    final url = '${UrlApi().url}delete_product_data_in_busket';
    final body = jsonEncode({
      'orderdt_id': orderDtId,
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      context.read<CounterProvider>().deleteCountProductInBusket(1);
      setState(() {
        totalPrice = 0;
        product.removeAt(index);
        productDataInBusket = productInBusketModelFromJson(
          jsonEncode(product),
        );
        for (var item in productDataInBusket) {
          totalPrice += item.orderdtNetAmnt!;
          for (var items in item.topping!) {
            totalPrice += items['total_price_tpping'];
          }
        }
        loading = false;
      });
      Provider.of<CounterProvider>(context, listen: false)
          .setValueProductDataInBusket(product);
      //fetchProductDataInBusket();
    }

    AlertDialogs().progressDialog(context, loading);
  }

  confirmProductOrder() async {
    List newData = [];
    for (var item in productDataInBusket) {
      newData.add({
        'orderdt_id': item.orderdtId,
        'orderdt_qty': item.orderdtQty,
        'orderdt_net_amount': item.orderdtNetAmnt,
        'location_type_id': item.locationTypeId,
        'print_bill_flag': item.billFlag,
        'orderdt_remark': item.orderdtRemark,
      });
    }
    final url = '${UrlApi().url}confirm_product_order';
    final body = jsonEncode({
      'orderhd_id': widget.orderId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'orderdt_data': newData,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      context
          .read<CounterProvider>()
          .addValueCountProductInOrder(productDataInBusket.length);
      setState(() {
        productDataInBusket = [];
        toppingPrice = [];
        totalPrice = 0;
        loading = false;
        context.read<CounterProvider>().resetCountProductInBusket();
      });
      if (widget.mainPage == 2) {
        Navigator.of(context)
          ..pop()
          ..pop();
      } else {
        Navigator.of(context).pop();
      }
      //fetchProductDataInBusket();
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  // fetchRemarkDataInBusket() async {
  //   final url = '${UrlApi().url}get_remark_data_in_busket';
  //   final body = jsonEncode({
  //     'token_key': 'tumkratoei',
  //   });
  //   final response = await HttpRequests().httpRequest(url, body, context, true);
  //   print(response);
  //   if (response.data.isNotEmpty || response.statusCode == 200) {
  //     setState(() {
  //       remarkDataInBusket = remarkInBusketModelFromJson(
  //         jsonEncode(response.data),
  //       );
  //       loading = false;
  //     });
  //   }
  //   await AlertDialogs().progressDialog(context, loading);
  // }

  fetchLocationTypyDataInBusket() async {
    final url = '${UrlApi().url}get_location_type_data_in_busket';
    final body = jsonEncode({
      'token_key': 'tumkratoei',
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        locationTypeDataInBusket = locationTypeInBusketModelFromJson(
          jsonEncode(response.data),
        );
        loading = false;
      });
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  updateProductQty(int qty, int orderdtId) async {
    final url = '${UrlApi().url}update_qty_product';
    final body = jsonEncode({
      "qty": qty,
      "orderdt_id": orderdtId,
      "orderhd_id": widget.orderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      fetchProductDataInBusket();
    }
    await AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchLocationTypyDataInBusket();
    // fetchProductDataInBusketForCount();
    //fetchRemarkDataInBusket();
    fetchProductDataInBusket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: productDataInBusket.isNotEmpty
          ? listProductsInBusket()
          : const Center(
              child: Text(
                'ไม่มีรายการอาหารในตะกร้า',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
      bottomNavigationBar: ClipRRect(
        child: BottomAppBar(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          'รวมเป็นเงิน',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Text(
                        '${NumberFormat.currency(name: '').format(totalPrice)} บาท',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                    color: productDataInBusket.isNotEmpty
                        ? const Color(0xff4fc3f7)
                        : Colors.white,
                  ),
                  height: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      productDataInBusket.isNotEmpty
                          ? confirmOrderAlert()
                          : null;
                    },
                    child: Text(
                      'ส่งรายการอาหารไปยังครัว',
                      style: TextStyle(
                        fontSize: 18,
                        color: productDataInBusket.isNotEmpty
                            ? const Color(0xffFFFFFF)
                            : Colors.grey,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding btnConfirmOrder() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffFFFFFF), width: 4),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ราคารวม',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    '${NumberFormat.currency(name: '').format(totalPrice)} บาท',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(29)),
                        ),
                        onPressed: productDataInBusket.isNotEmpty
                            ? () {
                                confirmOrderAlert();
                              }
                            : null,
                        child: const Text(
                          'ส่งอาหารไปยังครัว',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 10),
                  //   child: TextButton.icon(
                  //       onPressed: () {
                  //         productDataInBusket.isNotEmpty
                  //             ? Navigator.of(context).push(
                  //                 MaterialPageRoute(
                  //                   builder: (context) => ListOrderInBusket(
                  //                     tableId: widget.tableId,
                  //                     tableName: widget.tableName,
                  //                     orderId: widget.orderId,
                  //                     companyId: widget.companyId,
                  //                     branchId: widget.branchId,
                  //                   ),
                  //                 ),
                  //               )
                  //             : null;
                  //       },
                  //       icon: const Icon(
                  //         Icons.list_alt,
                  //         size: 30,
                  //       ),
                  //       label: const Text('')),
                  // )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  deleteProductDataAlert(String productName, int orderDtId, int index) {
    Alert(
      context: context,
      content: Column(
        children: [
          const Text(
            'ต้องการลบรายการอาหาร',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            '${productName} ออกจากตะกร้า',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
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
          child: const Text(
            "ปิด",
            style: TextStyle(fontSize: 16, color: Color(0xff4fc3f7)),
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
            Navigator.of(context).pop();
            deleteProductDataInBusket(orderDtId, index);
          },
        )
      ],
    ).show();
  }

  confirmOrderAlert() {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: const [
          Text(
            'ยืนยันการส่งอาหารไปยังครัว',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
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
          child: const Text(
            "ปิด",
            style: TextStyle(fontSize: 16, color: Color(0xff4fc3f7)),
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
            Navigator.pop(context);
            confirmProductOrder();
          },
        )
      ],
    ).show();
  }

  Widget listProductsInBusket() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: productDataInBusket.length,
      itemBuilder: (context, item) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Card(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${item + 1}',
                              style: FontStyle().h2Style(0xff000000, 16),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteProductDataAlert(
                                  productDataInBusket[item].productName!,
                                  productDataInBusket[item].orderdtId!,
                                  item,
                                );
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                productDataInBusket[item].productName!,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (productDataInBusket[item].orderdtType ==
                                        1) {
                                      if (productDataInBusket[item]
                                              .orderdtQty! >
                                          1) {
                                        setState(() {
                                          product[item]['orderdt_qty'] -= 1;
                                          totalPrice -= double.parse(
                                              product[item]
                                                  ['orderdt_saleprice']);
                                          product[item]['orderdt_netamnt'] =
                                              '${double.parse(product[item]['orderdt_netamnt']) - double.parse(product[item]['orderdt_saleprice'])}';
                                          productDataInBusket =
                                              productInBusketModelFromJson(
                                            jsonEncode(product),
                                          );
                                        });
                                        Provider.of<CounterProvider>(context,
                                                listen: false)
                                            .setValueProductDataInBusket(
                                                product);

                                        // updateProductQty(
                                        //   productDataInBusket[item]
                                        //           .orderdtQty! -
                                        //       1,
                                        //   productDataInBusket[item].orderdtId!,
                                        // );
                                        // setState(() {
                                        //   productDataInBusket[item]
                                        //           .orderdtQty =
                                        //       productDataInBusket[item]
                                        //               .orderdtQty! -
                                        //           1;
                                        //   totalPrice -=
                                        //       productDataInBusket[item]
                                        //           .orderdtSalePrice!;
                                        //   productDataInBusket[item]
                                        //           .orderdtNetAmnt =
                                        //       productDataInBusket[item]
                                        //               .orderdtNetAmnt! -
                                        //           productDataInBusket[item]
                                        //               .orderdtSalePrice!;
                                        // });
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: productDataInBusket[item]
                                                .orderdtType! ==
                                            1
                                        ? const Color(0xffff616f)
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                                Text(
                                  '${productDataInBusket[item].orderdtQty}',
                                  style: FontStyle().h2Style(0xff000000, 16),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (loading) {
                                      return;
                                    }
                                    if (productDataInBusket[item]
                                            .orderdtType! ==
                                        1) {
                                      setState(() {
                                        product[item]['orderdt_qty'] += 1;
                                        totalPrice += double.parse(
                                            product[item]['orderdt_saleprice']);
                                        product[item]['orderdt_netamnt'] =
                                            '${double.parse(product[item]['orderdt_netamnt']) + double.parse(product[item]['orderdt_saleprice'])}';
                                        productDataInBusket =
                                            productInBusketModelFromJson(
                                          jsonEncode(product),
                                        );
                                      });
                                      Provider.of<CounterProvider>(context,
                                              listen: false)
                                          .setValueProductDataInBusket(product);
                                      // updateProductQty(
                                      //   productDataInBusket[item].orderdtQty! +
                                      //       1,
                                      //   productDataInBusket[item].orderdtId!,
                                      // );
                                      // setState(() {
                                      //   productDataInBusket[item]
                                      //           .orderdtQty =
                                      //       productDataInBusket[item]
                                      //               .orderdtQty! +
                                      //           1;
                                      //   totalPrice +=
                                      //       productDataInBusket[item]
                                      //           .orderdtSalePrice!;
                                      //   productDataInBusket[item]
                                      //           .orderdtNetAmnt =
                                      //       productDataInBusket[item]
                                      //               .orderdtNetAmnt! +
                                      //           productDataInBusket[item]
                                      //               .orderdtSalePrice!;
                                      // });

                                    }
                                  },
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: productDataInBusket[item]
                                                    .orderdtType! ==
                                                1 ||
                                            loading == true
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${NumberFormat.currency(name: '').format(productDataInBusket[item].orderdtNetAmnt)} บาท',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            productDataInBusket[item].option!.isNotEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 0),
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
                                    productDataInBusket[item].option!.length,
                                    (index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                            '${productDataInBusket[item].option![index]['option_group_name']} : ${productDataInBusket[item].option![index]['option_name']}'),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              productDataInBusket[item].topping!.isNotEmpty
                                  ? const Text(
                                      'Topping',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    )
                                  : Container(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  productDataInBusket[item].topping!.length,
                                  (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                          '${index + 1}. ${productDataInBusket[item].topping![index]['topping_name']} : ${productDataInBusket[item].topping![index]['topping_qty']}'),
                                    );
                                    //  ListTile(
                                    //   title: Text(
                                    //       '${index + 1}. ${productDataInBusket[item].topping![index]['topping_name']} : ${productDataInBusket[item].topping![index]['topping_qty']}'),
                                    //   subtitle: Text(
                                    //       '    ราคา/หน่วย ${NumberFormat.currency(name: '').format(productDataInBusket[item].topping![index]['topping_price']!)} : รวม ${NumberFormat.currency(name: '').format(productDataInBusket[item].topping![index]['total_price_tpping']!)} บาท'),
                                    // );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: TextField(
                            style: const TextStyle(fontFamily: 'Kanit'),
                            decoration: InputDecoration(
                              hintText: 'หมายเหตุ:',
                              labelText:
                                  '${productDataInBusket[item].orderdtRemark}',
                            ),
                            onChanged: (value) {
                              setState(() {
                                productDataInBusket[item].orderdtRemark = value;
                                product[item]['orderdt_remark'] = value;

                                if (productDataInBusket[item].orderdtRemark ==
                                    '') {
                                  productDataInBusket[item].orderdtRemark =
                                      'ไม่มีหมายเหตุ';
                                  product[item]['orderdt_remark'] =
                                      'ไม่มีหมายเหตุ';
                                }
                                Provider.of<CounterProvider>(context,
                                        listen: false)
                                    .setValueProductDataInBusket(product);
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 1,
                            right: 1,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffbbdefb), width: 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    locationTypeDataInBusket.length,
                                    (index) {
                                      if (widget.tableTypeId == '1' &&
                                          productDataInBusket[item]
                                                  .orderdtType ==
                                              1) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 60),
                                          child: SizedBox(
                                            width: 50,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Radio(
                                                  value: int.parse(
                                                      locationTypeDataInBusket[
                                                              index]
                                                          .locationTypeId!),
                                                  groupValue:
                                                      productDataInBusket[item]
                                                          .locationTypeId!,
                                                  onChanged: (int? values) {
                                                    setState(() {
                                                      productDataInBusket[item]
                                                              .locationTypeId =
                                                          values;
                                                      product[item][
                                                              'master_order_location_type_id'] =
                                                          values;
                                                    });
                                                    Provider.of<CounterProvider>(
                                                            context,
                                                            listen: false)
                                                        .setValueProductDataInBusket(
                                                            product);
                                                  },
                                                ),
                                                Text(
                                                  locationTypeDataInBusket[
                                                          index]
                                                      .locationTypeName!,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 60),
                                        child: SizedBox(
                                          width: 50,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Radio(
                                                value: int.parse(
                                                    locationTypeDataInBusket[
                                                            index]
                                                        .locationTypeId!
                                                        .toString()),
                                                groupValue:
                                                    productDataInBusket[item]
                                                        .locationTypeId,
                                                onChanged: (values) => {null},
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Text(
                                                  locationTypeDataInBusket[
                                                          index]
                                                      .locationTypeName!,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
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
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 20, left: 1, right: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xff8470FF), width: 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      child: Row(
                                        children: [
                                          Radio(
                                            value: 1,
                                            groupValue:
                                                productDataInBusket[item]
                                                            .billFlag ==
                                                        true
                                                    ? selectedPrintreceipt = 1
                                                    : selectedPrintreceipt = 2,
                                            onChanged: (int? values) {
                                              setState(() {
                                                selectedPrintreceipt = values!;
                                                productDataInBusket[item]
                                                    .billFlag = true;
                                                product[item]
                                                    ['print_bill_flag'] = true;
                                              });
                                              Provider.of<CounterProvider>(
                                                      context,
                                                      listen: false)
                                                  .setValueProductDataInBusket(
                                                      product);
                                            },
                                          ),
                                          const Text(
                                            'พิมพ์สลิป',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      child: Row(
                                        children: [
                                          Radio(
                                            value: 2,
                                            groupValue:
                                                productDataInBusket[item]
                                                            .billFlag ==
                                                        false
                                                    ? selectedPrintreceipt = 2
                                                    : selectedPrintreceipt = 1,
                                            onChanged: (int? values) {
                                              setState(() {
                                                selectedPrintreceipt = values!;
                                                productDataInBusket[item]
                                                    .billFlag = false;
                                                product[item]
                                                    ['print_bill_flag'] = false;
                                              });
                                              Provider.of<CounterProvider>(
                                                      context,
                                                      listen: false)
                                                  .setValueProductDataInBusket(
                                                      product);
                                            },
                                          ),
                                          const Text(
                                            'ไม่พิมพ์สลิป',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
