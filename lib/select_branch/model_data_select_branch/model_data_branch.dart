import 'dart:convert';

List<BranchDataModel> branchModelFromJson(String str) {
  return List<BranchDataModel>.from(
      jsonDecode(str).map((x) => BranchDataModel.fromJson(x)));
}

class BranchDataModel {
  String? branchName;
  String? branchId;
  String? branchPrefix;
  String? branchType;
  int? branchTypeId;
  String? roleGroupId;
  bool? buffetActive;
  bool? alacarteActive;

  BranchDataModel({
    this.branchName,
    this.branchId,
    this.branchPrefix,
    this.branchType,
    this.branchTypeId,
    this.roleGroupId,
    this.buffetActive,
    this.alacarteActive,
  });
  BranchDataModel.fromJson(Map<String, dynamic> json) {
    branchName = json["master_branch_name"];
    branchId = json["master_branch_id"];
    branchPrefix = json["master_branch_prefix"];
    branchType = json["master_branch_type_name"];
    branchTypeId = json["master_branch_type_id"];
    roleGroupId = json['role_group_id'];
    buffetActive = json['buffet_active'];
    alacarteActive = json['alacarte_active'];
  }
}
