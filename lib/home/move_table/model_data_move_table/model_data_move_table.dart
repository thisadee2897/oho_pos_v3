import 'dart:convert';

List<OrderDataInMoveTableModel> orderDataInMoveTableModelFromJson(String str) {
  return List<OrderDataInMoveTableModel>.from(
      jsonDecode(str).map((x) => OrderDataInMoveTableModel.fromJson(x)));
}

class OrderDataInMoveTableModel {
  String? orderhdId;
  String? orderDocuno;
  String? tableId;
  String? zoneName;
  String? tableName;
  String? firstName;
  String? lastName;

  OrderDataInMoveTableModel({
    this.orderhdId,
    this.orderDocuno,
    this.tableId,
    this.zoneName,
    this.tableName,
    this.firstName,
    this.lastName,
  });
  OrderDataInMoveTableModel.fromJson(Map<String, dynamic> json) {
    orderhdId = json["orderhd_id"];
    orderDocuno = json["orderhd_docuno"];
    tableId = json["master_order_table_id"];
    zoneName = json["master_order_zone_name"];
    tableName = json["master_table_name"];
    firstName = json["firstname"];
    lastName = json["lastname"];
  }
}
