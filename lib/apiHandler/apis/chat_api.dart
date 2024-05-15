import '../../model/api_meta_data.dart';
import '../../model/call_history_model.dart';
import '../../model/chat_message_model.dart';
import '../../model/chat_room_model.dart';
import '../../model/user_model.dart';
import '../api_wrapper.dart';

class ChatApi {
  static createChatRoom(int opponentId,
      {required Function(int) resultCallback}) async {
    var url = NetworkConstantsUtil.createChatRoom;
    dynamic param = {"receiver_id": opponentId.toString(), "type": '1'};

    ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['room_id']);
      }
    });
  }

  static createGroupChatRoom(
      {String? image,
      String? description,
      required bool isPublicGroup,
      required String title,
      required Function(int) resultCallback}) async {
    var url = NetworkConstantsUtil.createChatRoom;
    dynamic param = {
      "type": isPublicGroup ? '3' : '2',
      'receiver_id': '',
      'title': title,
      'image': image ?? '',
      'description': description ?? ''
    };

    ApiWrapper().postApi(url: url, param: param).then((result) {
      resultCallback(result!.data['room_id']);
    });
  }

  static Future updateGroupChatRoom(int groupId, String title, String? image,
      String? description, String? groupAccess) async {
    var url = NetworkConstantsUtil.updateGroupChatRoom + groupId.toString();

    Map<String, String> param = {};

    param['title'] = title;

    if (description != null) {
      param['description'] = description;
    }
    if (image != null) {
      param['image'] = image;
    }
    if (groupAccess != null) {
      param['chat_access_group'] = groupAccess;
    }

    await ApiWrapper().postApi(url: url, param: param).then((result) {});
  }

  static deleteChatRoom(int roomId) async {
    var url = NetworkConstantsUtil.deleteChatRoom + roomId.toString();

    ApiWrapper().getApi(url: url).then((result) {});
  }

  static deleteChatRoomMessages(int roomId) async {
    var url = NetworkConstantsUtil.deleteChatRoomMessages + roomId.toString();

    ApiWrapper().postApi(
        url: url, param: {'room_id': roomId.toString()}).then((result) {});
  }

  static getChatRooms(
      {required Function(List<ChatRoomModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getChatRooms;
    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var room = result!.data['room'] as List<dynamic>;
          room = room.toList();
          resultCallback(List<ChatRoomModel>.from(
              room.map((x) => ChatRoomModel.fromJson(x))));

      }
    });
  }

  static getPublicChatRooms(
      {required int page,
      required Function(List<ChatRoomModel>, APIMetaData)
          resultCallback}) async {
    var url = '${NetworkConstantsUtil.getPublicChatRooms}&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var room = result!.data['room']['items'] as List<dynamic>;
          room = room.toList();
          resultCallback(
              List<ChatRoomModel>.from(
                  room.map((x) => ChatRoomModel.fromJson(x))),
              APIMetaData.fromJson(result.data['room']['_meta']));

      }
    });
  }

  static getChatRoomDetail(int roomId,
      {required Function(ChatRoomModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getChatRoomDetail;
    url = url.replaceAll('{room_id}', roomId.toString());

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var room = result!.data['room'] as Map<String, dynamic>?;
        if (room != null) {
          resultCallback(ChatRoomModel.fromJson(room));
        }
      }
    });
  }

  static getChatHistory(
      {required int roomId,
      required int lastMessageId,
      required Function(List<ChatMessageModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.chatHistory;
    url = url
        .replaceAll('{{room_id}}', roomId.toString())
        .replaceAll('{{last_message_id}}', lastMessageId.toString());

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['chatMessage']['items'];
        resultCallback(List<ChatMessageModel>.from(
            items.map((x) => ChatMessageModel.fromJson(x))));
      }
    });
  }

  static getCallHistory(
      {required int page,
      required Function(List<CallHistoryModel>, APIMetaData)
          resultCallback}) async {
    var url = '${NetworkConstantsUtil.callHistory}&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var callHistory = result!.data['callHistory'];
        var items = callHistory['items'];

        resultCallback(
            List<CallHistoryModel>.from(
                items.map((x) => CallHistoryModel.fromJson(x))),
            APIMetaData.fromJson(result.data['callHistory']['_meta']));
      }
    });
  }

  static getRandomOnlineUsers(int? profileCategoryType,
      {required Function(List<UserModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.randomOnlineUser;
    if (profileCategoryType != null) {
      url = '$url${profileCategoryType.toString()}';
    }

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        List items = result!.data['user'];

        if (items.isEmpty) {
          getRandomOnlineUsers(profileCategoryType,
              resultCallback: resultCallback);
        } else {
          resultCallback(
              List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));
        }
      }
    });
  }
}
