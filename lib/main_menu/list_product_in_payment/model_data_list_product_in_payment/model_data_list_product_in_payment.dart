import 'dart:convert';

List<ListProductInPaymentDataModel> listProductInPaymentModelFromJson(
    String str) {
  return List<ListProductInPaymentDataModel>.from(
    jsonDecode(str).map(
      (x) => ListProductInPaymentDataModel.fromJson(x),
    ),
  );
}

class ListProductInPaymentDataModel {
  String? orderdtId;
  String? productId;
  String? orderdtQty;
  String? orderdtSalePrice;
  String? orderdtNetAmnt;
  String? productName;
  String? totalPriceTopping;
  List? topping;
  String? locationType;
  int? orderdtTypeId;
  int? locationTypeId;

  ListProductInPaymentDataModel({
    this.orderdtId,
    this.productId,
    this.orderdtQty,
    this.orderdtSalePrice,
    this.orderdtNetAmnt,
    this.productName,
    this.totalPriceTopping,
    this.topping,
    this.locationType,
    this.orderdtTypeId,
    this.locationTypeId,
  });
  ListProductInPaymentDataModel.fromJson(Map<String, dynamic> json) {
    orderdtId = json["orderdt_id"];
    productId = json["orderdt_master_product_id"];
    orderdtQty = json["orderdt_qty"];
    orderdtSalePrice = json["orderdt_saleprice"];
    orderdtNetAmnt = json["orderdt_netamnt"];
    productName = json["master_product_name"];
    totalPriceTopping = json["total_price_topping"];
    topping = json["topping"];
    locationType = json["master_order_location_type_name"];
    orderdtTypeId = int.parse(json["master_orderdt_type_id"]);
    locationTypeId = int.parse(json["master_order_location_type_id"]);
  }
}
