import 'dart:convert';

List<ProductInBusketDataModel> productInBusketModelFromJson(String str) {
  return List<ProductInBusketDataModel>.from(
      jsonDecode(str).map((x) => ProductInBusketDataModel.fromJson(x)));
}

class ProductInBusketDataModel {
  int? orderdtId;
  int? productId;
  int? productGroupId;
  int? orderdtQty;
  double? orderdtSalePrice;
  double? orderdtNetAmnt;
  int? groupRemarkId;
  int? locationTypeId;
  bool? billFlag;
  String? orderdtRemark;
  String? groupRemarkName;
  String? locationTypeName;
  String? productName;
  String? totalPriceTopping;
  List? topping;
  List? remark;
  int? orderdtType;
  List? option;

  ProductInBusketDataModel({
    this.orderdtId,
    this.productId,
    this.productGroupId,
    this.orderdtQty,
    this.orderdtSalePrice,
    this.orderdtNetAmnt,
    this.groupRemarkId,
    this.locationTypeId,
    this.billFlag,
    this.orderdtRemark,
    this.groupRemarkName,
    this.locationTypeName,
    this.productName,
    this.totalPriceTopping,
    this.topping,
    this.remark,
    this.orderdtType,
    this.option,
  });
  ProductInBusketDataModel.fromJson(Map<String, dynamic> json) {
    orderdtId = json["orderdt_id"];
    productId = json["orderdt_master_product_id"];
    productGroupId = json["product_group_id"];
    orderdtQty = json["orderdt_qty"];
    orderdtSalePrice = double.parse(json["orderdt_saleprice"]);
    orderdtNetAmnt = double.parse(json["orderdt_netamnt"]);
    groupRemarkId = json["master_product_group_remark_id"];
    locationTypeId = json["master_order_location_type_id"];
    billFlag = json["print_bill_flag"];
    orderdtRemark = json["orderdt_remark"];
    groupRemarkName = json["master_product_group_remark_name"];
    locationTypeName = json["master_order_location_type_name"];
    productName = json["master_product_name"];
    totalPriceTopping = json["total_price_topping"];
    topping = json['topping'];
    remark = json['remark'];
    orderdtType = json['master_orderdt_type_id'];
    option = json['option'];
  }
}
