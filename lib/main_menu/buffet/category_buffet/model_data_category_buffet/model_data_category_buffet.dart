import 'dart:convert';

List<CategoryBuffetDataModel> categoryBuffetModelFromJson(String str) {
  return List<CategoryBuffetDataModel>.from(
      jsonDecode(str).map((x) => CategoryBuffetDataModel.fromJson(x)));
}

class CategoryBuffetDataModel {
  String? categoryId;
  String? categoryName;
  String? productQty;
  String? imageGroupname;

  CategoryBuffetDataModel({
    this.categoryId,
    this.categoryName,
    this.productQty,
    this.imageGroupname,
  });
  CategoryBuffetDataModel.fromJson(Map<String, dynamic> json) {
    categoryId = json["master_product_group_id"];
    categoryName = json["master_product_group_name"];
    productQty = json["count_product"];
    imageGroupname = json["image_group_name"];
  }
}
