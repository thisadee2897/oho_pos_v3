import 'dart:convert';

List<LocationtypeDataModel> locationTypeModelFromJson(String str) {
  return List<LocationtypeDataModel>.from(
      jsonDecode(str).map((x) => LocationtypeDataModel.fromJson(x)));
}

class LocationtypeDataModel {
  String? locationTypeId;
  String? locationTypeName;

  LocationtypeDataModel({
    this.locationTypeId,
    this.locationTypeName,
  });
  LocationtypeDataModel.fromJson(Map<String, dynamic> json) {
    locationTypeId = json["master_order_location_type_id"];
    locationTypeName = json["master_order_location_type_name"];
  }
}
