import 'dart:convert';

List<CompanyDataModel> companyModelFromJson(String str) {
  return List<CompanyDataModel>.from(
      jsonDecode(str).map((x) => CompanyDataModel.fromJson(x)));
}

class CompanyDataModel {
  int? companyId;
  String? companyName;

  CompanyDataModel({
    this.companyId,
    this.companyName,
  });
  CompanyDataModel.fromJson(Map<String, dynamic> json) {
    companyId = json["master_company_id"];
    companyName = json["master_company_name"];
  }
}
