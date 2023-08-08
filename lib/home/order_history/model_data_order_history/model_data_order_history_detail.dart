import 'dart:convert';

List<OrderHistoryDetailModel> orderHistoryDetailModelFromJson(String str) {
  return List<OrderHistoryDetailModel>.from(
      jsonDecode(str).map((x) => OrderHistoryDetailModel.fromJson(x)));
}

class OrderHistoryDetailModel {
  String? orderdtId;
  String? productId;
  String? orderdtQty;
  String? orderdtSalePrice;
  String? orderdtNetAmnt;
  String? productName;
  String? firstName;
  String? lastName;
  String? remark;
  String? firstNameReceive;
  String? lastNameReceive;
  String? totalPriceTopping;
  List? topping;
  String? locationType;
  int? orderdtTypeId;
  int? locationTypeId;

  OrderHistoryDetailModel({
    this.orderdtId,
    this.productId,
    this.orderdtQty,
    this.orderdtSalePrice,
    this.orderdtNetAmnt,
    this.productName,
    this.firstName,
    this.lastName,
    this.remark,
    this.firstNameReceive,
    this.lastNameReceive,
    this.totalPriceTopping,
    this.topping,
    this.locationType,
    this.orderdtTypeId,
    this.locationTypeId,
  });
  OrderHistoryDetailModel.fromJson(Map<String, dynamic> json) {
    orderdtId = json["orderdt_id"];
    productId = json["orderdt_master_product_id"];
    orderdtQty = json["orderdt_qty"];
    orderdtSalePrice = json["orderdt_saleprice"];
    orderdtNetAmnt = json["orderdt_netamnt"];
    productName = json["master_product_name"];
    firstName = json["firstname"];
    lastName = json["lastname"];
    remark = json["orderhd_remark"];
    firstNameReceive = json["firstname_receive"];
    lastNameReceive = json["lastname_receive"];
    totalPriceTopping = json["total_price_topping"];
    topping = json["topping"];
    locationType = json["master_order_location_type_name"];
    orderdtTypeId = int.parse(json["master_orderdt_type_id"]);
    locationTypeId = int.parse(json["master_order_location_type_id"]);
  }
}
