// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, prefer_null_aware_operators

class ReportModel {
  dynamic screen = 'report_model.dart';
  ReportModel({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.contactNo,
    this.gender,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.occupation,
    this.maritalStatus,
    this.answerLanguage,
    this.partnerName,
    this.partnerBirthDate,
    this.partnerBirthTime,
    this.partnerBirthPlace,
    this.comments,
    this.reportFile,
    this.reportType,
    this.astrologerId,
    this.isActive,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
  });

  dynamic id;
  dynamic userId;
  dynamic firstName;
  dynamic lastName;
  dynamic contactNo;
  dynamic gender;
  DateTime? birthDate;
  dynamic birthTime;
  dynamic birthPlace;
  dynamic occupation;
  dynamic maritalStatus;
  dynamic answerLanguage;
  dynamic partnerName;
  DateTime? partnerBirthDate;
  dynamic partnerBirthTime;
  dynamic partnerBirthPlace;
  dynamic comments;
  dynamic reportFile;
  dynamic reportType;
  dynamic astrologerId;
  dynamic isActive;
  dynamic isDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic createdBy;
  dynamic modifiedBy;
  dynamic profile;
  dynamic reportImage;

  ReportModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"];
      userId = json["userId"];
      firstName = json["firstName"] ?? '';
      lastName = json["lastName"] ?? '';
      contactNo = json["contactNo"] ?? '';
      gender = json["gender"] ?? '';
      birthDate =
          DateTime.parse(json["birthDate"] ?? DateTime.now().toIso8601String());
      birthTime = json["birthTime"] ?? '';
      birthPlace = json["birthPlace"] ?? '';
      occupation = json["occupation"] ?? '';
      maritalStatus = json["maritalStatus"] ?? '';
      answerLanguage = json["answerLanguage"] ?? '';
      partnerName = json["partnerName"] ?? '';
      partnerBirthDate = json["partnerBirthDate"] != null
          ? DateTime.parse(json["partnerBirthDate"])
          : null;
      partnerBirthTime = json["partnerBirthTime"] ?? '';
      partnerBirthPlace = json["partnerBirthPlace"] ?? '';
      comments = json["comments"] ?? '';
      reportFile = json["reportFile"] ?? "";
      reportType = json["reportType"] ?? "";
      astrologerId = json["astrologerId"];
      isActive = json["isActive"];
      isDelete = json["isDelete"];
      createdAt = DateTime.tryParse("${json["created_at"]}");
      updatedAt = DateTime.tryParse("${json["updated_at"]}");
      createdBy = json["createdBy"];
      modifiedBy = json["modifiedBy"];
      profile = json["profile"] ?? "";
      reportImage = json["reportImage"] ?? "";
    } catch (e, s) {
      print(s);
      print('Exception: $screen - ReportModel.fromJson():-' + e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "contactNo": contactNo,
        "gender": gender,
        "birthDate": birthDate!.toIso8601String(),
        "birthTime": birthTime,
        "birthPlace": birthPlace,
        "occupation": occupation,
        "maritalStatus": maritalStatus,
        "answerLanguage": answerLanguage,
        "partnerName": partnerName,
        "partnerBirthDate": partnerBirthDate!.toIso8601String(),
        "partnerBirthTime": partnerBirthTime,
        "partnerBirthPlace": partnerBirthPlace,
        "comments": comments,
        "reportFile": reportFile ?? "",
        "reportType": reportType,
        "astrologerId": astrologerId,
        "isActive": isActive,
        "isDelete": isDelete,
        "created_at": createdAt != null ? createdAt!.toIso8601String() : null,
        "updated_at": updatedAt != null ? updatedAt!.toIso8601String() : null,
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "profile": profile,
        "reportImage": reportImage,
      };
}
