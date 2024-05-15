import 'package:foap/model/user_model.dart';

class ClubJoinRequest {
  int? id;
  UserModel? user;

  ClubJoinRequest();

  factory ClubJoinRequest.fromJson(dynamic json) {
    ClubJoinRequest model = ClubJoinRequest();
    model.id = json['id'];
    model.user = UserModel.fromJson(json['user']);

    return model;
  }
}
