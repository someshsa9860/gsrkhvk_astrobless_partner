// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

class TimeAvailabilityModel {
  dynamic fromTime;
  dynamic toTime;

  TimeAvailabilityModel({
    this.fromTime,
    this.toTime,
  });

  TimeAvailabilityModel.fromJson(Map<String, dynamic> json) {
    try {
      fromTime = json["fromTime"] ?? '';
      toTime = json["toTime"] ?? '';
    } catch (e,s) {
      print(s);
      print('Exception: time_availability_model.dart - TimeAvailabilityModel.fromJson(): ' + e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        "fromTime": fromTime ?? '',
        "toTime": toTime ?? '',
      };
}
