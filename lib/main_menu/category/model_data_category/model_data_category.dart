import 'dart:convert';

List<CategoryDataModel> categoryModelFromJson(String str) {
  return List<CategoryDataModel>.from(
      jsonDecode(str).map((x) => CategoryDataModel.fromJson(x)));
}

class CategoryDataModel {
  String? categoryId;
  String? categoryName;
  String? productQty;
  String? imageGroupname;

  CategoryDataModel({
    this.categoryId,
    this.categoryName,
    this.productQty,
    this.imageGroupname,
  });
  CategoryDataModel.fromJson(Map<String, dynamic> json) {
    categoryId = json["master_product_group_id"];
    categoryName = json["master_product_group_name"];
    productQty = json["count_product"];
    imageGroupname = json["image_group_name"];
  }
}
