import 'dart:convert';

List<NewTable> newTableModelFromJson(String str) {
  return List<NewTable>.from(jsonDecode(str).map((x) => NewTable.fromJson(x)));
}

class NewTable {
  String? tableName;
  String? tableId;

  NewTable(
    this.tableName,
    this.tableId,
  );
  NewTable.fromJson(Map<String, dynamic> json) {
    tableName = json['master_table_name'];
    tableId = json['master_order_table_id'];
  }
}
