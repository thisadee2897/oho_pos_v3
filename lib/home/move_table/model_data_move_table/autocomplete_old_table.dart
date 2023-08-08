import 'dart:convert';

List<OldTable> oldTableModelFromJson(String str) {
  return List<OldTable>.from(jsonDecode(str).map((x) => OldTable.fromJson(x)));
}

class OldTable {
  String? tableName;
  String? tableId;

  OldTable(
    this.tableName,
    this.tableId,
  );
  OldTable.fromJson(Map<String, dynamic> json) {
    tableName = json['master_table_name'];
    tableId = json['master_order_table_id'];
  }
}
