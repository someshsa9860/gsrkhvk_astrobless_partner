// To parse this JSON data, do
//
//     final videoModel = videoModelFromJson(jsonString);

import 'dart:convert';

VideoModel videoModelFromJson(dynamic str) =>
    VideoModel.fromJson(json.decode(str));

dynamic videoModelToJson(VideoModel data) => json.encode(data.toJson());

class VideoModel {
  dynamic message;
  List<RecordList>? recordList;
  dynamic status;

  VideoModel({
    this.message,
    this.recordList,
    this.status,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        message: json["message"],
        recordList: json["recordList"] == null
            ? []
            : List<RecordList>.from(
                json["recordList"]!.map((x) => RecordList.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "recordList": recordList == null
            ? []
            : List<dynamic>.from(recordList!.map((x) => x.toJson())),
        "status": status,
      };
}

class RecordList {
  dynamic astrologerId;
  dynamic media;
  dynamic mediaType;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic id;

  RecordList({
    this.astrologerId,
    this.media,
    this.mediaType,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        astrologerId: json["astrologerId"],
        media: json["media"],
        mediaType: json["mediaType"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "astrologerId": astrologerId,
        "media": media,
        "mediaType": mediaType,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "id": id,
      };
}
