import 'dart:convert';

List<ProductDataModel> productModelFromJson(String str) {
  return List<ProductDataModel>.from(
      jsonDecode(str).map((x) => ProductDataModel.fromJson(x)));
}

class ProductDataModel {
  String? productId;
  String? productName;
  String? productPrice;
  String? productGropId;
  String? imgName;

  ProductDataModel({
    this.productId,
    this.productName,
    this.productPrice,
    this.productGropId,
    this.imgName,
  });
  ProductDataModel.fromJson(Map<String, dynamic> json) {
    productId = json["master_product_id"];
    productName = json["master_product_name"];
    productPrice = json["master_product_price1"];
    productGropId = json["master_product_group_id"];
    imgName = json["master_product_image_name"];
  }
}
