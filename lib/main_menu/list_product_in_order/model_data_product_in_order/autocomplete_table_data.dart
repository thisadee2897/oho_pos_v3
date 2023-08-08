import 'dart:convert';

List<TableDataModel> tableDataModelFromJson(String str) {
  return List<TableDataModel>.from(
      jsonDecode(str).map((x) => TableDataModel.fromJson(x)));
}

class TableDataModel {
  String? tableName;
  String? tableId;
  String? orderId;

  TableDataModel(
    this.tableName,
    this.tableId,
    this.orderId,
  );
  TableDataModel.fromJson(Map<String, dynamic> json) {
    tableName = json['master_table_name'];
    tableId = json['master_order_table_id'];
    orderId = json['orderhd_id'];
  }
}
