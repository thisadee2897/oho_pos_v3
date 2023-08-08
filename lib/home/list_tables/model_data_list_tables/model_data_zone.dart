import 'dart:convert';

List<ZoneDataModel> zoneModelFromJson(String str) {
  return List<ZoneDataModel>.from(
      jsonDecode(str).map((x) => ZoneDataModel.fromJson(x)));
}

class ZoneDataModel {
  String? zoneName;
  String? zoneId;

  ZoneDataModel({
    this.zoneName,
    this.zoneId,
  });
  ZoneDataModel.fromJson(Map<String, dynamic> json) {
    zoneName = json["master_order_zone_name"];
    zoneId = json["master_order_zone_id"];
  }
}
