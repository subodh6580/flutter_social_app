import 'dart:convert';
import 'package:foap/helper/imports/common_import.dart';
import 'chat_message_model.dart';

class ChatRoomMember {
  int id;

  int roomId;
  int userId;
  int isAdmin;
  UserModel userDetail;

  ChatRoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.isAdmin,
    required this.userDetail,
  });

  factory ChatRoomMember.fromJson(Map<String, dynamic> jsonData) =>
      ChatRoomMember(
          id: jsonData["id"],
          roomId: jsonData["room_id"],
          userId: jsonData["user_id"],
          isAdmin: jsonData["is_admin"],
          userDetail: UserModel.fromJson(jsonData['user'] is String
              ? json.decode(jsonData['user'])
              : jsonData['user']));

  Map<String, dynamic> toJson() => {
        "id": id,
        "room_id": roomId,
        "user_id": userId,
        "is_admin": isAdmin,
        "user": json.encode(userDetail.toJson()),
      };
}

class ChatRoomModel {
  int id = 0;
  int status = 0;
  int createdAt = 0;
  int? updatedAt;

  int createdBy = 0;
  String? name;

  // List<UserModel> users = [];
  ChatMessageModel? lastMessage;
  String? lastMessageId;

  // bool isTyping = false;
  List<String> whoIsTyping = [];
  bool isOnline = false;
  int unreadMessages = 0;
  bool isGroupChat;
  int type = 0;

  String? image;
  String? description;
  int groupAccess;
  List<ChatRoomMember> roomMembers;
  UserModel chatGroupOwner;

  ChatRoomModel({
    required this.id,
    this.lastMessageId,
    this.name,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    // required this.users,
    required this.isOnline,
    required this.isGroupChat,
    required this.type,
    required this.lastMessage,
    required this.groupAccess,
    this.image,
    this.description,
    required this.roomMembers,
    required this.chatGroupOwner,
  });

  factory ChatRoomModel.fromJson(dynamic jsonData) => ChatRoomModel(
      id: jsonData['id'],
      lastMessageId: jsonData['last_message_id'],
      name: jsonData['title'] ?? 'No Group name added',
      status: jsonData['status'],
      createdAt:
          jsonData['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: jsonData['updated_at'],
      createdBy: jsonData['created_by'],
      isOnline: jsonData['is_chat_user_online'] == 1,
      isGroupChat: jsonData['type'] != 1,
      type: jsonData['type'],
      image: jsonData['imageUrl'],
      description: jsonData['description'],
      groupAccess: jsonData['chat_access_group'] ?? 1,
      chatGroupOwner: UserModel.fromJson(jsonData['createdByUser'] is String
          ? json.decode(jsonData['createdByUser'])
          : jsonData['createdByUser']),
      roomMembers: jsonData['chatRoomUser'] != null
          ? jsonData['chatRoomUser'] is String
              ? (json.decode(jsonData['chatRoomUser']) as List<dynamic>)
                  .map((e) =>
                      ChatRoomMember.fromJson(e is String ? json.decode(e) : e))
                  .toList()
              : (jsonData['chatRoomUser'] as List<dynamic>)
                  .map((e) =>
                      ChatRoomMember.fromJson(e is String ? json.decode(e) : e))
                  .toList()
          : [],
      lastMessage: jsonData['lastMessage'] == null
          ? null
          : ChatMessageModel.fromJson(jsonData['lastMessage']));

  Map<String, dynamic> toJson() {
    // print(users.first.toJson());
    return {
      'id': id,
      'title': name,
      'status': status,
      'created_at': createdAt,
      'created_by': createdBy,
      'is_chat_user_online': isOnline,
      'type': type,
      'imageUrl': image,
      'description': description,
      'chat_access_group': groupAccess,
      'chatRoomUser':
          json.encode(roomMembers.map((e) => json.encode(e.toJson())).toList()),
      'createdByUser': json.encode(chatGroupOwner.toJson()),
      // 'unreadMessages': unreadMessages,
    };
  }

  ChatRoomMember get opponent {
    final UserProfileManager userProfileManager = Get.find();

    return roomMembers
        .where((element) =>
            element.userDetail.id != userProfileManager.user.value!.id)
        .first;
  }

  bool get amIGroupAdmin {
    return roomMembers
        .where((element) => element.isAdmin == 1 && element.userDetail.isMe)
        .toList()
        .isNotEmpty;
  }

  bool get amIMember {
    return roomMembers
        .where((element) => element.userDetail.isMe)
        .toList()
        .isNotEmpty;
  }

  bool get canIChat {
    if (isGroupChat == false) {
      return true;
    }
    if (groupAccess == 2) {
      return true;
    }
    return amIGroupAdmin;
  }

  ChatRoomMember memberById(int memberId) {
    return roomMembers
        .where((element) => element.userDetail.id == memberId)
        .first;
  }
}
