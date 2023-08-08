import 'dart:convert';

List<RemarkInBusketDataModel> remarkInBusketModelFromJson(String str) {
  return List<RemarkInBusketDataModel>.from(
      jsonDecode(str).map((x) => RemarkInBusketDataModel.fromJson(x)));
}

class RemarkInBusketDataModel {
  String? remarkId;
  String? remarkName;

  RemarkInBusketDataModel({
    this.remarkId,
    this.remarkName,
  });
  RemarkInBusketDataModel.fromJson(Map<String, dynamic> json) {
    remarkId = json["master_product_group_remark_id"];
    remarkName = json["master_product_group_remark_name"];
  }
}
