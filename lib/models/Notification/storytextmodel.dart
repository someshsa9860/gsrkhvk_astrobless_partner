// To parse this JSON data, do
//
//     final storyTextModel = storyTextModelFromJson(jsonString);

import 'dart:convert';

StoryTextModel storyTextModelFromJson(dynamic str) =>
    StoryTextModel.fromJson(json.decode(str));

dynamic storyTextModelToJson(StoryTextModel data) => json.encode(data.toJson());

class StoryTextModel {
  dynamic message;
  List<RecordList>? recordList;
  dynamic status;

  StoryTextModel({
    this.message,
    this.recordList,
    this.status,
  });

  factory StoryTextModel.fromJson(Map<String, dynamic> json) => StoryTextModel(
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
