// ignore_for_file: prefer_null_aware_operators

class IntakeModel {
  IntakeModel({
    this.id,
    this.name,
    this.phoneNumber,
    this.countryCode,
    this.birthDate,
    this.birthTime,
    this.maritalStatus,
    this.occupation,
    this.topicOfConcern,
    this.partnerName,
    this.gender,
    this.partnerBirthDate,
    this.partnerBirthPlace,
    this.partnerBirthTime,
    this.birthPlace,
  });
  dynamic id;
  dynamic name;
  dynamic phoneNumber;
  dynamic countryCode;
  dynamic gender;
  DateTime? birthDate;
  dynamic birthPlace;
  dynamic birthTime;
  dynamic maritalStatus;
  dynamic occupation;
  dynamic topicOfConcern;
  dynamic partnerName;
  DateTime? partnerBirthDate;
  dynamic partnerBirthTime;
  dynamic partnerBirthPlace;

  factory IntakeModel.fromJson(Map<String, dynamic> json) => IntakeModel(
        id: json["id"],
        name: json["name"] ?? "",
        phoneNumber: json["phoneNumber"],
        countryCode: json["countryCode"] ?? "IN",
        birthDate: DateTime.parse(json["birthDate"] ?? DateTime.now().toIso8601String()),
        birthTime: json["birthTime"] ?? "",
        maritalStatus: json["maritalStatus"] ?? "",
        birthPlace: json["birthPlace"] ?? "",
        occupation: json["occupation"] ?? "",
        topicOfConcern: json["topicOfConcern"] ?? "",
        partnerName: json["partnerName"],
        gender: json["gender"] ?? "Male",
        partnerBirthDate: json["partnerBirthDate"] != null ? DateTime.parse(json["partnerBirthDate"]) : null,
        partnerBirthTime: json["partnerBirthTime"] ?? "",
        partnerBirthPlace: json["partnerBirthPlace"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phoneNumber": phoneNumber,
        "countryCode": countryCode,
        "birthDate": birthDate!.toIso8601String(),
        "birthTime": birthTime,
        "maritalStatus": maritalStatus,
        "birthPlace": birthPlace,
        "occupation": occupation,
        "topicOfConcern": topicOfConcern ?? "",
        "partnerName": partnerName ?? "",
        "gender": gender,
        "partnerBirthDate": partnerBirthDate != null ? partnerBirthDate!.toIso8601String() : null,
        "partnerBirthTime": partnerBirthTime ?? "",
        "partnerBirthPlace": partnerBirthPlace ?? "",
      };
}
