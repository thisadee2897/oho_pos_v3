import 'dart:convert';

List<LocationTypeInBusketDataModel> locationTypeInBusketModelFromJson(
    String str) {
  return List<LocationTypeInBusketDataModel>.from(
      jsonDecode(str).map((x) => LocationTypeInBusketDataModel.fromJson(x)));
}

class LocationTypeInBusketDataModel {
  String? locationTypeId;
  String? locationTypeName;

  LocationTypeInBusketDataModel({
    this.locationTypeId,
    this.locationTypeName,
  });
  LocationTypeInBusketDataModel.fromJson(Map<String, dynamic> json) {
    locationTypeId = json["master_order_location_type_id"];
    locationTypeName = json["master_order_location_type_name"];
  }
}
