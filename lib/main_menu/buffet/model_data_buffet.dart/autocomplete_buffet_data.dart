import 'dart:convert';

List<AutocompleteBuffetDataModel> autocompleteBuffetModelFromJson(String str) {
  return List<AutocompleteBuffetDataModel>.from(
      jsonDecode(str).map((x) => AutocompleteBuffetDataModel.fromJson(x)));
}

class AutocompleteBuffetDataModel {
  String? buffethdId;
  String? buffetName;
  String? productQty;
  String? buffetPrice;
  int? limitOrderQty;
  List? orderBuffet;
  int? balanchQty;
  int? orderQty;
  bool? buffethdOrderInfinity;
  String? productId;
  String? buffetImageName;

  AutocompleteBuffetDataModel({
    this.buffethdId,
    this.buffetName,
    this.productQty,
    this.buffetPrice,
    this.limitOrderQty,
    this.orderBuffet,
    this.balanchQty,
    this.orderQty,
    this.buffethdOrderInfinity,
    this.productId,
    this.buffetImageName,
  });
  AutocompleteBuffetDataModel.fromJson(Map<String, dynamic> json) {
    buffethdId = json["master_buffet_hd_id"];
    buffetName = json["master_buffet_hd_name"];
    productQty = json["count_product"];
    buffetPrice = json["master_product_price1"];
    limitOrderQty = int.parse(json["master_buffet_hd_limit_order_qty"]);
    orderBuffet = json["order_buffet"];
    balanchQty = int.parse(json["balanch_qty"]);
    orderQty = int.parse(json["buffethd_order_qty"]);
    buffethdOrderInfinity = json["buffethd_order_infinity"];
    productId = json["master_product_id"];
    buffetImageName = json["master_buffet_hd_image_name"];
  }
}
