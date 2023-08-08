import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/buffet/buffet_detail/model_data_buffet_detail/model_data_option.dart';
import 'package:oho_pos_v3/main_menu/buffet/order_product_in_buffet/order_product_in_buffet.dart';
import 'package:oho_pos_v3/main_menu/category_detail/busket_detail.dart';
import 'package:oho_pos_v3/main_menu/order_product/order_product.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:badges/badges.dart' as badges;
import 'package:oho_pos_v3/url_api/url_api_other.dart';
import 'package:provider/src/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../CounterProvider.dart';
import 'model_data_buffet_detail/autocomplete_product_data.dart';
import 'model_data_buffet_detail/model_data_buffet_detail.dart';

class BuffetDetail extends StatefulWidget {
  final String? tableId;
  final String? orderId;
  final String? buffethdId;
  final String? buffetName;
  final String? tableName;
  final String? branchId;
  final String? tableTypeId;
  final String? empId;
  final String? companyId;
  final String? productGroupId;
  final String? productGroupName;
  final String? buffetPrice;
  final bool? buffetActive;
  final int? orderQty;
  final int? allBalanchBuffethdQty;
  final bool? buffethdOrderInfinity;
  final int? limitOrderQty;
  final bool? alacarteActive;
  final int? packageId;
  const BuffetDetail({
    Key? key,
    this.buffethdId,
    this.buffetName,
    this.orderId,
    this.tableId,
    this.tableName,
    this.branchId,
    this.tableTypeId,
    this.empId,
    this.companyId,
    this.buffetPrice,
    this.buffetActive,
    required this.orderQty,
    required this.allBalanchBuffethdQty,
    required this.buffethdOrderInfinity,
    required this.limitOrderQty,
    required this.productGroupId,
    required this.productGroupName,
    required this.alacarteActive,
    required this.packageId,
  }) : super(key: key);

  @override
  _BuffetDetailState createState() => _BuffetDetailState();
}

class _BuffetDetailState extends State<BuffetDetail> {
  bool loading = false;
  List<BuffetDataDetailModel> productData = [];
  List<OptionDataModel> optionData = [];
  List<AutocompleteProductsInBuffetModel> productDataAutocomplete = [];
  List timeData = [];
  int balanchBuffetQty = 0;
  List orderBuffetData = [];
  List option = [];
  int countOrder = 1;
  String remarkText = "ไม่มีหมายเหตุ";
  int selectedPrintreceipt = 1;
  bool printReceipt = true;
  int countOption = 0;
  double? screenWidth;
  fetchProductDataInBuffet() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_product_inbuffet_data';
    final body = jsonEncode({
      'buffethd_id': widget.buffethdId,
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
      'order_qty': widget.orderQty,
      'product_group_id': widget.productGroupId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 || response.data.isNotEmpty) {
      setState(() {
        productData = productInBuffetModelFromJson(jsonEncode(response.data));
        orderBuffetData = response.data;
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchOrderdtBuffetData() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_orderdt_buffet_data';
    final body = jsonEncode({
      'buffethd_id': widget.buffethdId,
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 || response.data.isNotEmpty) {
      setState(() {
        balanchBuffetQty =
            widget.limitOrderQty! - int.parse(response.data[0]['orderdt_qty']);
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchEndTimeData() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_end_time_data';
    final body = jsonEncode({
      'buffethd_id': widget.buffethdId,
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 || response.data.isNotEmpty) {
      setState(() {
        timeData = response.data;
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future<List<AutocompleteProductsInBuffetModel>> autocompleteProducts(
      String query) async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_product_inbuffet_data';
    final body = jsonEncode({
      'buffethd_id': widget.buffethdId,
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
      'order_qty': widget.orderQty,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    setState(() {
      loading = false;
      productDataAutocomplete = autocompleteProductInBuffetModelFromJson(
        jsonEncode(response.data),
      );
    });
    AlertDialogs().progressDialog(context, loading);
    return productDataAutocomplete.where((products) {
      final productName = products.productName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return productName.contains(queryLower);
    }).toList();
  }

  addProductDataInBuffet() async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}add_product_data_in_buffet';
    final body = jsonEncode({
      'order_id': widget.orderId,
      'table_id': widget.tableId,
      'user_id': widget.empId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'buffethd_id': widget.buffethdId,
      'product_data': orderBuffetData,
      'limit_order_qty': widget.limitOrderQty,
      'count_order': countOrder,
      'limit_time': timeData[0]['limit_hr'] + timeData[0]['limit_mi'],
      'time_to_eat_infinity': timeData[0]['time_to_eat_infinity'],
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 && response.data['status'] == 1) {
      fetchEndTimeData();
      fetchOrderdtBuffetData();
      fetchProductDataInBuffet();
      setState(() {
        countOrder = 1;
        loading = false;
        context.read<CounterProvider>().addValueCountProductInBusket(1);
        Navigator.of(context).pop();
      });
    } else if (response.data['status'] == 0) {
      alertMessageBack('${response.data['message']} !!');
      loading = false;
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchOptionData(int productId) async {
    setState(() {
      loading = true;
    });
    final url = '${UrlApi().url}get_remark_data';
    final body = jsonEncode({
      'product_id': productId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        option = [];
        optionData = [];
        optionData = optionDataModelFromJson(
          jsonEncode(response.data),
        );
        countOption = optionData.length;
        loading = false;
      });
      for (var item in optionData) {
        option.add({
          'option_group_name': "",
          'option_name': "",
          'option_id': 0,
        });
      }
    }
    AlertDialogs().progressDialog(context, loading);
  }

  @override
  void initState() {
    fetchEndTimeData();
    fetchOrderdtBuffetData();
    fetchProductDataInBuffet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '${widget.tableName}',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            label: const Text(
              'กลับ',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SizedBox(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          widget.buffethdOrderInfinity == true
                              ? const Text(
                                  'ไม่จำกัดรายการที่สั่ง',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                )
                              : Text(
                                  'คงเหลือ ${balanchBuffetQty} รายการ',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                          timeData[0]['time_to_eat_infinity'] == true
                              ? const Text('ไม่จำกัดเวลา')
                              : Text(
                                  'หมดเวลา ${timeData[0]['end_time']}',
                                  style: TextStyle(
                                    color: ((timeData[0]['limit_hr'] +
                                                timeData[0]['limit_mi']) >
                                            (timeData[0]['current_time_hr'] +
                                                timeData[0]['current_time_mi'])
                                        ? Colors.black
                                        : Colors.red),
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        '${widget.buffetName}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: productData.isNotEmpty
                  ? _buildListViewProducts()
                  : Center(
                      child: Text(
                        'ไม่มีรายการอาหารในโปรบุฟเฟต์หมู่นี้',
                        style: FontStyle().h2Style(0, 20),
                      ),
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => BusketDetail(
                tableId: widget.tableId,
                tableName: widget.tableName,
                orderId: widget.orderId,
                tableTypeId: widget.tableTypeId,
                companyId: widget.companyId,
                branchId: widget.branchId,
                buffetActive: widget.buffetActive,
                alacarteActive: widget.alacarteActive,
                page: widget.packageId == 9 ? 3 : 2,
              ),
            ),
          )
              .then((value) {
            fetchEndTimeData();
            fetchOrderdtBuffetData();
            fetchProductDataInBuffet();
          });
        },
        child: badges.Badge(
          // shape: BadgeShape.circle,
          position: badges.BadgePosition.topEnd(),
          badgeContent: Text(
            '${context.watch<CounterProvider>().countProductInBusket}',
            style: FontStyle().h2Style(0xffFFFFFF, 14),
          ),
          // borderRadius: BorderRadius.circular(100),
          child: const Icon(Icons.shopping_basket),
        ),
      ),
      //bottomNavigationBar: Container(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context)
      //         .push(
      //       MaterialPageRoute(
      //         builder: (context) => BusketDetail(
      //           tableId: widget.tableId,
      //           tableName: widget.tableName,
      //           orderId: widget.orderId,
      //           tableTypeId: widget.tableTypeId,
      //           companyId: widget.companyId,
      //           branchId: widget.branchId,
      //           buffetActive: widget.buffetActive,
      //         ),
      //       ),
      //     )
      //         .then((value) {
      //       fetchOrderdtBuffetData();
      //       fetchProductDataInBuffet();
      //     });
      //   },
      //   child: Badge(
      //     shape: BadgeShape.circle,
      //     position: BadgePosition.topEnd(),
      //     borderRadius: BorderRadius.circular(100),
      //     child: const Icon(Icons.shopping_basket),
      //     badgeContent: Text(
      //       '${context.watch<CounterProvider>().countProductInBusket}',
      //       style: FontStyle().h2Style(0xffFFFFFF, 14),
      //     ),
      //   ),
      // ),
    );
  }

  selectOption(int productId, String productName, int item) async {
    remarkText = 'ไม่มีหมายเหตุ';
    selectedPrintreceipt = 1;
    bool printReceipt = true;
    await fetchOptionData(productId);
    Alert(
      closeFunction: () {
        setState(() {
          countOrder = 1;
        });
        Navigator.pop(context);
      },
      style: MyStyle().alertStyle,
      context: context,
      content: SizedBox(
        width: screenWidth! < 500 ? double.maxFinite : 500,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (countOrder > 1) {
                              setState(() {
                                balanchBuffetQty++;
                                countOrder--;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Color(0xffff616f),
                            size: 35,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '${countOrder}',
                            style: FontStyle().h2Style(0xff000000, 25),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (balanchBuffetQty - 1 > 0 ||
                                widget.buffethdOrderInfinity == true) {
                              if (countOrder <
                                      productData[item].balanchOrderdtQty! ||
                                  productData[item].orderInfinity!) {
                                setState(() {
                                  countOrder++;
                                  balanchBuffetQty--;
                                });
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                optionData.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(left: 12, top: 5),
                        child: Text(
                          'กรุณาเลือกให้ครบ',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      optionData.length,
                      (index) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            optionData[index].optionGroupName!,
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
                              optionData[index].option!.length,
                              (indexs) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(right: 50, top: 10),
                                  child: SizedBox(
                                    width: 30,
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: int.parse(optionData[index]
                                              .option![indexs]
                                                  ['option_items_id']
                                              .toString()),
                                          groupValue: option[index]
                                              ['option_id'],
                                          onChanged: (values) {
                                            setState(() {
                                              option[index]
                                                      ['option_group_name'] =
                                                  optionData[index]
                                                      .optionGroupName!;
                                              option[index]['option_id'] =
                                                  values!;
                                              option[index]['option_name'] =
                                                  optionData[index]
                                                          .option![indexs]
                                                      ['option_items_name']!;
                                            });
                                          },
                                        ),
                                        Text(
                                          optionData[index].option![indexs]
                                              ['option_items_name']!,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xffaab6fe), width: 2),
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
                                const Text(
                                  'พิมพ์สลิป',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
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
                                const Text(
                                  'ไม่พิมพ์สลิป',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                )
              ],
            );
          },
        ),
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () {
            setState(() {
              countOrder = 1;
            });
            Navigator.pop(context);
          },
          color: Colors.transparent,
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
          onPressed: () async {
            int count = 0;
            if (countOrder != 0) {
              setState(() {
                productData[item].buffetdtQty = countOrder;
                productData[item].optionItem = option;
                productData[item].remark = remarkText;
                productData[item].printBillFlag = printReceipt;

                orderBuffetData[item]['buffetdt_qty'] = countOrder;
                orderBuffetData[item]['option_item'] = option;
                orderBuffetData[item]['remark'] = remarkText;
                orderBuffetData[item]['print_bill_flag'] = printReceipt;
              });
              for (var item in option) {
                if (item['option_id'] != 0) {
                  count += 1;
                }
              }
              if (count == countOption) {
                await addProduct();
              }
            }
          },
        )
      ],
    ).show();
  }

  ListView _buildListViewProducts() {
    return ListView.builder(
      itemCount: productData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
          child: ListTile(
            onTap: () {
              if (productData[index].balanchOrderdtQty == 0 &&
                  productData[index].orderInfinity == false) {
                setState(() {
                  countOrder = 0;
                });
              }
              selectOption(
                int.parse(productData[index].productId!),
                productData[index].productName!,
                index,
              );
            },
            mouseCursor: null,
            hoverColor: Colors.blue[100],
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${UrlApiOther().apiShowProductImage}${productData[index].imgName}',
                width: 100,
                height: 100,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    'assets/images/buffet.png',
                    width: 100,
                    height: 100,
                  );
                },
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    productData[index].productName!,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (productData[index].balanchOrderdtQty == 0 &&
                        productData[index].orderInfinity == false) {
                      setState(() {
                        countOrder = 0;
                      });
                    }
                    selectOption(
                      int.parse(productData[index].productId!),
                      productData[index].productName!,
                      index,
                    );
                  },
                  child: const Text('เลือก'),
                )
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                productData[index].limitOrderQty == 0
                    ? Container()
                    : Text(
                        'จำกัดการสั่ง ${productData[index].limitOrderQty! * widget.orderQty!} รายการ',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                productData[index].limitOrderQty == 0
                    ? Container()
                    : Text(
                        'คงเหลือ ${productData[index].balanchOrderdtQty} รายการ',
                        style: TextStyle(
                            fontSize: 14,
                            color: productData[index].balanchOrderdtQty! > 0
                                ? Colors.green
                                : Colors.red),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  addProduct() async {
    if (timeData[0]['time_to_eat_infinity'] == true) {
      if (loading) {
        null;
      } else {
        await addProductDataInBuffet();
      }
    } else {
      if ((timeData[0]['limit_hr'] + timeData[0]['limit_mi']) >
          (timeData[0]['current_time_hr'] + timeData[0]['current_time_mi'])) {
        await addProductDataInBuffet();
      } else {
        alertMessage('หมดเวลาในการนั่งทานแล้ว');
        null;
      }
    }
  }

  alertMessage(String text) {
    Alert(
      closeFunction: () {
        Navigator.of(context).pop();
      },
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.warning,
      content: Text(
        text,
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

  alertMessageBack(String text) {
    Alert(
      closeFunction: () {
        Navigator.of(context)
          ..pop()
          ..pop()
          ..pop()
          ..pop;
      },
      style: MyStyle().alertStyle,
      context: context,
      type: AlertType.warning,
      content: Text(
        text,
        style: FontStyle().h2Style(0xff000000, 16),
      ),
      buttons: [
        DialogButton(
          child: Text(
            "ตกลง",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            Navigator.of(context)
              ..pop()
              ..pop()
              ..pop()
              ..pop();
          },
          width: 120,
          radius: const BorderRadius.all(Radius.circular(30)),
        )
      ],
    ).show();
  }
}
