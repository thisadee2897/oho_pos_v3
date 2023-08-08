import 'package:flutter/material.dart';
import 'package:oho_pos_v3/CounterProvider.dart';
import 'package:oho_pos_v3/fonts/fonts_style.dart';
import 'package:oho_pos_v3/main_menu/main_menu.dart';
import 'package:oho_pos_v3/main_menu/main_menu_buffet.dart';
import 'package:provider/src/provider.dart';

class SelectTypeOrder extends StatefulWidget {
  final String? tableId;
  final String? tableName;
  final String? zoneName;
  final String? branchId;
  final String? companyId;
  final String? tableTypeId;
  final String? empId;
  final bool? menuActionActive;
  final bool? buffetActive;
  final bool? alacarteActive;
  final String? orderhdId;
  final String? userId;
  final String? orderhdDocuno;
  final int? packageId;
  const SelectTypeOrder({
    Key? key,
    required this.tableId,
    required this.tableName,
    required this.zoneName,
    required this.branchId,
    required this.tableTypeId,
    required this.empId,
    required this.menuActionActive,
    required this.companyId,
    required this.buffetActive,
    required this.orderhdId,
    required this.orderhdDocuno,
    required this.userId,
    required this.alacarteActive,
    required this.packageId,
  }) : super(key: key);

  @override
  State<SelectTypeOrder> createState() => _SelectTypeOrderState();
}

class _SelectTypeOrderState extends State<SelectTypeOrder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MainMenuBuffet(
                                tableId: widget.tableId,
                                tableName: widget.tableName,
                                zoneName: widget.zoneName,
                                branchId: widget.branchId,
                                tableTypeId: widget.tableTypeId,
                                empId: widget.empId,
                                menuActionActive: widget.menuActionActive,
                                companyId: widget.companyId,
                                buffetActive: widget.buffetActive,
                                alacarteActive: widget.alacarteActive,
                                userId: widget.userId,
                                packageId: widget.packageId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SizedBox(
                            height: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => MainMenuBuffet(
                                          tableId: widget.tableId,
                                          tableName: widget.tableName,
                                          zoneName: widget.zoneName,
                                          branchId: widget.branchId,
                                          tableTypeId: widget.tableTypeId,
                                          empId: widget.empId,
                                          menuActionActive:
                                              widget.menuActionActive,
                                          companyId: widget.companyId,
                                          buffetActive: widget.buffetActive,
                                          alacarteActive: widget.alacarteActive,
                                          userId: widget.userId,
                                          packageId: widget.packageId,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: Image.asset(
                                    "assets/images/buffet.png",
                                    width: 50,
                                  ),
                                  title: const Text(
                                    'บุฟเฟต์',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  trailing: const Text(
                                    'เลือก',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MainMenu(
                              tableId: widget.tableId,
                              tableName: widget.tableName,
                              zoneName: widget.zoneName,
                              branchId: widget.branchId,
                              tableTypeId: widget.tableTypeId,
                              empId: widget.empId,
                              menuActionActive: widget.menuActionActive,
                              companyId: widget.companyId,
                              buffetActive: widget.buffetActive,
                              alacarteActive: widget.alacarteActive,
                              userId: widget.userId,
                              packageId: widget.packageId,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 120,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MainMenu(
                                        tableId: widget.tableId,
                                        tableName: widget.tableName,
                                        zoneName: widget.zoneName,
                                        branchId: widget.branchId,
                                        tableTypeId: widget.tableTypeId,
                                        empId: widget.empId,
                                        menuActionActive:
                                            widget.menuActionActive,
                                        companyId: widget.companyId,
                                        buffetActive: widget.buffetActive,
                                        alacarteActive: widget.alacarteActive,
                                        userId: widget.userId,
                                        packageId: widget.packageId,
                                      ),
                                    ),
                                  );
                                },
                                leading: Image.asset(
                                  "assets/images/a-la-carte.png",
                                  width: 50,
                                ),
                                title: const Text(
                                  'อลาคาส',
                                  style: TextStyle(fontSize: 18),
                                ),
                                trailing: const Text(
                                  'เลือก',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
