// ignore_for_file: file_names

class SystemFlag {
  SystemFlag({
    this.id,
    required this.name,
    required this.value,
  });
  dynamic id;
  dynamic name;
  dynamic value;

  factory SystemFlag.fromJson(Map<String, dynamic> json) => SystemFlag(
        id: json["id"],
        name: json["name"] ?? "",
        value: (json["value"]) ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
      };
}
