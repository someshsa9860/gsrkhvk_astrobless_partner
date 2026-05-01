import 'package:callvcal/utils/global.dart' as global;

class MessageModelLive {
  dynamic id;
  dynamic userId1;
  dynamic userId2;
  dynamic message;
  bool? isRead;
  bool? isActive;
  bool? isDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic orderId;
  MessageModelLive(
      {this.id,
      this.userId1,
      this.userId2,
      this.message,
      this.isActive,
      this.isRead,
      this.isDelete,
      this.createdAt,
      this.updatedAt,
      this.orderId});
  static MessageModelLive fromJson(Map<String, dynamic> json) =>
      MessageModelLive(
        userId1: json['userId1'],
        userId2: json['userId2'],
        message: json['message'],
        isActive: json['isActive'],
        orderId: json['orderId'],
        isDelete: json['isDelete'],
        isRead: json['isRead'],
        createdAt: json['createdAt'] != null
            ? global.DateFormatter.toDateTime(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? global.DateFormatter.toDateTime(json['updatedAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId1': userId1,
        'userId2': userId2,
        'message': message,
        'orderId': orderId,
        'isDelete': isDelete,
        'isRead': isRead,
        'updatedAt': updatedAt,
      };
}
