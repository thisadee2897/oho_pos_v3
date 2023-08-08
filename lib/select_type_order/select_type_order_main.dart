import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:oho_pos_v3/CounterProvider.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/main_menu/busket/busket.dart';
import 'package:oho_pos_v3/main_menu/list_product_in_order/list_product_in_order.dart';
import 'package:oho_pos_v3/main_menu/list_product_in_payment/list_product_in_payment.dart';
import 'package:oho_pos_v3/select_type_order/select_type_order.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';

class SelectTypeOrderMain extends StatefulWidget {
  final String? tableId;
  final String? tableName;
  final String? zoneName;
  final String? branchId;
  final String? companyId;
  final String? tableTypeId;
  final String? empId;
  final String? userId;
  final bool? menuActionActive;
  final bool? buffetActive;
  final bool? alacarteActive;
  final int? packageId;
  const SelectTypeOrderMain({
    Key? key,
    required this.tableId,
    required this.tableName,
    required this.zoneName,
    required this.branchId,
    required this.tableTypeId,
    required this.empId,
    required this.menuActionActive,
    required this.companyId,
    required this.userId,
    required this.buffetActive,
    required this.alacarteActive,
    required this.packageId,
  }) : super(key: key);

  @override
  State<SelectTypeOrderMain> createState() => _SelectTypeOrderMainState();
}

class _SelectTypeOrderMainState extends State<SelectTypeOrderMain> {
  double? screen;
  bool loading = true;
  String? orderId;
  String? orderDocuno;

  int selectedIndex = 0;
  static List<Widget> widgetOptions = [];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  addWidget(orderHdId, orderDocuno) {
    setState(
      () {
        widgetOptions = [
          SelectTypeOrder(
            tableId: widget.tableId,
            tableName: widget.tableName,
            zoneName: widget.zoneName,
            tableTypeId: widget.tableTypeId,
            branchId: widget.branchId,
            empId: widget.empId,
            companyId: widget.companyId,
            menuActionActive: widget.menuActionActive,
            buffetActive: widget.buffetActive,
            orderhdId: orderHdId,
            orderhdDocuno: orderDocuno,
            userId: widget.userId,
            alacarteActive: widget.alacarteActive,
            packageId: widget.packageId,
          ),
          Busket(
            tableId: widget.tableId,
            tableName: widget.tableName,
            orderId: orderHdId,
            tableTypeId: widget.tableTypeId,
            companyId: widget.companyId,
            branchId: widget.branchId,
            buffetActive: widget.buffetActive,
            mainPage: 1,
            alacarteActive: widget.alacarteActive,
          ),
          ListProductInOrder(
            orderId: orderHdId,
            orderDocuno: orderDocuno,
            branchId: widget.branchId,
            tableName: widget.tableName,
            menuActionActive: widget.menuActionActive,
            empId: widget.empId,
            tableId: widget.tableId,
            companyId: widget.companyId,
            userId: widget.userId,
          ),
          ListProducInPayment(
            orderId: orderHdId,
            orderDocuno: orderDocuno,
            empId: widget.empId,
            branchId: widget.branchId,
            companyId: widget.companyId,
            buffetActive: widget.buffetActive,
            mainPage: 1,
            alacarteActive: widget.alacarteActive,
          )
        ];
      },
    );
  }

  fetchOrderData() async {
    widgetOptions = [];
    final url = '${UrlApi().url}get_order_data';
    final body = jsonEncode({
      'table_id': widget.tableId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty) {
      setState(() {
        orderId = response.data[0]['orderhd_id'];
        orderDocuno = response.data[0]['orderhd_docuno'];
        loading = false;
      });
      await addWidget(orderId, orderDocuno);
      await fetchProductDataInBusket(orderId);
      await fetchProductDataInOrder(orderId);
    } else {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    }

    AlertDialogs().progressDialog(context, loading);
  }

  fetchProductDataInBusket(orderHdId) async {
    final url = '${UrlApi().url}get_product_data_in_busket';
    final body = jsonEncode({
      'order_id': orderHdId,
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

  fetchProductDataInOrder(orderHdId) async {
    final url = '${UrlApi().url}get_product_data_in_order';
    final body = jsonEncode({
      'orderhd_id': orderHdId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data.isNotEmpty || response.statusCode == 200) {
      setState(() {
        loading = false;
        context
            .read<CounterProvider>()
            .addValueCountProductInOrder(response.data.length);
      });
      await AlertDialogs().progressDialog(context, loading);
    }
  }

  @override
  void initState() {
    fetchOrderData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '${widget.zoneName} ${widget.tableName}',
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
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
            // bottomLeft: Radius.circular(40),
            // bottomRight: Radius.circular(40),
            ),
        child: BottomNavigationBar(
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Kanit',
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 10,
          ),
          showUnselectedLabels: true,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.food_bank,
              ),
              label: 'สั่งอาหาร',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: badges.Badge(
                // shape: badges.BadgeShape.circle,
                position: badges.BadgePosition.topEnd(),
                badgeContent: Text(
                  '${context.watch<CounterProvider>().countProductInBusket}',
                  style: FontStyle().h2Style(0xffFFFFFF, 14),
                ),
                // borderRadius: BorderRadius.circular(100),
                child: const Icon(Icons.shopping_basket),
              ),
              label: 'ตะกร้า',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: badges.Badge(
                // shape: BadgeShape.circle,
                position: badges.BadgePosition.topEnd(),
                badgeContent: Text(
                  '${context.watch<CounterProvider>().countProductInOrder}',
                  style: FontStyle().h2Style(0xffFFFFFF, 14),
                ),
                // borderRadius: BorderRadius.circular(100),
                child: const Icon(Icons.list),
              ),
              label: 'รายการที่สั่ง',
              backgroundColor: Colors.white,
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.payment_outlined,
              ),
              label: 'แจ้งยอดชำระเงิน',
              backgroundColor: Colors.white,
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
