import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:provider/src/provider.dart';
import '../../CounterProvider.dart';
import 'model_data_order_product/model_location_type.dart';
import 'model_data_order_product/model_remark_data.dart';
import 'model_data_order_product/model_topping.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class OrderProductForSearch extends StatefulWidget {
  final String? orderId;
  final String? productId;
  final String? productName;
  final dynamic productPrice;
  final String? tableId;
  final String? productGroupId;
  final String? tableTypeId;
  final String? empId;
  final String? companyId;
  final String? branchId;
  const OrderProductForSearch({
    Key? key,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.orderId,
    required this.tableId,
    required this.productGroupId,
    required this.tableTypeId,
    required this.empId,
    required this.companyId,
    required this.branchId,
  }) : super(key: key);

  @override
  _OrderProductForSearchState createState() => _OrderProductForSearchState();
}

class _OrderProductForSearchState extends State<OrderProductForSearch> {
  bool loading = true;
  List<RemarkDataModel> remarkData = [];
  List<LocationtypeDataModel> locationTypeData = [];
  List<ToppingDataModel> toppingData = [];
  List toppings = [];
  List option = [];
  double totalPrice = 0;
  int qty = 1;
  int selectedChoice = 1;
  int selectedChoice2 = 2;
  int type = 1;
  int selectedChoiceRemark = 0;
  int remarkId = 0;
  String remarkText = "ไม่มีหมายเหตุ";
  int selectedPrintreceipt = 1;
  bool printReceipt = true;
  int countOption = 0;

  fetchRemarkData() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_remark_data';
    final body = jsonEncode({
      'product_group_id': widget.productGroupId,
      'product_id': widget.productId,
      'company_id': widget.companyId,
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        remarkData = remarkModelFromJson(jsonEncode(response.data));
        countOption = remarkData.length;
        loading = false;
      });
      for (var item in remarkData) {
        option.add({'option_id': 0});
      }
    }
    if (remarkData.isEmpty) {
      setState(() {
        remarkId = 0;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchToppingData() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_topping_data';
    final body = jsonEncode({
      'product_id': widget.productId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        toppingData = toppingModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchLocationTypyData() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_location_type_data';
    final body = jsonEncode({});
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);

    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        locationTypeData = locationTypeModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  addProductData() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}add_product_data';
    final body = jsonEncode({
      'product_id': widget.productId,
      'orderhd_id': widget.orderId,
      'product_price': widget.productPrice,
      'qty': qty,
      'total_price': totalPrice,
      'table_id': widget.tableId,
      'location_type': type,
      'remark_id': remarkId,
      'remark_text': remarkText,
      'print_receipt': printReceipt,
      'emp_id': widget.empId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'toppings': toppings,
      'option': option,
    });
    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
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
    fetchToppingData();
    fetchRemarkData();
    fetchLocationTypyData();
    totalPrice = widget.productPrice;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            btnAddQtyProduct(),
            remarkData.isNotEmpty ? haveRemark() : Container(),
            toppingData.isNotEmpty ? topping() : Container(),
            toppings.isNotEmpty ? showTopping() : Container(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: TextField(
                style: const TextStyle(fontFamily: 'Kanit'),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide:
                        BorderSide(color: MyStyle().prinaryColor, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
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
            ),
            locationType(),
            slip(),
          ],
        ),
      ),
      bottomNavigationBar: addProduct(),
    );
  }

  Widget showTopping() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          toppings.length,
          (index) => SizedBox(
            width: 400,
            child: ListTile(
              title: Text(
                '${index + 1}. ${toppings[index]['master_product_name']}',
              ),
              subtitle: Text(
                  '${NumberFormat.currency(name: '').format(toppings[index]['total_price_topping'])} บาท'),
              trailing: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (toppings[index]['topping_qty'] > 1) {
                          setState(() {
                            totalPrice -=
                                toppings[index]['master_product_price1'];
                            toppings[index]['topping_qty']--;
                            toppings[index]['total_price_topping'] -=
                                toppings[index]['master_product_price1'];
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Color(0xffff616f),
                        size: 26,
                      ),
                    ),
                    Text(
                      '${toppings[index]['topping_qty']}',
                      style: FontStyle().h2Style(0xff000000, 16),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          totalPrice +=
                              toppings[index]['master_product_price1'];
                          toppings[index]['topping_qty']++;
                          toppings[index]['total_price_topping'] +=
                              toppings[index]['master_product_price1'];
                        });
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget topping() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: MultiSelectDialogField(
            listType: MultiSelectListType.CHIP,
            itemsTextStyle: const TextStyle(fontFamily: 'Kanit'),
            dialogHeight: 250,
            searchable: true,
            items: toppingData
                .map((e) => MultiSelectItem<ToppingDataModel>(e,
                    '${e.productName!} : ${NumberFormat.currency(name: '').format(double.parse(e.productPrice!))} บาท'))
                .toList(),
            title: const Text("Topping"),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
            buttonIcon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.blue,
            ),
            buttonText: Text(
              "Topping",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 16,
              ),
            ),
            onConfirm: (value) {
              toppings = [];
              List data = value;
              setState(() {
                totalPrice = widget.productPrice * qty;
                for (var item in data) {
                  totalPrice += double.parse(item.productPrice);
                  toppings.add({
                    "master_product_id": item.productId,
                    "master_product_name": item.productName,
                    "master_product_price1": double.parse(item.productPrice),
                    "total_price_topping": double.parse(item.productPrice),
                    "topping_qty": 1
                  });
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget addProduct() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          int count = 0;
          for (var item in option) {
            if (item['option_id'] != 0) {
              count += 1;
            }
          }
          if (count == countOption) {
            if (loading) {
              null;
            } else {
              await addProductData();
            }
          } else {
            AlertDialogs()
                .alertWarning(context, 'กรุณเลือกตัวเลือกเพิ่มเติมให้ครบ');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            color: loading ? Colors.grey[200] : Color(0xff4fc3f7),
          ),
          height: 70,
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
                    color: const Color(0xff4fc3f7),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_shopping_cart,
                        color: Color(0xffFFFFFF),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'เพิ่มใส่ตะกร้า',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xffFFFFFF),
                  ),
                ),
                Text(
                  '${NumberFormat.currency(name: '').format(totalPrice)} บาท',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xffFFFFFF),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding btnAddQtyProduct() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
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
            color: const Color(0xffff616f),
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
              setState(() {
                qty++;
                totalPrice += widget.productPrice;
              });
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
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff8470FF), width: 2),
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

  Widget haveRemark() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
          child: Text(
            'กรุณาเลือกให้ครบ',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
                remarkData.length,
                (index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          remarkData[index].optionGroupName!,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                        Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.start,
                          spacing: 70,
                          runSpacing: 5,
                          runAlignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: List.generate(
                            remarkData[index].optionItem!.length,
                            (indexs) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 60, top: 10),
                                child: SizedBox(
                                  width: 50,
                                  child: Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Radio(
                                          value: int.parse(remarkData[index]
                                              .optionItem![indexs]
                                                  ['option_items_id']
                                              .toString()),
                                          groupValue: option[index]
                                              ['option_id'],
                                          onChanged: (values) {
                                            setState(() {
                                              option[index]['option_id'] =
                                                  values!;
                                            });
                                          },
                                        ),
                                      ),
                                      Text(
                                        remarkData[index].optionItem![indexs]
                                            ['option_items_name']!,
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
                    )),
          ),
        ),
      ],
    );
  }

  Padding locationType() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffbbdefb), width: 2),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            locationTypeData.length,
            (index) {
              if (widget.tableTypeId == '1') {
                return Padding(
                  padding: const EdgeInsets.only(right: 60),
                  child: SizedBox(
                    width: 40,
                    child: Row(
                      children: [
                        Radio(
                          value: int.parse(
                              locationTypeData[index].locationTypeId!),
                          groupValue: selectedChoice,
                          onChanged: (int? values) => {
                            setState(() {
                              selectedChoice = values!;
                              type = selectedChoice;
                            })
                          },
                        ),
                        Text(
                          locationTypeData[index].locationTypeName!,
                          style: FontStyle().h2Style(0xff000000, 14),
                        ),
                      ],
                    ),
                  ),
                );
              }
              setState(() {
                type = 2;
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
                        groupValue: selectedChoice2,
                        onChanged: (int? values) => {null},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          locationTypeData[index].locationTypeName!,
                          style: FontStyle().h2Style(0xff000000, 16),
                        ),
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
