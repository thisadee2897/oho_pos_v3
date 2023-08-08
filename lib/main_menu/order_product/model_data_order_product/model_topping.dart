import 'dart:convert';

List<ToppingDataModel> toppingModelFromJson(String str) {
  return List<ToppingDataModel>.from(
      jsonDecode(str).map((x) => ToppingDataModel.fromJson(x)));
}

class ToppingDataModel {
  String? productId;
  String? productName;
  String? productPrice;

  ToppingDataModel({
    this.productId,
    this.productName,
    this.productPrice,
  });

  ToppingDataModel.fromJson(Map<String, dynamic> json) {
    productId = json["master_product_id"];
    productName = json["master_product_name"];
    productPrice = json["master_product_price1"];
  }
}
