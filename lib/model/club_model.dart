import 'package:foap/helper/imports/common_import.dart';

enum AccessLevel { private, public, request }

class ClubModel {
  int? categoryId;
  int? id;
  int? userId;
  int? privacyType;
  bool? isRequestBased;

  String? name;
  String? desc;
  int? enableChat;
  int? chatRoomId;
  bool? isJoined;
  bool? isRequested;

  int? createdBy;
  int? totalMembers;

  String? image;
  String? imageName;

  UserModel? createdByUser;

  ClubModel({
    this.id,
    this.categoryId,
    this.userId,
    this.privacyType,
    this.isRequestBased,
    this.name,
    this.desc,
    this.enableChat,
    this.chatRoomId,
    this.isJoined,
    this.isRequested,
    this.image,
    this.imageName,
    this.createdBy,
    this.createdByUser,
    this.totalMembers,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
        id: json["id"],
        userId: json["user_id"],
        categoryId: json["category_id"],
        privacyType: json["privacy_type"],
        isRequestBased: json["is_request_based"] == 1,
        name: json["name"],
        chatRoomId: json["chat_room_id"],
        enableChat: json["is_chat_room"],
        image: json["imageUrl"],
        imageName: json["image"],
        desc: json["description"],
        isJoined: json["is_joined"] == 1,
        isRequested: json["is_join_requested"] == 1,
        createdBy: json["created_by"],
        totalMembers: json["totalJoinedUser"],
        createdByUser: json["createdByUser"] == null
            ? null
            : UserModel.fromJson(json["createdByUser"]),
      );

  bool get amIAdmin {
    return createdByUser!.isMe;
  }

  String get groupType {
    if (privacyType == 1) {
      if (isRequestBased == true) {
        return onRequestString.tr;
      }
      return publicString.tr;
    }
    return privateString.tr;
  }

  AccessLevel get accessLevel {
    if (privacyType == 1) {
      if (isRequestBased == true) {
        return AccessLevel.request;
      }
      return AccessLevel.public;
    }
    return AccessLevel.private;
  }
}
