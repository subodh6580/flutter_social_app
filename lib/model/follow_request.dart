import 'package:foap/helper/imports/common_import.dart';

class FollowRequestModel {
  int id;

  UserModel sender;

  FollowRequestModel({
    required this.id,
    required this.sender,
    // required this.subCategories,
  });

  factory FollowRequestModel.fromJson(Map<String, dynamic> json) =>
      FollowRequestModel(
        id: json["id"],
        sender: UserModel.fromJson(json["followerUserDetail"]),
      );
}
