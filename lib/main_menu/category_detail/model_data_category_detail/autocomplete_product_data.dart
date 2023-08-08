import 'dart:convert';

List<AutocompleteProductsModel> autocompleteProductModelFromJson(String str) {
  return List<AutocompleteProductsModel>.from(
      jsonDecode(str).map((x) => AutocompleteProductsModel.fromJson(x)));
}

class AutocompleteProductsModel {
  String? productId;
  String? productName;
  String? productNameEng;
  String productPrice = '';
  String? productGroupId;
  String? imgName;

  AutocompleteProductsModel(
    this.productId,
    this.productName,
    this.productNameEng,
    this.productPrice,
    this.productGroupId,
    this.imgName,
  );
  AutocompleteProductsModel.fromJson(Map<String, dynamic> json) {
    productId = json['master_product_id'];
    productName = json['master_product_name'];
    productNameEng = json['master_product_name_eng'];
    productPrice = json['master_product_price1'];
    productGroupId = json['master_product_group_id'];
    imgName = json["master_product_image_name"];
  }
}
