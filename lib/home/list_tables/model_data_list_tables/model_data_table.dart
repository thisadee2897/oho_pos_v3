import 'dart:convert';

List<TableDataModel> tableModelFromJson(String str) {
  return List<TableDataModel>.from(
      jsonDecode(str).map((x) => TableDataModel.fromJson(x)));
}

class TableDataModel {
  String? tableId;
  String? tableName;
  String? tableQty;
  String? zoneId;
  int? statusId;
  String? empId;
  String? locationTypeId;
  String? netAmnt;
  bool? requestConfirm;

  TableDataModel({
    this.tableId,
    this.tableName,
    this.tableQty,
    this.zoneId,
    this.statusId,
    this.empId,
    this.locationTypeId,
    this.netAmnt,
    this.requestConfirm,
  });
  TableDataModel.fromJson(Map<String, dynamic> json) {
    tableId = json["master_order_table_id"];
    tableName = json["master_table_name"];
    tableQty = json["master_table_quantity"].toString();
    zoneId = json["master_order_zone_id"];
    statusId = json["master_table_status_id"];
    empId = json["emp_employeemasterid"].toString();
    locationTypeId = json["master_order_location_type_id"].toString();
    netAmnt = json["table_netamnt"];
    requestConfirm = json["orderhd_request_confirm"];
  }
}
