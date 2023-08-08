import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/buffet/buffet_detail/buffet_detail.dart';
import 'package:oho_pos_v3/main_menu/buffet/buffet_detail/model_data_buffet_detail/model_data_option.dart';
import 'package:oho_pos_v3/main_menu/category_detail/busket_detail.dart';
import 'package:oho_pos_v3/main_menu/category_detail/category_detail.dart';
import 'package:oho_pos_v3/main_menu/order_product/order_product.dart';
import 'package:oho_pos_v3/main_menu/order_product/order_product_for_search.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:oho_pos_v3/url_api/url_api_other.dart';
import 'package:provider/src/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../CounterProvider.dart';
import 'model_data_category_buffet/autocomplete_buffet.dart';
import 'model_data_category_buffet/model_data_category_buffet.dart';

class CategoryBuffet extends StatefulWidget {
  final String? tableId;
  final String? orderId;
  final String? buffethdId;
  final String? buffetName;
  final String? tableName;
  final String? branchId;
  final String? tableTypeId;
  final String? empId;
  final String? companyId;
  final String? buffetPrice;
  final bool? buffetActive;
  final bool? alacarteActive;
  final int? orderQty;
  final int? allBalanchBuffethdQty;
  final bool? buffethdOrderInfinity;
  final int? limitOrderQty;
  final int? packageId;
  const CategoryBuffet({
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
    required this.alacarteActive,
    required this.packageId,
  }) : super(key: key);

  @override
  _CategoryBuffetState createState() => _CategoryBuffetState();
}

class _CategoryBuffetState extends State<CategoryBuffet> {
  List<CategoryBuffetDataModel> categoryData = [];
  List<AllProductInBuffetModel> allProductdata = [];
  List<OptionDataModel> optionData = [];
  String? orderhdId;
  bool loading = true;
  int orderType = 0;
  List orderBuffetData = [];
  List option = [];
  int countOrder = 1;
  String remarkText = "ไม่มีหมายเหตุ";
  int selectedPrintreceipt = 1;
  bool printReceipt = true;
  int countOption = 0;
  int balanchBuffetQty = 0;
  List timeData = [];
  double? screenWidth;

  fetchCategoryBuffetData() async {
    final url = '${UrlApi().url}get_category_buffet_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'buffethd_id': widget.buffethdId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty && response.statusCode == 200) {
      setState(() {
        loading = false;
        categoryData = categoryBuffetModelFromJson(jsonEncode(response.data));
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future<List<AllProductInBuffetModel>> fetchAllProductInBuffetData(
      String query) async {
    final url = '${UrlApi().url}get_all_product_inbuffet_data';
    final body = jsonEncode({
      'buffethd_id': widget.buffethdId,
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
      'order_qty': widget.orderQty,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty && response.statusCode == 200) {
      setState(() {
        loading = false;
        allProductdata =
            productAllInbuffetModelFromJson(jsonEncode(response.data));
        orderBuffetData = response.data;
      });
    }
    AlertDialogs().progressDialog(context, loading);
    return allProductdata.where((products) {
      final productName = products.productName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return productName.contains(queryLower);
    }).toList();
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

  @override
  void initState() {
    fetchOrderdtBuffetData();
    fetchCategoryBuffetData();
    fetchEndTimeData();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.buffethdOrderInfinity == true
                          ? const Text(
                              'ไม่จำกัดรายการที่สั่ง',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: TypeAheadField<AllProductInBuffetModel>(
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                borderRadius: BorderRadius.circular(35),
              ),
              textFieldConfiguration: TextFieldConfiguration(
                style: const TextStyle(fontFamily: 'Kanit'),
                autofocus: false,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                    borderSide:
                        BorderSide(color: MyStyle().lightColor, width: 1),
                  ),
                  label: Text(
                    'ค้นหารายการอาหาร',
                    style: FontStyle().h2Style(0xff778899, 16),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
              ),
              suggestionsCallback: fetchAllProductInBuffetData,
              minCharsForSuggestions: 1,
              itemBuilder: (context, AllProductInBuffetModel suggestion) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      '${UrlApiOther().apiShowProductImage}${suggestion.imgName}',
                      width: 50,
                      height: 50,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'assets/images/buffet.png',
                          width: 50,
                          height: 50,
                        );
                      },
                    ),
                  ),
                  title: Text(
                    '${suggestion.productName}',
                    style: FontStyle().h2Style(0xff000000, 16),
                  ),
                  subtitle: Text(
                    'ราคา ${NumberFormat.currency(name: '').format(double.parse(suggestion.productPrice!))} บาท',
                    style: FontStyle().h2Style(0, 14),
                  ),
                );
              },
              onSuggestionSelected: (AllProductInBuffetModel suggestion) {
                if (suggestion.balanchOrderdtQty == 0 &&
                    suggestion.orderInfinity == false) {
                  setState(() {
                    countOrder = 0;
                  });
                }
                selectOption(
                  int.parse(suggestion.productId!),
                  suggestion.productName!,
                  suggestion.countNumber!,
                );
              },
              noItemsFoundBuilder: (contex) => Center(
                child: Text('ไม่พบรายการอาหารที่ค้นหา',
                    style: FontStyle().h2Style(0, 20)),
              ),
            ),
          ),
          Expanded(
            child: _buildListView(),
          ),
        ],
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
                page: widget.packageId == 9 ? 2 : 1,
              ),
            ),
          )
              .then((value) {
            fetchEndTimeData();
            fetchOrderdtBuffetData();
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
    );
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
                            // print(balanchBuffetQty);
                            if (balanchBuffetQty - 1 > 0 ||
                                widget.buffethdOrderInfinity == true) {
                              if (countOrder <
                                      allProductdata[item].balanchOrderdtQty! ||
                                  allProductdata[item].orderInfinity!) {
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

  ListView _buildListView() {
    return ListView.builder(
      itemCount: categoryData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: ListTile(
            mouseCursor: null,
            hoverColor: Colors.blue[100],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuffetDetail(
                    productGroupName: categoryData[index].categoryName,
                    productGroupId: categoryData[index].categoryId,
                    buffethdId: widget.buffethdId,
                    buffetName: widget.buffetName,
                    buffetPrice: widget.buffetPrice,
                    tableName: widget.tableName,
                    orderId: widget.orderId,
                    tableId: widget.tableId,
                    tableTypeId: widget.tableTypeId,
                    empId: widget.empId,
                    companyId: widget.companyId,
                    branchId: widget.branchId,
                    buffetActive: widget.buffetActive,
                    orderQty: widget.orderQty,
                    allBalanchBuffethdQty: widget.allBalanchBuffethdQty,
                    buffethdOrderInfinity: widget.buffethdOrderInfinity,
                    limitOrderQty: widget.limitOrderQty,
                    alacarteActive: widget.alacarteActive,
                    packageId: widget.packageId,
                  ),
                ),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${UrlApiOther().apiShowProductGroupImage}${categoryData[index].imageGroupname}',
                width: 80,
                height: 80,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    'assets/images/buffet.png',
                    width: 80,
                    height: 80,
                  );
                },
              ),
            ),
            title: Text(
              categoryData[index].categoryName!,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            subtitle: Text(categoryData[index].productQty!,
                style: const TextStyle(fontSize: 20, color: Color(0xff778899))),
            trailing: const Text(
              'เลือก',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        );
      },
    );
  }

  alertMessageBack(String text) {
    Alert(
      closeFunction: () {
        Navigator.of(context)
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
              ..pop();
          },
          width: 120,
          radius: const BorderRadius.all(Radius.circular(30)),
        )
      ],
    ).show();
  }
}
