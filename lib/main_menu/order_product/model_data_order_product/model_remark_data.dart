import 'dart:convert';

List<RemarkDataModel> remarkModelFromJson(String str) {
  return List<RemarkDataModel>.from(
      jsonDecode(str).map((x) => RemarkDataModel.fromJson(x)));
}

class RemarkDataModel {
  String? optionGroupId;
  String? optionGroupName;
  List? optionItem;

  RemarkDataModel({
    this.optionGroupId,
    this.optionGroupName,
    this.optionItem,
  });
  RemarkDataModel.fromJson(Map<String, dynamic> json) {
    optionGroupId = json["master_product_option_group_id"];
    optionGroupName = json["master_product_option_group_name"];
    optionItem = json["option_item"];
  }
}
