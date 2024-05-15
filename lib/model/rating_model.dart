import 'package:foap/helper/date_extension.dart';
import 'package:foap/model/user_model.dart';

class RatingModel {
  int? id;
  int? bookingId;
  UserModel? user;
  double rating;
  String reviewMsg;
  int? createdAt;

  RatingModel({
    this.id,
    this.bookingId,
    this.user,
    required this.rating,
    required this.reviewMsg,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<dynamic, dynamic> json) => RatingModel(
        id: json["id"],
        user: UserModel.fromJson(json["user"]),
        rating: double.parse(json["rating"].toString()),
        reviewMsg: json["review"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": bookingId,
        "feedback": reviewMsg,
        "rating": rating,
      };

  String get timeAgoStr {
    var date = DateTime.fromMillisecondsSinceEpoch(createdAt! * 1000);
    return (date.getTimeAgo); // 15 minutes ago
  }
}
