import 'package:intl/intl.dart';

class SupportRequestModel {
  int id;
  int userId;
  String name;
  String email;
  String phone;
  String message;
  String? reply;
  int createdAt;
  int? updatedAt;

  SupportRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.reply,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportRequestModel.fromJson(Map<String, dynamic> json) =>
      SupportRequestModel(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        message: json["request_message"],
        reply: json["reply_message"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  String requestSentDate() {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(createdAt * 1000).toUtc();
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  String repliedDate() {
    DateTime dateTime =
    DateTime.fromMillisecondsSinceEpoch(updatedAt! * 1000).toUtc();
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
// factory SupportRequestModel.fromJson(dynamic json) {
//   SupportRequestModel model = SupportRequestModel();
//   model.amount = (json['amount'] ?? '').toString();
//   model.status = json['status'];
//
//   DateTime createDate =
//   DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000).toUtc();
//   String dateString = DateFormat('MMM dd, yyyy').format(createDate);
//   model.createDate = dateString;
//
//   return model;
// }
}
