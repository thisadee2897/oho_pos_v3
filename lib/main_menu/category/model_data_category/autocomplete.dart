import 'dart:convert';

List<AllProductsModel> productAllModelFromJson(String str) {
  return List<AllProductsModel>.from(
      jsonDecode(str).map((x) => AllProductsModel.fromJson(x)));
}

class AllProductsModel {
  String? productId;
  String? productName;
  String? productNameEng;
  String productPrice = '';
  String? productGroupId;
  String? imgName;

  AllProductsModel(
    this.productId,
    this.productName,
    this.productNameEng,
    this.productPrice,
    this.productGroupId,
    this.imgName,
  );
  AllProductsModel.fromJson(Map<String, dynamic> json) {
    productId = json['master_product_id'];
    productName = json['master_product_name'];
    productNameEng = json['master_product_name_eng'];
    productPrice = json['master_product_price1'];
    productGroupId = json['master_product_group_id'];
    imgName = json['master_product_image_name'];
  }
}
