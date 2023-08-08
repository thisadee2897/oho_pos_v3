import 'dart:convert';

List<OptionDataModel> optionDataModelFromJson(String str) {
  return List<OptionDataModel>.from(
      jsonDecode(str).map((x) => OptionDataModel.fromJson(x)));
}

class OptionDataModel {
  String? optionGroupName;
  String? optionGroupId;
  List? option;

  OptionDataModel({
    this.optionGroupName,
    this.option,
    this.optionGroupId,
  });
  OptionDataModel.fromJson(Map<String, dynamic> json) {
    optionGroupName = json["master_product_option_group_name"];
    optionGroupId = json["master_product_option_group_id"];
    option = json["option_item"];
  }
}
