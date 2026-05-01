// ignore_for_file: file_names

class HororscopeSignModel {
  HororscopeSignModel({this.id, required this.name, required this.image, this.isSelected = false});
  dynamic id;
  dynamic name;
  dynamic image;
  bool isSelected;

  factory HororscopeSignModel.fromJson(Map<String, dynamic> json) => HororscopeSignModel(
        id: json["id"],
        name: json["name"] ?? "",
        image: json["image"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
