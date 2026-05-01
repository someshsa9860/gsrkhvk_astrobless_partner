// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

class WalletHistoryModel {
  WalletHistoryModel({
    this.id,
    this.amount,
    this.userId,
    this.transactionType,
    this.orderId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.isCredit,
    this.name,
    this.totalMin,
  });

  dynamic id;
  double? amount;
  dynamic userId;
  dynamic transactionType;
  dynamic orderId;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic createdBy;
  dynamic modifiedBy;
  dynamic isCredit;
  dynamic name;
  dynamic totalMin;
  dynamic productRefName;

  WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"];
      amount = json["amount"] != null ? double.parse(json["amount"].toString()) : 0;
      userId = json["userId"];
      transactionType = json["transactionType"];
      orderId = json["orderId"];
      createdAt = DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String());
      updatedAt = DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String());
      createdBy = json["createdBy"];
      modifiedBy = json["modifiedBy"];
      isCredit = json["isCredit"];
      name = json["name"];
      totalMin = json["totalMin"];
      productRefName = json["productRefName"];
    } catch (e,s) {
      print(s);
      print('Exception: wallet_history_model.dart - WalletHistoryModel.fromJson():-' + e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "userId": userId,
        "transactionType": transactionType,
        "orderId": orderId,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "isCredit": isCredit,
        "name": name,
        "totalMin": totalMin,
        "productRefName": productRefName,
      };
}
