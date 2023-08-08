import 'dart:convert';

List<RestoreOrderModel> restoreOrderModelFromJson(String str) {
  return List<RestoreOrderModel>.from(
      jsonDecode(str).map((x) => RestoreOrderModel.fromJson(x)));
}

class RestoreOrderModel {
  String? orderhdId;
  String? tableId;
  String? orderhdDocuno;
  String? tableName;
  String? orderhdNetamnt;
  int? customerQty;
  String? zoneName;

  RestoreOrderModel(
    this.orderhdId,
    this.tableId,
    this.orderhdDocuno,
    this.tableName,
    this.orderhdNetamnt,
    this.customerQty,
    this.zoneName,
  );
  RestoreOrderModel.fromJson(Map<String, dynamic> json) {
    orderhdId = json['orderhd_id'];
    tableId = json['master_order_table_id'];
    orderhdDocuno = json['orderhd_docuno'];
    tableName = json['master_table_name'];
    orderhdNetamnt = json['orderhd_netamnt'];
    customerQty = json['orderhd_customer_quantity'];
    zoneName = json['master_order_zone_name'];
  }
}
