import 'package:foap/model/club_model.dart';

class ClubInvitation {
  int? id;
  ClubModel? club;

  ClubInvitation();

  factory ClubInvitation.fromJson(dynamic json) {
    ClubInvitation model = ClubInvitation();
    model.id = json['id'];
    model.club = ClubModel.fromJson(json['club']);

    return model;
  }
}
