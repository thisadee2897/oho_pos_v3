// ignore_for_file: implementation_imports, use_build_context_synchronously, unnecessary_brace_in_string_interps, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:oho_pos_v3/main_menu/main_menu.dart';
import 'package:oho_pos_v3/select_type_order/select_type_order_main.dart';
import 'package:oho_pos_v3/style/style_colors.dart';
import 'package:provider/src/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'package:oho_pos_v3/alert_dialog/alert_dialog.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/http_request/http_request.dart';
import 'package:oho_pos_v3/url_api/url_api.dart';
import 'package:intl/intl.dart';
import '../../CounterProvider.dart';
import 'model_data_list_tables/model_data_table.dart';
import 'model_data_list_tables/model_data_zone.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class ListTables extends StatefulWidget {
  final String? branchPrefix;
  final String? empId;
  final String? branchId;
  final String? companyId;
  final String? userId;
  final bool? menuActionActive;
  final bool? buffetActive;
  final bool? alacarteActive;
  const ListTables({
    Key? key,
    this.branchId,
    this.branchPrefix,
    this.empId,
    this.companyId,
    required this.menuActionActive,
    required this.buffetActive,
    required this.userId,
    required this.alacarteActive,
  }) : super(key: key);

  @override
  _ListTablesState createState() => _ListTablesState();
}

class _ListTablesState extends State<ListTables> {
  List<ZoneDataModel> zoneData = [];
  List<TableDataModel> tableData = [];
  String numberOfCustomers = "";
  bool loading = true;
  String date = DateFormat('y-M-dd').format(DateTime.now());
  int year = int.parse(DateFormat('y').format(DateTime.now())) + 543;
  String month = DateFormat('MM').format(DateTime.now());
  String day = DateFormat('dd').format(DateTime.now());
  bool? statsuShiftOpen;
  int? packageId;
  int selectedPrintQrCode = 1;
  bool printQrCode = true;
  final TextEditingController _controller = TextEditingController();
  late Timer _timer;
  // late IO.Socket socket;

  fetchZoneData() async {
    final url = '${UrlApi().url}get_zone_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        zoneData = zoneModelFromJson(jsonEncode(response.data));
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  cancelOrder(tableId) async {
    final url = '${UrlApi().url}cancel_table';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
      'table_id': tableId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      fetchTableData(true);
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchPackegeId() async {
    final url = '${UrlApi().url}get_package_id';
    final body = jsonEncode({
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        packageId = int.parse(response.data[0]['package_id']);
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  checkShiftOpen() async {
    final url = '${UrlApi().url}check_shift_open';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        statsuShiftOpen = response.data['status_shift_open'];
      });
    }
    AlertDialogs().progressDialog(context, loading);
  }

  fetchTableData(bool loading) async {
    final url = '${UrlApi().url}get_table_data';
    final body = jsonEncode({
      'branch_id': widget.branchId,
      'company_id': widget.companyId,
    });
    // socket.emit('get_table_data', {
    //   'branch_id': widget.branchId,
    //   'company_id': widget.companyId,
    // });
    // socket.on('table_data', (data) {
    //   if (data.isNotEmpty) {
    //     setState(() {
    //       loading = false;
    //       tableData = tableModelFromJson(jsonEncode(data));
    //     });
    //   }
    // });

    final response =
        await HttpRequests().httpRequest(url, body, context, loading);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        tableData = tableModelFromJson(jsonEncode(response.data));
      });
    }

    AlertDialogs().progressDialog(context, loading);
  }

  createOrder(
    String tableId,
    String zoneId,
    String tableName,
    String zoneName,
    String tableTypeId,
  ) async {
    final url = '${UrlApi().url}create_order';
    final body = jsonEncode({
      'token_key': 'tumkratoei',
      'zone_id': zoneId,
      'table_id': tableId,
      'num_of_customers': numberOfCustomers,
      'emp_id': widget.empId,
      'company_id': widget.companyId,
      'branch_id': widget.branchId,
      'branch_prefix': widget.branchPrefix,
      'date': date,
      'date_docuno': '${year}${month}${day}',
      'print_qr_code': packageId != 1 ? printQrCode : false,
    });
    final response = await HttpRequests().httpRequest(url, body, context, true);
    if (response.data['status'] == 1) {
      createOrderSuccess(tableId, tableName, zoneName, tableTypeId);
      setState(() {
        loading = false;
        numberOfCustomers = "";
        printQrCode = true;
      });
      fetchZoneData();
      fetchTableData(true);
    } else {
      AlertDialogs().alertWarning(
          context, 'ไม่สามารถเปิดโต๊ะได้เนื่องจากยังไม่เปิด รอบการขาย(Shift)');
      setState(() {
        loading = false;
        numberOfCustomers = "";
      });
      fetchZoneData();
      fetchTableData(true);
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
  //       socket.on('table_data', (res) {
  //         if (res.isNotEmpty) {
  //           setState(() {
  //             loading = false;
  //             tableData = tableModelFromJson(jsonEncode(res));
  //           });
  //         }
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
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchTableData(false);
    });
    fetchPackegeId();
    //socketServer();
    checkShiftOpen();
    context.read<CounterProvider>().resetCountProduct();
    fetchZoneData();
    fetchTableData(true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return fetchTableData(true);
        },
        child: Container(
          height: double.infinity,
          color: Colors.grey[200],
          child: zoneData.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      zoneData.length,
                      (index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    zoneData[index].zoneName!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xff4fc3f7),
                                    ),
                                  ),
                                ),
                                listTable(
                                  zoneData[index].zoneId!,
                                  zoneData[index].zoneName!,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'ไม่พบข้อมูล โซนเเละโต๊ะ',
                    style: FontStyle().h2Style(0xff000000, 18),
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'รีเฟรชหน้า',
        child: const Icon(Icons.refresh),
        onPressed: () {
          context.read<CounterProvider>().resetCountProduct();
          fetchTableData(true);
        },
      ),
    );
  }

  Widget listTable(String zoneId, String zoneName) {
    List listTable = [];
    for (var item in tableData) {
      if (item.zoneId == zoneId) {
        listTable.add(item);
      }
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 20,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: List<Widget>.generate(listTable.length, (index) {
            if (listTable[index].zoneId == zoneId) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onLongPress: () {
                    if (listTable[index].statusId == 3 &&
                        double.parse(listTable[index].netAmnt) == 0) {
                      dialogCancelOrder(
                          listTable[index].tableId, listTable[index].tableName);
                    }
                  },
                  onTap: () {
                    if (listTable[index].statusId == 1) {
                      checkShiftOpen();
                      createOrderAlert(
                        'โต๊ะ ${listTable[index].tableName}',
                        zoneName,
                        listTable[index].tableId,
                        zoneId,
                        listTable[index].locationTypeId,
                      );
                    } else if (listTable[index].statusId == 3) {
                      // widget.buffetActive == true &&
                      //         widget.alacarteActive == true
                      packageId == 9 || packageId == 8
                          ? Navigator.of(context)
                              .push(
                              MaterialPageRoute(
                                builder: (context) => SelectTypeOrderMain(
                                  tableId: listTable[index].tableId,
                                  tableName:
                                      'โต๊ะ ${listTable[index].tableName}',
                                  zoneName: zoneName,
                                  branchId: widget.branchId,
                                  tableTypeId: listTable[index].locationTypeId,
                                  empId: widget.empId,
                                  menuActionActive: widget.menuActionActive,
                                  companyId: widget.companyId,
                                  buffetActive: widget.buffetActive,
                                  alacarteActive: widget.alacarteActive,
                                  userId: widget.userId,
                                  packageId: packageId,
                                ),
                              ),
                            )
                              .then((value) {
                              context
                                  .read<CounterProvider>()
                                  .resetCountProduct();
                              Provider.of<CounterProvider>(context,
                                      listen: false)
                                  .setValueProductDataInBusket([]);
                              //fetchZoneData();
                              fetchTableData(true);
                              fetchPackegeId();
                            })
                          : Navigator.of(context)
                              .push(
                              MaterialPageRoute(
                                builder: (context) => MainMenu(
                                  tableId: listTable[index].tableId,
                                  tableName:
                                      'โต๊ะ ${listTable[index].tableName}',
                                  zoneName: zoneName,
                                  branchId: widget.branchId,
                                  tableTypeId: listTable[index].locationTypeId,
                                  empId: widget.empId,
                                  menuActionActive: widget.menuActionActive,
                                  companyId: widget.companyId,
                                  buffetActive: widget.buffetActive,
                                  alacarteActive: widget.alacarteActive,
                                  userId: widget.userId,
                                  packageId: packageId,
                                ),
                              ),
                            )
                              .then((value) {
                              context
                                  .read<CounterProvider>()
                                  .resetCountProduct();
                              Provider.of<CounterProvider>(context,
                                      listen: false)
                                  .setValueProductDataInBusket([]);
                              //fetchZoneData();
                              fetchTableData(true);
                              fetchPackegeId();
                            });

                      // : Navigator.of(context)
                      //       .push(
                      //       MaterialPageRoute(
                      //         builder: (context) => MainMenuBuffet(
                      //           tableId: listTable[index].tableId,
                      //           tableName:
                      //               'โต๊ะ ${listTable[index].tableName}',
                      //           zoneName: zoneName,
                      //           branchId: widget.branchId,
                      //           tableTypeId:
                      //               listTable[index].locationTypeId,
                      //           empId: widget.empId,
                      //           menuActionActive: widget.menuActionActive,
                      //           alacarteActive: widget.alacarteActive,
                      //           companyId: widget.companyId,
                      //           buffetActive: widget.buffetActive,
                      //           userId: widget.userId,
                      //           packageId: packageId,
                      //         ),
                      //       ),
                      //     )
                      //       .then((value) {
                      //       context
                      //           .read<CounterProvider>()
                      //           .resetCountProduct();
                      //       Provider.of<CounterProvider>(context,
                      //               listen: false)
                      //           .setValueProductDataInBusket([]);
                      //       //fetchZoneData();
                      //       fetchTableData();
                      //       fetchPackegeId();
                      //     });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: listTable[index].statusId == 1
                          ? const Color(0xff27AE60)
                          : listTable[index].requestConfirm == false
                              ? const Color(0xffFF8800)
                              : const Color(0xffff616f),
                    ),
                    height: 100,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          Text(
                            'โต๊ะ ${listTable[index].tableName!}',
                            style: FontStyle().h2Style(0xffFFFFFF, 16),
                          ),
                          Text(
                            NumberFormat.currency(name: '').format(
                              int.parse(listTable[index].netAmnt!),
                            ),
                            style: FontStyle().h2Style(0xffFFFFFF, 16),
                          ),
                          Text('จำนวนที่นั่ง ${listTable[index].tableQty!}',
                              style: FontStyle().h2Style(0xffFFFFFF, 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return const Text('');
          }),
        ),
      ),
    );
  }

  dialogCancelOrder(
    String tableId,
    String tableName,
  ) {
    Alert(
      context: context,
      content: Text(
        'ยืนยันการปิดโต๊ะ ${tableName}',
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
          color: const Color(0xff4fc3f7),
          onPressed: () {
            Navigator.of(context).pop();
            cancelOrder(tableId);
          },
          width: 120,
          radius: const BorderRadius.all(
            Radius.circular(30),
          ),
          child: Text(
            "ยืนยัน",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
        )
      ],
    ).show();
  }

  BottomAppBar bottomAppBar() {
    return BottomAppBar(
      child: SizedBox(
        height: 60,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.green, width: 15),
                        ),
                      ),
                      child:
                          Text('โต๊ะว่าง', style: FontStyle().h2Style(0, 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.red, width: 15),
                        ),
                      ),
                      child: Text(
                        'โต๊ะไม่ว่าง',
                        style: FontStyle().h2Style(0, 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget qrCode() {
    return Column(
      children: [
        Text(
          'QR CODE ลูกค้า',
          style: FontStyle().h2Style(0xff000000, 16),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffbbdefb), width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Radio(
                      value: 1,
                      groupValue: selectedPrintQrCode,
                      onChanged: (int? values) {
                        setState(() {
                          selectedPrintQrCode = values!;
                          printQrCode = true;
                        });
                      },
                    ),
                    const Text(
                      'พิมพ์',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    )
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: 2,
                      groupValue: selectedPrintQrCode,
                      onChanged: (int? values) {
                        setState(() {
                          selectedPrintQrCode = values!;
                          printQrCode = false;
                        });
                      },
                    ),
                    const Text(
                      'ไม่พิมพ์',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    )
                  ],
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  createOrderAlert(
    String tableName,
    String zoneName,
    String tableId,
    String zoneId,
    String tableTypeId,
  ) {
    Alert(
      style: MyStyle().alertStyle,
      context: context,
      content: Column(
        children: [
          Text(
            tableName,
            style: FontStyle().h2Style(0xff000000, 16),
          ),
          Text(
            zoneName,
            style: FontStyle().h2Style(0xff000000, 16),
          ),
          TextFormField(
            maxLength: 2,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'กรอกจำนวนลูกค้า'),
            onChanged: (value) {
              if (value != "") {
                if (int.parse(value[0]) == 0) {
                  _controller.clear();
                  setState(() {
                    numberOfCustomers = "";
                  });
                  return;
                }
              }
              setState(() {
                numberOfCustomers = value;
              });
            },
          ),
          packageId != 1 ? qrCode() : Container(),
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
          radius: const BorderRadius.all(
            Radius.circular(20),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            if (statsuShiftOpen == true) {
              if (numberOfCustomers == '') {
                AlertDialogs().alertWarning(context, 'โปรดกรอกจำนวนลูกค้า');
                return;
              }
              Navigator.pop(context);
              createOrder(
                tableId,
                zoneId,
                tableName,
                zoneName,
                tableTypeId,
              );
            } else {
              AlertDialogs().alertWarning(context,
                  'ไม่สามารถเปิดโต๊ะได้เนื่องจากยังไม่เปิด รอบการขาย(Shift)');
              return;
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

  createOrderSuccess(
    String tableId,
    String tableName,
    String zoneName,
    String tableTypeId,
  ) {
    Alert(
      context: context,
      type: AlertType.success,
      content: Text(
        'เปิดโต๊ะสำเร็จ',
        style: FontStyle().h2Style(0xff000000, 16),
      ),
      buttons: [
        DialogButton(
          border: const Border.fromBorderSide(
            BorderSide(
              color: Color(0xff4fc3f7),
            ),
          ),
          color: const Color(0xff4fc3f7),
          onPressed: () {
            Navigator.of(context).pop();
            packageId == 9 || packageId == 8
                ? Navigator.of(context)
                    .push(
                    MaterialPageRoute(
                      builder: (context) => SelectTypeOrderMain(
                        tableId: tableId,
                        tableName: tableName,
                        zoneName: zoneName,
                        branchId: widget.branchId,
                        tableTypeId: tableTypeId,
                        empId: widget.empId,
                        menuActionActive: widget.menuActionActive,
                        companyId: widget.companyId,
                        buffetActive: widget.buffetActive,
                        alacarteActive: widget.alacarteActive,
                        userId: widget.userId,
                        packageId: packageId,
                      ),
                    ),
                  )
                    .then((value) {
                    Provider.of<CounterProvider>(context, listen: false)
                        .setValueProductDataInBusket([]);
                    fetchZoneData();
                    fetchTableData(true);
                    fetchPackegeId();
                  })
                : Navigator.of(context)
                    .push(
                    MaterialPageRoute(
                      builder: (context) => MainMenu(
                        tableId: tableId,
                        tableName: tableName,
                        zoneName: zoneName,
                        branchId: widget.branchId!,
                        tableTypeId: tableTypeId,
                        empId: widget.empId,
                        menuActionActive: widget.menuActionActive,
                        companyId: widget.companyId,
                        buffetActive: widget.buffetActive,
                        alacarteActive: widget.alacarteActive,
                        userId: widget.userId,
                        packageId: packageId,
                      ),
                    ),
                  )
                    .then((value) {
                    Provider.of<CounterProvider>(context, listen: false)
                        .setValueProductDataInBusket([]);
                    fetchZoneData();
                    fetchTableData(true);
                    fetchPackegeId();
                  });

            // : Navigator.of(context)
            //       .push(
            //       MaterialPageRoute(
            //         builder: (context) => MainMenuBuffet(
            //           tableId: tableId,
            //           tableName: tableName,
            //           zoneName: zoneName,
            //           branchId: widget.branchId,
            //           tableTypeId: tableTypeId,
            //           empId: widget.empId,
            //           menuActionActive: widget.menuActionActive,
            //           companyId: widget.companyId,
            //           buffetActive: widget.buffetActive,
            //           alacarteActive: widget.alacarteActive,
            //           userId: widget.userId,
            //           packageId: packageId,
            //         ),
            //       ),
            //     )
            //       .then((value) {
            //       context.read<CounterProvider>().resetCountProduct();
            //       Provider.of<CounterProvider>(context, listen: false)
            //           .setValueProductDataInBusket([]);
            //       //fetchZoneData();
            //       fetchTableData();
            //       fetchPackegeId();
            //     });
          },
          width: 120,
          radius: const BorderRadius.all(
            Radius.circular(30),
          ),
          child: Text(
            "ตกลง",
            style: FontStyle().h2Style(0xffFFFFFF, 16),
          ),
        )
      ],
    ).show();
  }
}
