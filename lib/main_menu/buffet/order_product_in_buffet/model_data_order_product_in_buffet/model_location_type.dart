import 'dart:convert';

List<LocationtypeDataInBuffetModel> locationTypeInBuffetModelFromJson(
    String str) {
  return List<LocationtypeDataInBuffetModel>.from(
      jsonDecode(str).map((x) => LocationtypeDataInBuffetModel.fromJson(x)));
}

class LocationtypeDataInBuffetModel {
  String? locationTypeId;
  String? locationTypeName;

  LocationtypeDataInBuffetModel({
    this.locationTypeId,
    this.locationTypeName,
  });
  LocationtypeDataInBuffetModel.fromJson(Map<String, dynamic> json) {
    locationTypeId = json["master_order_location_type_id"];
    locationTypeName = json["master_order_location_type_name"];
  }
}
