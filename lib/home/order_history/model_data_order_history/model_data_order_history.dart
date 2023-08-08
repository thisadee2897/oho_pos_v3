import 'dart:convert';

List<OrderHistoryModel> orderHistoryModelFromJson(String str) {
  return List<OrderHistoryModel>.from(
      jsonDecode(str).map((x) => OrderHistoryModel.fromJson(x)));
}

class OrderHistoryModel {
  String? orderhdId;
  String? orderhdDocuno;
  String? tableName;
  String? orderhdNetamnt;
  int? customerQty;
  String? zoneName;

  OrderHistoryModel(
    this.orderhdId,
    this.orderhdDocuno,
    this.tableName,
    this.orderhdNetamnt,
    this.customerQty,
    this.zoneName,
  );
  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    orderhdId = json['orderhd_id'];
    orderhdDocuno = json['orderhd_docuno'];
    tableName = json['master_table_name'];
    orderhdNetamnt = json['orderhd_netamnt'];
    customerQty = json['orderhd_customer_quantity'];
    zoneName = json['master_order_zone_name'];
  }
}
