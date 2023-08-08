import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'button_widget.dart';
import 'model_data_order_history/model_data_order_history.dart';
import 'order_history_detail.dart';

class OrderHistory extends StatefulWidget {
  final String? branchId;
  final String? companyId;
  const OrderHistory({
    Key? key,
    required this.branchId,
    required this.companyId,
  }) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  bool loading = true;
  DateTime? date;
  String? selectDate = DateFormat('y-M-dd').format(DateTime.now());
  List<OrderHistoryModel> orderHistoryData = [];

  String getText() {
    if (date == null) {
      return DateFormat('EEEE d/MMMM/y', 'th').format(DateTime.now());
    } else {
      return DateFormat('EEEE d/MMMM/y', 'th').format(date!);
    }
  }

  fetchOrderHistoryData(String selectDate) async {
    final url = '${UrlApi().url}get_order_history_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'select_date': selectDate,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        orderHistoryData = orderHistoryModelFromJson(jsonEncode(response.data));
        loading = false;
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  Future<List<OrderHistoryModel>> autocompleteTableOrder(String query) async {
    final url = '${UrlApi().url}get_order_history_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'select_date': selectDate,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        loading = false;
        orderHistoryData = orderHistoryModelFromJson(jsonEncode(response.data));
      });
    }
    AlertDialogs().progressDialog(context, loading);
    return orderHistoryData.where((order) {
      final tableName = order.tableName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return tableName.contains(queryLower);
    }).toList();
  }

  @override
  void initState() {
    fetchOrderHistoryData(selectDate!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return fetchOrderHistoryData(selectDate!);
        },
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: ButtonHeaderWidget(
                        title: 'Date',
                        text: getText(),
                        onClicked: () => pickDate(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TypeAheadField<OrderHistoryModel>(
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
                      itemBuilder: (context, OrderHistoryModel suggestion) {
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
                      onSuggestionSelected: (OrderHistoryModel suggestion) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrderHistoryDetail(
                              orderId: suggestion.orderhdId!,
                              orderDocuno: suggestion.orderhdDocuno!,
                              branchId: widget.branchId,
                              companyId: widget.companyId,
                            ),
                          ),
                        );
                      },
                      noItemsFoundBuilder: (contex) => Center(
                        child: Text('ไม่พบข้อมูล',
                            style: FontStyle().h2Style(0, 20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: orderHistoryData.isNotEmpty
                  ? listOrdersInPaymented()
                  : const Center(
                      child: Text(
                        'ไม่มีรายการออเดอร์ในวันนี้',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Future pickDate(BuildContext context) async {
    final newDateTime = await showRoundedDatePicker(
      theme: ThemeData(
        primaryColor: MyStyle().lightColor,
        hintColor: Colors.blue,
      ),
      context: context,
      locale: const Locale("th", "TH"),
      era: EraMode.BUDDHIST_YEAR,
    );
    if (newDateTime == null) return;
    setState(() {
      date = newDateTime;
      selectDate = DateFormat('y-M-dd').format(date!);
      fetchOrderHistoryData(selectDate!);
    });
  }

  Widget listOrdersInPaymented() {
    return ListView.builder(
      itemCount: orderHistoryData.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: ListTile(
            hoverColor: const Color(0xff4fc3f7),
            title: Text(
              '${orderHistoryData[index].orderhdDocuno}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${orderHistoryData[index].tableName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    )),
                Text('จำนวนลูกค้า ${orderHistoryData[index].customerQty} คน',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    )),
                Text(
                    'มูลค่ารวม ${NumberFormat.currency(name: '').format(
                      int.parse(orderHistoryData[index].orderhdNetamnt!),
                    )} บาท',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    )),
              ],
            ),
            trailing: Text('${orderHistoryData[index].zoneName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                )),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderHistoryDetail(
                    orderId: orderHistoryData[index].orderhdId!,
                    orderDocuno: orderHistoryData[index].orderhdDocuno!,
                    branchId: widget.branchId,
                    companyId: widget.companyId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
