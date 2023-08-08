import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/buffet/buffet_detail/buffet_detail.dart';
import 'package:oho_pos_v3/main_menu/buffet/category_buffet/category_buffet.dart';
import 'package:oho_pos_v3/main_menu/category_detail/category_detail.dart';
import 'package:oho_pos_v3/main_menu/order_product/order_product.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:oho_pos_v3/url_api/url_api_other.dart';
import 'package:provider/src/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:universal_html/html.dart';
import '../../CounterProvider.dart';
import 'model_data_buffet.dart/autocomplete_buffet_data.dart';
import 'model_data_buffet.dart/model_data_buffet.dart';
import 'order_product_in_buffet/order_product_in_buffet.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Buffet extends StatefulWidget {
  final String? tableId;
  final String? tableName;
  final String? zoneName;
  final String? branchId;
  final String? tableTypeId;
  final String? empId;
  final String? orderId;
  final String? companyId;
  final bool? buffetActive;
  final bool? alacarteActive;
  final int? packageId;
  const Buffet({
    Key? key,
    required this.tableId,
    required this.tableName,
    required this.zoneName,
    required this.branchId,
    required this.tableTypeId,
    required this.empId,
    required this.orderId,
    required this.companyId,
    required this.buffetActive,
    required this.alacarteActive,
    required this.packageId,
  }) : super(key: key);

  @override
  _BuffetState createState() => _BuffetState();
}

class _BuffetState extends State<Buffet> {
  List<BuffetDataModel> buffetData = [];
  List<AutocompleteBuffetDataModel> autocomplete = [];
  List orderBuffetData = [];
  bool loading = true;
  String numberOfCustomers = "";
  int qty = 1;
  late IO.Socket socket;
  String gg = "";

  fetchProbuffetData() async {
    final url = '${UrlApi().url}get_probuffet_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        buffetData = buffetModelFromJson(jsonEncode(response.data));
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchOrderbuffetData() async {
    final url = '${UrlApi().url}get_order_buffet_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty) {
      setState(() {
        orderBuffetData = response.data;
        loading = false;
        // fetchProbuffetData();
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  orderBuffet(
    String productId,
    String buffethdId,
    String buffetName,
    String buffetPrice,
  ) async {
    final url = '${UrlApi().url}order_buffet';
    final body = jsonEncode({
      'product_id': productId,
      'orderhd_id': widget.orderId,
      'buffethd_id': buffethdId,
      'qty': qty,
      'emp_id': widget.empId,
      'table_id': widget.tableId,
      'buffet_price': buffetPrice,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => CategoryBuffet(
              buffethdId: buffethdId,
              buffetName: buffetName,
              buffetPrice: buffetPrice,
              tableName: widget.tableName,
              orderId: widget.orderId,
              tableId: widget.tableId,
              tableTypeId: widget.tableTypeId,
              empId: widget.empId,
              companyId: widget.companyId,
              branchId: widget.branchId,
              buffetActive: widget.buffetActive,
              orderQty: int.parse(response.data[0]['buffethd_order_qty']),
              allBalanchBuffethdQty:
                  int.parse(response.data[0]['all_balanch_qty']),
              buffethdOrderInfinity: response.data[0]
                  ['buffethd_order_infinity'],
              limitOrderQty: int.parse(response.data[0]['limit_order_qty']),
              alacarteActive: widget.alacarteActive,
              packageId: widget.packageId,
            ),
          ),
        )
            .then((value) {
          fetchProbuffetData();
          fetchOrderbuffetData();
        });
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future<List<AutocompleteBuffetDataModel>> autocompleteBuffetData(
      String query) async {
    final url = '${UrlApi().url}get_probuffet_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'orderhd_id': widget.orderId,
    });

    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty && response.statusCode == 200) {
      setState(() {
        loading = false;
        autocomplete =
            autocompleteBuffetModelFromJson(jsonEncode(response.data));
      });
    }

    AlertDialogs().progressDialog(context, loading);
    return autocomplete.where((products) {
      final buffetName = products.buffetName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return buffetName.contains(queryLower);
    }).toList();
  }

  fetchProductDataInBusket() async {
    context.read<CounterProvider>().resetCountProduct();
    final url = '${UrlApi().url}get_product_data_in_busket';
    final body = jsonEncode({
      'order_id': widget.orderId,
      'table_id': widget.tableId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200 || response.data.isNotEmpty) {
      setState(() {
        loading = false;
        context
            .read<CounterProvider>()
            .addValueCountProductInBusket(response.data.length);
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  // void socketServer() {
  //   try {
  //     socket = IO.io(UrlApi().url, <String, dynamic>{
  //       'transports': ['websocket'],
  //       'autoConnect': false
  //     });

  //     socket.connect();
  //     socket.onConnect((data) {
  //       socket.on('probuffet_data', (res) {
  //         setState(() {
  //           buffetData = buffetModelFromJson(jsonEncode(res));
  //           loading = false;
  //           // fetchProbuffetData();
  //         });
  //       });
  //     });

  //     // socket.onConnect((client) {
  //     //   fetchTableData();
  //     // });
  //     // Handle socket events

  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  @override
  void initState() {
    //socketServer();
    fetchProbuffetData();
    fetchOrderbuffetData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TypeAheadField<AutocompleteBuffetDataModel>(
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
                      'ค้นหารายการบุฟเฟ่ต์',
                      style: FontStyle().h2Style(0xff778899, 16),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                ),
                suggestionsCallback: autocompleteBuffetData,
                minCharsForSuggestions: 1,
                itemBuilder: (context, AutocompleteBuffetDataModel suggestion) {
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '${UrlApiOther().apiShowBuffetImage}${suggestion.buffetImageName}',
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
                      '${suggestion.buffetName}',
                      style: FontStyle().h2Style(0xff000000, 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        suggestion.limitOrderQty == 0
                            ? Text(
                                'ไม่จำกัดจำนวนการสั่ง',
                                style: FontStyle().h3Style(0xff00CC66, 14),
                              )
                            : Text(
                                'จำกัดจำนวนการสั่ง ${suggestion.limitOrderQty} รายการ',
                                style: FontStyle().h3Style(0xff778899, 14),
                              ),
                        suggestion.limitOrderQty == 0
                            ? Container()
                            : Text(
                                'คงเหลือ ${suggestion.balanchQty} รายการ',
                                style: FontStyle().h3Style(
                                    suggestion.balanchQty! > 0
                                        ? 0xff00CC66
                                        : 0xffFF0033,
                                    14),
                              ),
                        Text(
                          '(ราคา ${NumberFormat.currency(name: '').format(double.parse(suggestion.buffetPrice!))})',
                          style: FontStyle().h3Style(0xff778899, 16),
                        ),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        suggestion.orderBuffet!.isNotEmpty
                            ? Navigator.of(context)
                                .push(
                                MaterialPageRoute(
                                  builder: (context) => CategoryBuffet(
                                    buffethdId: suggestion.buffethdId,
                                    buffetName: suggestion.buffetName,
                                    buffetPrice: suggestion.buffetPrice!,
                                    orderId: widget.orderId,
                                    tableId: widget.tableId,
                                    tableTypeId: widget.tableTypeId,
                                    empId: widget.empId,
                                    companyId: widget.companyId,
                                    branchId: widget.branchId,
                                    orderQty: suggestion.orderQty,
                                    allBalanchBuffethdQty:
                                        suggestion.balanchQty,
                                    buffethdOrderInfinity:
                                        suggestion.buffethdOrderInfinity,
                                    limitOrderQty: suggestion.limitOrderQty,
                                    alacarteActive: widget.alacarteActive,
                                    packageId: widget.packageId,
                                    tableName: widget.tableName,
                                  ),
                                ),
                              )
                                .then((value) {
                                fetchProbuffetData();
                                fetchOrderbuffetData();
                                fetchProductDataInBusket();
                              })
                            : orderBuffetAlert(
                                suggestion.productId!,
                                suggestion.buffetName!,
                                suggestion.buffetPrice!,
                                suggestion.buffethdId!,
                              );
                      },
                      child: suggestion.orderBuffet!.isNotEmpty
                          ? const Text('สั่งอาหาร')
                          : const Text('เลือก'),
                    ),
                  );
                },
                onSuggestionSelected: (AutocompleteBuffetDataModel suggestion) {
                  suggestion.orderBuffet!.isNotEmpty
                      ? Navigator.of(context)
                          .push(
                          MaterialPageRoute(
                            builder: (context) => CategoryBuffet(
                              buffethdId: suggestion.buffethdId,
                              buffetName: suggestion.buffetName,
                              buffetPrice: suggestion.buffetPrice!,
                              orderId: widget.orderId,
                              tableId: widget.tableId,
                              tableTypeId: widget.tableTypeId,
                              empId: widget.empId,
                              companyId: widget.companyId,
                              branchId: widget.branchId,
                              orderQty: suggestion.orderQty,
                              allBalanchBuffethdQty: suggestion.balanchQty,
                              buffethdOrderInfinity:
                                  suggestion.buffethdOrderInfinity,
                              limitOrderQty: suggestion.limitOrderQty,
                              alacarteActive: widget.alacarteActive,
                              packageId: widget.packageId,
                            ),
                          ),
                        )
                          .then((value) {
                          fetchProbuffetData();
                          fetchOrderbuffetData();
                          fetchProductDataInBusket();
                        })
                      : orderBuffetAlert(
                          suggestion.productId!,
                          suggestion.buffetName!,
                          suggestion.buffetPrice!,
                          suggestion.buffethdId!,
                        );
                },
                noItemsFoundBuilder: (contex) => Center(
                  child: Text('ไม่พบรายการบุเฟ่ต์ที่ค้นหา',
                      style: FontStyle().h2Style(0, 20)),
                ),
              ),
            ),
            buffetData.isNotEmpty
                ? Expanded(
                    child: _buildListView(),
                  )
                : const Center(
                    child: Text(
                      'ไม่พบข้อมูลบุฟเฟต์',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: buffetData.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: ListTile(
            mouseCursor: null,
            hoverColor: Colors.blue[100],
            onTap: () {
              buffetData[index].orderBuffet!.isNotEmpty

                  // ? Navigator.of(context)
                  //     .push(
                  //     MaterialPageRoute(
                  //       builder: (context) => BuffetDetail(
                  //         buffethdId: buffetData[index].buffethdId,
                  //         buffetName: buffetData[index].buffetName,
                  //         buffetPrice: buffetData[index].buffetPrice,
                  //         tableName: widget.tableName,
                  //         orderId: widget.orderId,
                  //         tableId: widget.tableId,
                  //         tableTypeId: widget.tableTypeId,
                  //         empId: widget.empId,
                  //         companyId: widget.companyId,
                  //         branchId: widget.branchId,
                  //         buffetActive: widget.buffetActive,
                  //         orderQty: buffetData[index].orderQty,
                  //         allBalanchBuffethdQty: buffetData[index].balanchQty,
                  //         buffethdOrderInfinity:
                  //             buffetData[index].buffethdOrderInfinity,
                  //         limitOrderQty: buffetData[index].limitOrderQty,
                  //       ),
                  //     ),
                  //   )
                  //     .then((value) {
                  //     fetchProbuffetData();
                  //     fetchOrderbuffetData();
                  //     fetchProductDataInBusket();
                  //   })
                  ? Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryBuffet(
                          buffethdId: buffetData[index].buffethdId,
                          buffetName: buffetData[index].buffetName,
                          buffetPrice: buffetData[index].buffetPrice,
                          tableName: widget.tableName,
                          orderId: widget.orderId,
                          tableId: widget.tableId,
                          tableTypeId: widget.tableTypeId,
                          empId: widget.empId,
                          companyId: widget.companyId,
                          branchId: widget.branchId,
                          buffetActive: widget.buffetActive,
                          orderQty: buffetData[index].orderQty,
                          allBalanchBuffethdQty: buffetData[index].balanchQty,
                          buffethdOrderInfinity:
                              buffetData[index].buffethdOrderInfinity,
                          limitOrderQty: buffetData[index].limitOrderQty,
                          alacarteActive: widget.alacarteActive,
                          packageId: widget.packageId,
                        ),
                      ),
                    )
                  : orderBuffetAlert(
                      buffetData[index].productId!,
                      buffetData[index].buffetName!,
                      buffetData[index].buffetPrice!,
                      buffetData[index].buffethdId!,
                    );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                '${UrlApiOther().apiShowBuffetImage}${buffetData[index].buffetImageName}',
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
              buffetData[index].buffetName!,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buffetData[index].limitOrderQty == 0
                    ? const Text(
                        'ไม่จำกัดจำนวนการสั่ง',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      )
                    : Text(
                        'จำกัดจำนวนการสั่ง ${buffetData[index].limitOrderQty} รายการ',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                buffetData[index].limitOrderQty == 0
                    ? Container()
                    : Text(
                        'คงเหลือ ${buffetData[index].balanchQty} รายการ',
                        style: TextStyle(
                            fontSize: 14,
                            color: buffetData[index].balanchQty! > 0
                                ? Colors.green
                                : Colors.red),
                      ),
                Text(
                  'ราคา ${NumberFormat.currency(name: '').format(double.parse(buffetData[index].buffetPrice!))}',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xff778899)),
                ),
              ],
            ),
            trailing: TextButton(
              onPressed: () {
                buffetData[index].orderBuffet!.isNotEmpty
                    ? Navigator.of(context)
                        .push(
                        MaterialPageRoute(
                          builder: (context) => CategoryBuffet(
                            buffethdId: buffetData[index].buffethdId,
                            buffetName: buffetData[index].buffetName,
                            buffetPrice: buffetData[index].buffetPrice,
                            tableName: widget.tableName,
                            orderId: widget.orderId,
                            tableId: widget.tableId,
                            tableTypeId: widget.tableTypeId,
                            empId: widget.empId,
                            companyId: widget.companyId,
                            branchId: widget.branchId,
                            buffetActive: widget.buffetActive,
                            orderQty: buffetData[index].orderQty,
                            allBalanchBuffethdQty: buffetData[index].balanchQty,
                            buffethdOrderInfinity:
                                buffetData[index].buffethdOrderInfinity,
                            limitOrderQty: buffetData[index].limitOrderQty,
                            alacarteActive: widget.alacarteActive,
                            packageId: widget.packageId,
                          ),
                        ),
                      )
                        .then((value) {
                        fetchProbuffetData();
                        fetchOrderbuffetData();
                        fetchProductDataInBusket();
                      })
                    : orderBuffetAlert(
                        buffetData[index].productId!,
                        buffetData[index].buffetName!,
                        buffetData[index].buffetPrice!,
                        buffetData[index].buffethdId!,
                      );
              },
              child: buffetData[index].orderBuffet!.isNotEmpty
                  ? const Text('สั่งอาหาร')
                  : const Text('เลือก'),
            ),
          ),
        );
      },
    );
  }

  orderBuffetAlert(
    String productId,
    String buffetName,
    String buffetPrice,
    String buffethdId,
  ) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buffetName,
                      style: FontStyle().h2Style(0xff000000, 16),
                    ),
                    Text(
                      'ราคา ${buffetPrice}.00 บาท',
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
                          setState(() {
                            qty++;
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.green,
                        iconSize: 50,
                      ),
                    ],
                  ),
                ),
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
          radius: const BorderRadius.all(Radius.circular(20)),
          child: Text(
            "ปิด",
            style: FontStyle().h2Style(0xff4fc3f7, 16),
          ),
          onPressed: () => Navigator.pop(context),
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
          onPressed: () {
            // if (numberOfCustomers == '') {
            //   AlertDialogs().alertWarning(context, 'โปรดกรอกจำนวนลูกค้า');
            //   return;
            // }
            Navigator.pop(context);
            orderBuffet(
              productId,
              buffethdId,
              buffetName,
              buffetPrice,
            );
          },
        )
      ],
    ).show();
  }
}
