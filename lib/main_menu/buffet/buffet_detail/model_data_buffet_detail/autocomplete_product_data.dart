import 'dart:convert';

List<AutocompleteProductsInBuffetModel>
    autocompleteProductInBuffetModelFromJson(String str) {
  return List<AutocompleteProductsInBuffetModel>.from(jsonDecode(str)
      .map((x) => AutocompleteProductsInBuffetModel.fromJson(x)));
}

class AutocompleteProductsInBuffetModel {
  String? productId;
  String? productName;
  String? productNameEng;
  String? productPrice;
  String? buffethdId;
  int? limitOrderQty;
  int? balanchOrderdtQty;
  int? allBalanchOrderdtQty;
  bool? orderInfinity;

  AutocompleteProductsInBuffetModel(
    this.productId,
    this.productName,
    this.productNameEng,
    this.productPrice,
    this.buffethdId,
    this.limitOrderQty,
    this.balanchOrderdtQty,
    this.allBalanchOrderdtQty,
    this.orderInfinity,
  );
  AutocompleteProductsInBuffetModel.fromJson(Map<String, dynamic> json) {
    productId = json['master_buffet_dt_product_id'];
    productName = json['master_buffet_dt_barcode_name'];
    productNameEng = json['master_product_name_eng'];
    productPrice = json['master_buffet_dt_unit_price'];
    buffethdId = json['master_buffet_hd_id'];
    limitOrderQty = int.parse(json["master_buffet_dt_order_qty"]);
    balanchOrderdtQty = int.parse(json["balanch_orderdt_qty"]);
    allBalanchOrderdtQty = int.parse(json["all_balanch_orderdt_qty"]);
    orderInfinity = json["order_infinity"];
  }
}
