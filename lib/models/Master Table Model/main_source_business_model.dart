class MainSourceBusinessModel {
  dynamic id;
  dynamic jobName;

  MainSourceBusinessModel({
    this.jobName,
    this.id,  
  });

  factory MainSourceBusinessModel.fromJson(Map<String, dynamic> json) => MainSourceBusinessModel(
        id: json["id"],
        jobName: json["jobName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "jobName": jobName,
      };
}
