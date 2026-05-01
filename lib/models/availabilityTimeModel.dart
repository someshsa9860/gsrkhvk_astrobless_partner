// ignore_for_file: avoid_print, file_names, prefer_null_aware_operators
class AvailabilityTimeModel {
  dynamic id;
  dynamic astrologerId;
  dynamic status;
  DateTime? waitTime;

  AvailabilityTimeModel({this.id, this.astrologerId, this.status, this.waitTime});

  AvailabilityTimeModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"];
      astrologerId = json["astrologerId"];
      status = json["name"] ?? "";
      waitTime = DateTime.parse(json["waitTime"] ?? DateTime.now().toIso8601String());
    } catch (e,s) {
      print(s);
      print("Exception - AvailabilityTimeModel.dart - AvailabilityTimeModel.fromJson(): ${e.toString()}");
    }
  }

  Map<dynamic, dynamic> toJson() => {
        "id": id,
        "astrologerId": astrologerId,
        "status": status,
        "waitTime": waitTime != null ? waitTime!.toIso8601String() : null,
      };
}
