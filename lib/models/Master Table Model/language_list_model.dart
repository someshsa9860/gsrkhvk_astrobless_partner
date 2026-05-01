// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

class LanguageModel {
  dynamic id;
  dynamic name;
  bool? isCheck = false;

  LanguageModel({
    this.name,
    this.id,
    this.isCheck = false,
  });

  LanguageModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"];
      name = json["languageName"] ?? "";
    } catch (e,s) {
      print(s);
      print('Exception: language_list_model.dart - LanguageModel.fromJson(): ' + e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "languageName": name ?? "",
      };
}
