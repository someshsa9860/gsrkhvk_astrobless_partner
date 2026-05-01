class ProductCategoryListModel {
  dynamic id;
  dynamic name;
  dynamic displayOrder;
  dynamic categoryImage;
  dynamic isActive;
  dynamic isDelete;

  ProductCategoryListModel({
    this.id,
    this.name,
    this.displayOrder,
    this.categoryImage,
    this.isActive,
    this.isDelete,
  });

  factory ProductCategoryListModel.fromJson(Map<String, dynamic> json) => ProductCategoryListModel(
        id: json["id"],
        name: json["name"],
        displayOrder: json["displayOrder"],
        categoryImage: json["categoryImage"],
        isActive: json["isActive"],
        isDelete: json["isDelete"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "displayOrder": displayOrder,
        "categoryImage": categoryImage,
        "isActive": isActive,
        "isDelete": isDelete,
      };
}
