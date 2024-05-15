import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/user_model.dart';

class GiftModel {
  int id;
  String name;
  String logo;
  int coins;

  GiftModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.coins,
    // required this.subCategories,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) => GiftModel(
        id: json["id"],
        logo: json["imageUrl"],
        name: json["name"],
        coins: json["coin"],
      );
}

class ReceivedGiftModel {
  GiftModel giftDetail;
  UserModel sender;

  ReceivedGiftModel({
    required this.giftDetail,
    required this.sender,

    // required this.subCategories,
  });

  factory ReceivedGiftModel.fromJson(Map<String, dynamic> json) =>
      ReceivedGiftModel(
        giftDetail: GiftModel.fromJson(json["giftDetail"]),
        sender: UserModel.fromJson(json["senderDetail"]),
      );
}
