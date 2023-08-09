import 'dart:convert';

List<ListProductInOrderDataModel> listProductInOrderModelFromJson(String str) {
  return List<ListProductInOrderDataModel>.from(
      jsonDecode(str).map((x) => ListProductInOrderDataModel.fromJson(x)));
}

class ListProductInOrderDataModel {
  String? orderdtId;
  String? productId;
  String? orderdtQty;
  String? orderdtSalePrice;
  String? orderdtNetAmnt;
  String? orderdtStatusId;
  String? orderdtRemark;
  String? empId;
  String? firstName;
  String? nickName;
  String? productName;
  String? groupRemarkName;
  String? saveTime;
  String? totalPriceTopping;
  String? locationType;
  List topping = [];
  List buffet = [];
  String? orderdtTypeId;
  bool? checked;
  List option = [];

  ListProductInOrderDataModel({
    this.orderdtId,
    this.productId,
    this.orderdtQty,
    this.orderdtSalePrice,
    this.orderdtNetAmnt,
    this.orderdtStatusId,
    this.orderdtRemark,
    this.empId,
    this.firstName,
    this.nickName,
    this.productName,
    this.groupRemarkName,
    this.saveTime,
    this.totalPriceTopping,
    this.locationType,
    this.topping = const [],
    this.buffet = const [],
    this.orderdtTypeId,
    this.checked,
    this.option = const [],
  });
  ListProductInOrderDataModel.fromJson(Map<String, dynamic> json) {
    orderdtId = json["orderdt_id"];
    productId = json["orderdt_master_product_id"];
    orderdtQty = json["orderdt_qty"];
    orderdtSalePrice = json["orderdt_saleprice"];
    orderdtNetAmnt = json["orderdt_netamnt"];
    orderdtStatusId = json["orderdt_status_id"];
    orderdtRemark = json["orderdt_remark"];
    empId = json["employee_id"];
    firstName = json["firstname"];
    nickName = json["nickname"];
    productName = json["master_product_name"];
    groupRemarkName = json["remark_name"];
    saveTime = json["savetime"];
    totalPriceTopping = json["total_price_topping"];
    locationType = json["master_order_location_type_name"];
    if (json["topping"] != null) topping = json["topping"];
    if (json["buffet"] != null) buffet = json["buffet"];
    orderdtTypeId = json["master_orderdt_type_id"];
    checked = false;
    if (json["option"] != null) option = json["option"];
  }
}
