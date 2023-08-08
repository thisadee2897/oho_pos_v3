import 'dart:convert';

List<AllProductInBuffetModel> productAllInbuffetModelFromJson(String str) {
  return List<AllProductInBuffetModel>.from(
      jsonDecode(str).map((x) => AllProductInBuffetModel.fromJson(x)));
}

class AllProductInBuffetModel {
  String? productId;
  String? productName;
  String? productPrice;
  String? buffethdId;
  int? limitOrderQty;
  int? balanchOrderdtQty;
  int? allBalanchOrderdtQty;
  bool? orderInfinity;
  int? buffetdtQty;
  String? imgName;
  bool? printBillFlag;
  String? remark;
  List? optionItem;
  int? countNumber;

  AllProductInBuffetModel(
    this.productId,
    this.productName,
    this.productPrice,
    this.buffethdId,
    this.limitOrderQty,
    this.balanchOrderdtQty,
    this.allBalanchOrderdtQty,
    this.orderInfinity,
    this.buffetdtQty,
    this.imgName,
    this.printBillFlag,
    this.remark,
    this.optionItem,
    this.countNumber,
  );
  AllProductInBuffetModel.fromJson(Map<String, dynamic> json) {
    productId = json["master_buffet_dt_product_id"];
    productName = json["master_buffet_dt_barcode_name"];
    productPrice = json["master_buffet_dt_unit_price"];
    buffethdId = json["master_buffet_hd_id"];
    limitOrderQty = int.parse(json["master_buffet_dt_order_qty"]);
    balanchOrderdtQty = int.parse(json["balanch_orderdt_qty"]);
    allBalanchOrderdtQty = int.parse(json["all_balanch_orderdt_qty"]);
    orderInfinity = json["order_infinity"];
    buffetdtQty = json["buffetdt_qty"];
    imgName = json["master_product_image_name"];
    printBillFlag = json["print_bill_flag"];
    remark = json["remark"];
    optionItem = json["option_item"];
    countNumber = int.parse(json["count_number"]);
  }
}
