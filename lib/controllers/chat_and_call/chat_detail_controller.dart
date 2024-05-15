import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_contacts/contact.dart';
import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profanity_filter/profanity_filter.dart';
import '../../components/notification_banner.dart';
import '../../helper/enum_linking.dart';
import '../../helper/permission_utils.dart';
import '../../manager/socket_manager.dart';
import '../../model/call_model.dart';
import '../../model/gallery_media.dart';
import '../../model/location.dart';
import '../../model/post_model.dart';
import '../../model/story_model.dart';
import '../../util/constant_util.dart';
import '../../util/shared_prefs.dart';
import 'agora_call_controller.dart';

class ChatDetailController extends GetxController {
  final AgoraCallController agoraCallController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  Rx<TextEditingController> messageTf = TextEditingController().obs;

  bool expandActions = false;

  // RxMap<String, dynamic> isOnlineMapping = <String, dynamic>{}.obs;
  RxMap<String, dynamic> isTypingMapping = <String, dynamic>{}.obs;

  // RxBool isOnline = false.obs;
  // RxBool isTyping = false.obs;
  RxString wallpaper = "assets/chatbg/chatbg3.jpg".obs;

  Rx<ChatMessageActionMode> actionMode = ChatMessageActionMode.none.obs;
  RxList<ChatMessageModel> selectedMessages = <ChatMessageModel>[].obs;
  RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;

  RxList<String> smartReplySuggestions = <String>[].obs;
  Rx<ChatMessageModel?> selectedMessage = Rx<ChatMessageModel?>(null);

  Rx<ChatRoomModel?> chatRoom = Rx<ChatRoomModel?>(null);
  Rx<UserModel?> opponent = Rx<UserModel?>(null);

  DateTime? typingStatusUpdatedAt;

  RxSet<String> whoIsTyping = RxSet<String>();
  final smartReply = SmartReply();

  int chatHistoryPage = 1;
  bool canLoadMoreMessages = true;
  bool isLoading = false;

  List<ChatMessageModel> get mediaMessages {
    return messages
        .where((element) =>
            element.messageContentType == MessageContentType.photo ||
            element.messageContentType == MessageContentType.video)
        .toList();
  }

  clear() {
    expandActions = false;
    selectedMessages.clear();
    messages.clear();
    chatRoom.value = null;
    // opponents.value = [];
    actionMode.value = ChatMessageActionMode.none;
    selectedMessage.value = null;
    typingStatusUpdatedAt = null;

    isLoading = false;
    chatHistoryPage = 1;
    canLoadMoreMessages = true;
  }

  //create chat room directory
  Future<String> messageMediaDirectory(String localMessageId) async {
    final appDir = await getApplicationDocumentsDirectory();

    final Directory chatRoomDirectory =
        Directory('${appDir.path}/${chatRoom.value!.id}/$localMessageId');

    if (await chatRoomDirectory.exists()) {
      //if folder already exists return path
      return chatRoomDirectory.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory newFolder =
          await chatRoomDirectory.create(recursive: true);
      return newFolder.path;
    }
  }

  deleteChat(int roomId) {
    messages.clear();
    ChatApi.deleteChatRoomMessages(roomId);
    update();
  }

  getUpdatedChatRoomDetail(
      {required ChatRoomModel room, required VoidCallback callback}) {
    ChatApi.getChatRoomDetail(room.id, resultCallback: (result) async {
      chatRoom.value = result;
      chatRoom.refresh();

      // update room in local storage
      await getIt<DBManager>().updateRoom(chatRoom.value!);
      callback();
    });
  }

  getChatRoomWithUser(
      {required int userId, required Function(ChatRoomModel) callback}) {
    createChatRoom(userId, (roomId) async {
      ChatApi.getChatRoomDetail(roomId, resultCallback: (result) async {
        await getIt<DBManager>().saveRooms([result]);
        callback(result);
      });
    });
  }

  Future<UserModel?> getOpponentUser({required int userId}) async {
    UserModel? user;
    await UsersApi.getOtherUser(
        userId: userId,
        resultCallback: (result) {
          user = result;
        });

    return user;
  }

  loadChat(ChatRoomModel chatRoom, VoidCallback completion) async {
    if (this.chatRoom.value == null) {
      this.chatRoom.value = chatRoom;
      this.chatRoom.refresh();
    }

    List<ChatMessageModel> msgList = await getIt<DBManager>().getAllMessages(
        roomId: chatRoom.id, limit: 20, offset: messages.length);
    messages.insertAll(0, msgList);

    if (chatRoom.isGroupChat == false) {
      opponent.value =
          await getOpponentUser(userId: chatRoom.opponent.userDetail.id);
    }

    if (msgList.length == 20) {
      completion();
    } else {
      //check for more message from server
      getChatHistoryInRoom(
        roomId: chatRoom.id,
        chatRoom: chatRoom,
        lastFetchedMessageId: messages.isNotEmpty ? messages.first.id : 0,
        completion: completion,
      );
    }

    update();
  }

  getChatHistoryInRoom(
      {required int roomId,
      required ChatRoomModel chatRoom,
      required int lastFetchedMessageId,
      required VoidCallback completion}) {
    if (canLoadMoreMessages && isLoading == false) {
      isLoading = true;

      ChatApi.getChatHistory(
          roomId: roomId,
          lastMessageId: lastFetchedMessageId,
          resultCallback: (result) async {
            if (result.isNotEmpty) {
              await getIt<DBManager>().saveMessage(chatMessages: result);

              if (chatRoom.id == this.chatRoom.value?.id) {
                loadChat(chatRoom, () {});
              }
            }
            isLoading = false;
          });
    } else {
      completion();
    }
  }

  getRoomDetail(int roomId, Function(ChatRoomModel) callback) async {
    ChatRoomModel? chatRoom = await getIt<DBManager>().getRoomById(roomId);

    if (chatRoom == null) {
      await ChatApi.getChatRoomDetail(roomId, resultCallback: (result) {
        callback(result);
      });
    } else {
      callback(chatRoom);
    }
  }

  loadWallpaper(int roomId) async {
    wallpaper.value = await SharedPrefs().getWallpaper(roomId: roomId);
  }

  createChatRoom(int userId, Function(int) callback) {
    ChatApi.createChatRoom(userId, resultCallback: (roomId) {
      getIt<SocketManager>().emit(SocketConstants.addUserInChatRoom, {
        'userId': '${_userProfileManager.user.value!.id},$userId'.toString(),
        'room': roomId
      });

      callback(roomId);
    });
  }

  isSelected(ChatMessageModel message) {
    return selectedMessages.contains(message);
  }

  starMessage(ChatMessageModel message) {
    message.isStar = 1;
    selectedMessages.refresh();
    getIt<DBManager>().starUnStarMessage(
        roomId: message.roomId,
        localMessageId: message.localMessageId,
        isStar: 1);
    update();
  }

  unStarMessage(ChatMessageModel message) {
    message.isStar = 0;
    selectedMessages.refresh();
    getIt<DBManager>().starUnStarMessage(
        roomId: message.roomId,
        localMessageId: message.localMessageId,
        isStar: 0);
    update();
  }

  selectMessage(ChatMessageModel message) {
    if (isSelected(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }
    update();
  }

  setToActionMode({required ChatMessageActionMode mode}) {
    actionMode.value = mode;
    if (mode == ChatMessageActionMode.none) {
      selectedMessages.clear();
    }
    update();
  }

  setReplyMessage({required ChatMessageModel? message}) {
    if (message == null) {
      setToActionMode(mode: ChatMessageActionMode.none);
    } else {
      // if (message.messageContentType != MessageContentType.reply) {
      selectedMessage.value = message;
      // } else {
      //   selectedMessage.value = message.reply;
      // }
      setToActionMode(mode: ChatMessageActionMode.reply);
    }
    update();
  }

// updateOnlineStatus() {
//   isOnline.value = !isOnline.value;
//   update();
// }

  expandCollapseActions() {
    expandActions = !expandActions;
    update();
  }

  messageChanges() {
    getIt<SocketManager>()
        .emit(SocketConstants.typing, {'room': chatRoom.value!.id});
    messageTf.refresh();
    // update();
  }

  sendMessageAsRead(ChatMessageModel message) {
    messages.value = messages.map((element) {
      if (element.id == message.id) {
        element.status = 3;
      }
      return element;
    }).toList();

    getIt<SocketManager>().emit(SocketConstants.readMessage,
        {'id': message.id, 'room': message.roomId});
    // messages.refresh();
    // update();
    getIt<DBManager>().updateMessageStatus(
        roomId: message.roomId,
        localMessageId: message.localMessageId,
        id: message.id,
        status: 3);
  }

  /// Todo : instead of opponent send chatroom id
  Future<bool> sendPostAsMessage(
      {required PostModel post, required ChatRoomModel room}) async {
    bool status = true;
    // await getChatRoomWithUser(toOpponent.id, (room) {
    String localMessageId = randomId();

    var content = {
      'messageType': messageTypeId(MessageContentType.post),
      'postId': post.id,
      'postThumbnail': post.gallery.first.thumbnail
    };

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'localMessageId': localMessageId,
      'is_encrypted': AppConfigConstants.enableEncryption,
      'messageType': messageTypeId(MessageContentType.post),
      'message': json.encode(content).encrypted(),
      'chat_version': AppConfigConstants.chatVersion,
      'replied_on_message': null,
      'room': room.id,
      'created_by': _userProfileManager.user.value!.id,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    ChatMessageModel currentMessageModel = ChatMessageModel();
    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.sender = _userProfileManager.user.value!;
    currentMessageModel.roomId = room.id;
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;

    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(MessageContentType.post);
    // currentMessageModel.messageContent = json.encode(content).replaceAll('\\', '');
    currentMessageModel.messageContent = json.encode(content).encrypted();

    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    addNewMessage(message: currentMessageModel, roomId: room.id);
    // save message to database
    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);
    // send message to socket server

    status = getIt<SocketManager>().emit(SocketConstants.sendMessage, message);
    update();
    // });
    setReplyMessage(message: null);
    return status;
  }

  Future<bool> sendTextMessage(
      {required String messageText,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;

    final filter = ProfanityFilter();
    bool hasProfanity = filter.hasProfanity(messageText);
    if (hasProfanity) {
      AppUtil.showToast(message: notAllowedMessageString.tr, isSuccess: true);
      return false;
    }

    String encryptedTextMessage = messageText.encrypted();
    var content = {
      'messageType': messageTypeId(MessageContentType.text),
      'text': encryptedTextMessage,
    };

    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();

    if (encryptedTextMessage.removeAllWhitespace.trim().isNotEmpty) {
      String localMessageId = randomId();
      var message = {
        'userId': _userProfileManager.user.value!.id,
        'localMessageId': localMessageId,
        'is_encrypted': AppConfigConstants.enableEncryption,
        'messageType': messageTypeId(mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.text),
        'message': json.encode(content).encrypted(),
        'replied_on_message': repliedOnMessage,
        'chat_version': AppConfigConstants.chatVersion,
        'room': room.id,
        'created_by': _userProfileManager.user.value!.id,
        'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
      };

      //save message to socket server
      status =
          getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

      ChatMessageModel currentMessageModel = ChatMessageModel();
      currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
      currentMessageModel.chatVersion = AppConfigConstants.chatVersion;

      currentMessageModel.localMessageId = localMessageId;
      currentMessageModel.sender = _userProfileManager.user.value!;

      currentMessageModel.roomId = room.id;

      currentMessageModel.userName = youString.tr;
      currentMessageModel.senderId = _userProfileManager.user.value!.id;
      currentMessageModel.messageType = messageTypeId(
          mode == ChatMessageActionMode.reply
              ? MessageContentType.reply
              : MessageContentType.text);
      currentMessageModel.messageContent = json.encode(content).encrypted();
      currentMessageModel.repliedOnMessageContent = repliedOnMessage;

      currentMessageModel.createdAt =
          (DateTime.now().millisecondsSinceEpoch / 1000).round();

      addNewMessage(message: currentMessageModel, roomId: room.id);
      // save message to database
      getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);

      setReplyMessage(message: null);
      messageTf.value.text = '';
      messageTf.refresh();
      update();
    }

    return status;
  }

  Future<bool> sendContactMessage(
      {required Contact contact,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;

    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();
    String localMessageId = randomId();

    var content = {
      'messageType': messageTypeId(MessageContentType.contact),
      'contactCard': contact.toVCard(),
    };

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'localMessageId': localMessageId,
      'is_encrypted': AppConfigConstants.enableEncryption,
      'messageType': messageTypeId(mode == ChatMessageActionMode.reply
          ? MessageContentType.reply
          : MessageContentType.contact),
      'message': json.encode(content).encrypted(),
      'chat_version': AppConfigConstants.chatVersion,
      'replied_on_message': repliedOnMessage,
      'room': room.id,
      'created_by': _userProfileManager.user.value!.id,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    status = getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

    ChatMessageModel currentMessageModel = ChatMessageModel();
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.sender = _userProfileManager.user.value!;

    currentMessageModel.roomId = room.id;
    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.contact);
    currentMessageModel.messageContent = json.encode(content).encrypted();
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    addNewMessage(message: currentMessageModel, roomId: room.id);
    // save message to database
    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);

    setReplyMessage(message: null);
    update();
    return status;
  }

  Future<bool> sendUserProfileAsMessage(
      {required UserModel user,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;
    String localMessageId = randomId();
    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();

    var content = {
      'messageType': messageTypeId(MessageContentType.profile),
      'userId': user.id,
      'userPicture': user.picture,
      'userName': user.userName,
      'location':
          user.city != null ? '${user.city ?? ''}, ${user.country ?? ''}' : '',
    };

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'localMessageId': localMessageId,
      'is_encrypted': AppConfigConstants.enableEncryption,
      'messageType': messageTypeId(mode == ChatMessageActionMode.reply
          ? MessageContentType.reply
          : MessageContentType.profile),
      'message': json.encode(content).encrypted(),
      'chat_version': AppConfigConstants.chatVersion,
      'replied_on_message': repliedOnMessage,
      'room': room.id,
      'created_by': _userProfileManager.user.value!.id,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    ChatMessageModel currentMessageModel = ChatMessageModel();
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.sender = _userProfileManager.user.value!;

    currentMessageModel.roomId = room.id;
    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.profile);
    // currentMessageModel.messageContent = json.encode(content).replaceAll('\\', '');
    currentMessageModel.messageContent = json.encode(content).encrypted();
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    addNewMessage(message: currentMessageModel, roomId: room.id);
    // save message to database
    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);
    // send message to socket server

    status = getIt<SocketManager>().emit(SocketConstants.sendMessage, message);
    setReplyMessage(message: null);

    update();
    return status;
  }

  Future<bool> sendLocationMessage(
      {required LocationModel location,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;

    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();
    String localMessageId = randomId();

    var locationData = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'name': location.name,
    };

    var content = {
      'location': locationData,
      'messageType': messageTypeId(MessageContentType.location),
    };

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'localMessageId': localMessageId,
      'is_encrypted': AppConfigConstants.enableEncryption,
      'chat_version': AppConfigConstants.chatVersion,
      'messageType': messageTypeId(mode == ChatMessageActionMode.reply
          ? MessageContentType.reply
          : MessageContentType.location),
      'message': json.encode(content).encrypted(),
      'replied_on_message': repliedOnMessage,
      'room': room.id,
      'created_by': _userProfileManager.user.value!.id,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    status = getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

    ChatMessageModel currentMessageModel = ChatMessageModel();
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.sender = _userProfileManager.user.value!;

    currentMessageModel.roomId = room.id;
    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.location);
    currentMessageModel.messageContent = json.encode(content).encrypted();
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    addNewMessage(message: currentMessageModel, roomId: room.id);
    // save message to database

    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);

    setReplyMessage(message: null);
    update();
    return status;
  }

  Future<bool> forwardMessage(
      {required ChatMessageModel msg, required ChatRoomModel room}) async {
    bool status = true;

    String localMessageId = randomId();
    var originalContent = {
      'originalMessage': msg.toJson(),
      'messageType': msg.messageType,
    };

    ChatMessageModel currentMessageModel = ChatMessageModel();
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;

    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.sender = _userProfileManager.user.value!;

    currentMessageModel.roomId = room.id;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(MessageContentType.forward);
    currentMessageModel.messageContent =
        json.encode(originalContent).encrypted();
    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'localMessageId': localMessageId,
      'is_encrypted': AppConfigConstants.enableEncryption,
      'chat_version': AppConfigConstants.chatVersion,
      'messageType': messageTypeId(MessageContentType.forward),
      'message': json.encode(originalContent).encrypted(),
      'room': room.id,
      'created_by': _userProfileManager.user.value!.id,
      'created_at': currentMessageModel.createdAt,
    };

    status = getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);
    // setReplyMessage(message: null);
    return status;
  }

  Future<bool> sendImageMessage(
      {required Media media,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;

    String localMessageId = randomId();
    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();

    var content = {
      'messageType': messageTypeId(MessageContentType.photo),
      // 'image': uploadedMedia.thumbnail!,
    };
    // store image in local storage
    File mainFile = await FileManager.saveChatMediaToDirectory(
        media, localMessageId, false, chatRoom.value!.id);

    ChatMessageModel currentMessageModel = ChatMessageModel();

    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.sender = _userProfileManager.user.value!;
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.roomId = room.id;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;

    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.photo);
    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    currentMessageModel.messageContent = json.encode(content).encrypted();
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    addNewMessage(message: currentMessageModel, roomId: room.id);
    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);

    update();

    // upload photo and send message

    uploadMedia(
        messageId: localMessageId,
        media: media,
        mainFile: mainFile,
        callback: (uploadedMedia) {
          var content = {
            'messageType': messageTypeId(MessageContentType.photo),
            'image': uploadedMedia.thumbnail!,
          };

          var message = {
            'userId': _userProfileManager.user.value!.id,
            'localMessageId': localMessageId,
            'is_encrypted': AppConfigConstants.enableEncryption,
            'chat_version': AppConfigConstants.chatVersion,
            'messageType': messageTypeId(mode == ChatMessageActionMode.reply
                ? MessageContentType.reply
                : MessageContentType.photo),
            'message': json.encode(content).encrypted(),
            'replied_on_message': repliedOnMessage,
            'room': room.id,
            'created_by': _userProfileManager.user.value!.id,
            'created_at': currentMessageModel.createdAt,
          };

          // send message to socket
          status =
              getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

          // update in cache message

          currentMessageModel.messageContent = json.encode(content).encrypted();
          // update message in local database
          getIt<DBManager>().updateMessageContent(
              roomId: room.id,
              localMessageId: currentMessageModel.localMessageId.toString(),
              content: json.encode(content).encrypted());
        });

    setReplyMessage(message: null);
    return status;
  }

  Future<bool> sendVideoMessage(
      {required Media media,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;

    String localMessageId = randomId();
    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();

    // store video in local storage
    File mainFile = await FileManager.saveChatMediaToDirectory(
        media, localMessageId, false, chatRoom.value!.id);

    // store image in local storage
    File videoThumbnail = await FileManager.saveChatMediaToDirectory(
        media, localMessageId, true, chatRoom.value!.id);

    ChatMessageModel currentMessageModel = ChatMessageModel();

    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.roomId = room.id;
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    currentMessageModel.sender = _userProfileManager.user.value!;

    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.video);
    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    currentMessageModel.messageContent = ''.encrypted();
    // currentMessageModel.media = media;
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    addNewMessage(message: currentMessageModel, roomId: room.id);

    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);

    update();

    // upload video and send message

    uploadMedia(
        messageId: localMessageId,
        media: media,
        mainFile: mainFile,
        thumbnailFile: videoThumbnail,
        callback: (uploadedMedia) {
          var content = {
            'messageType': messageTypeId(MessageContentType.video),
            'image': uploadedMedia.thumbnail,
            'video': uploadedMedia.video!,
          };

          var message = {
            'userId': _userProfileManager.user.value!.id,
            'localMessageId': localMessageId,
            'is_encrypted': AppConfigConstants.enableEncryption,
            'chat_version': AppConfigConstants.chatVersion,
            'messageType': messageTypeId(mode == ChatMessageActionMode.reply
                ? MessageContentType.reply
                : MessageContentType.video),
            'message': json.encode(content).encrypted(),
            'room': room.id,
            'created_by': _userProfileManager.user.value!.id,
            'created_at': currentMessageModel.createdAt,
          };

          // send message to socket
          status =
              getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

          // update in cache message
          currentMessageModel.messageContent = json.encode(content).encrypted();

          update();

          // update message in local database
          getIt<DBManager>().updateMessageContent(
              roomId: room.id,
              localMessageId: currentMessageModel.localMessageId.toString(),
              content: json.encode(content).encrypted());
        });

    setReplyMessage(message: null);
    return status;
  }

  Future<bool> sendAudioMessage(
      {required Media media,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;

    String localMessageId = randomId();
    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();

    // store audio in local storage
    File mainFile = await FileManager.saveChatMediaToDirectory(
        media, localMessageId, false, chatRoom.value!.id);

    ChatMessageModel currentMessageModel = ChatMessageModel();

    var content = {
      'messageType': messageTypeId(MessageContentType.audio),
    };
    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.roomId = room.id;
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    currentMessageModel.sender = _userProfileManager.user.value!;

    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.audio);
    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    currentMessageModel.messageContent = json.encode(content).encrypted();
    // currentMessageModel.media = media;
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    addNewMessage(message: currentMessageModel, roomId: room.id);

    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);
    update();

    // upload audio and send message

    uploadMedia(
        messageId: localMessageId,
        media: media,
        mainFile: mainFile,
        callback: (uploadedMedia) {
          var content = {
            'messageType': messageTypeId(MessageContentType.audio),
            'audio': uploadedMedia.audio,
          };

          var message = {
            'userId': _userProfileManager.user.value!.id,
            'localMessageId': localMessageId,
            'is_encrypted': AppConfigConstants.enableEncryption,
            'chat_version': AppConfigConstants.chatVersion,
            'messageType': messageTypeId(mode == ChatMessageActionMode.reply
                ? MessageContentType.reply
                : MessageContentType.audio),
            'message': json.encode(content).encrypted(),
            'room': room.id,
            'created_by': _userProfileManager.user.value!.id,
            'created_at': currentMessageModel.createdAt,
            'replied_on_message': repliedOnMessage,
          };

          // send message to socket
          status =
              getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

          // update in cache message

          currentMessageModel.messageContent = json.encode(content).encrypted();

          // update message in local database
          getIt<DBManager>().updateMessageContent(
              roomId: room.id,
              localMessageId: currentMessageModel.localMessageId.toString(),
              content: json.encode(content).encrypted());
        });

    setReplyMessage(message: null);
    return status;
  }

  Future<bool> sendGifMessage(
      {required String gif,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;
    String localMessageId = randomId();
    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();

    var content = {
      'image': gif,
      'video': '',
      'messageType': messageTypeId(MessageContentType.gif),
    };

    ChatMessageModel currentMessageModel = ChatMessageModel();

    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.roomId = room.id;
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    currentMessageModel.sender = _userProfileManager.user.value!;
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.gif);
    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    currentMessageModel.messageContent =
        json.encode(content).replaceAll('\\', '').encrypted();

    addNewMessage(message: currentMessageModel, roomId: room.id);

    update();

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'localMessageId': localMessageId,
      'is_encrypted': AppConfigConstants.enableEncryption,
      'chat_version': AppConfigConstants.chatVersion,
      'messageType': messageTypeId(mode == ChatMessageActionMode.reply
          ? MessageContentType.reply
          : MessageContentType.gif),
      'message': json.encode(content).encrypted(),
      'replied_on_message': repliedOnMessage,
      'room': room.id,
      'created_by': _userProfileManager.user.value!.id,
      'created_at': currentMessageModel.createdAt,
    };

    status = getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

    // save message to database

    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);
    setReplyMessage(message: null);
    return status;
  }

  Future<bool> sendFileMessage(
      {required Media media,
      required ChatMessageActionMode mode,
      required ChatRoomModel room}) async {
    bool status = true;

    String localMessageId = randomId();
    String? repliedOnMessage = selectedMessage.value == null
        ? null
        : jsonEncode(selectedMessage.value!.toJson()).encrypted();

    // store file in local storage
    File mainFile = await FileManager.saveChatMediaToDirectory(
        media, localMessageId, false, chatRoom.value!.id);

    ChatMessageModel currentMessageModel = ChatMessageModel();

    // if (mode == ChatMessageActionMode.reply) {
    //   currentMessageModel.localMessageId = localMessageId;
    //   currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    //   currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    //   currentMessageModel.sender = _userProfileManager.user.value!;
    //
    //   currentMessageModel.roomId = room.id;
    //   // currentMessageModel.messageTime = justNow;
    //   currentMessageModel.userName = you;
    //   currentMessageModel.senderId = _userProfileManager.user.value!.id;
    //   currentMessageModel.messageType = messageTypeId(MessageContentType.reply);
    //   currentMessageModel.repliedOnMessageContent = repliedOnMessage;
    //
    //   // reply content start
    //   ChatMessageModel replyMessage = ChatMessageModel();
    //   replyMessage.isEncrypted = AppConfigConstants.enableEncryption;
    //   replyMessage.chatVersion = AppConfigConstants.chatVersion;
    //
    //   replyMessage.id = 0;
    //   replyMessage.roomId = room.id;
    //   replyMessage.localMessageId = localMessageId;
    //   replyMessage.senderId = _userProfileManager.user.value!.id;
    //   replyMessage.messageType = messageTypeId(MessageContentType.file);
    //   replyMessage.media = media;
    //   replyMessage.messageContent = ''.encrypted();
    //   replyMessage.createdAt =
    //       (DateTime.now().millisecondsSinceEpoch / 1000).round();
    //
    //   currentMessageModel.cachedReplyMessage = replyMessage;
    //   // reply content end
    //
    //   currentMessageModel.createdAt =
    //       (DateTime.now().millisecondsSinceEpoch / 1000).round();
    //   currentMessageModel.messageContent = ''.encrypted();
    //
    //   addNewMessage(message: currentMessageModel, roomId: room.id);
    //   getIt<DBManager>().saveMessage(room, [currentMessageModel]);
    // } else {
    currentMessageModel.localMessageId = localMessageId;
    currentMessageModel.roomId = room.id;
    currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
    currentMessageModel.chatVersion = AppConfigConstants.chatVersion;
    currentMessageModel.sender = _userProfileManager.user.value!;

    // currentMessageModel.messageTime = justNow;
    currentMessageModel.userName = youString.tr;
    currentMessageModel.senderId = _userProfileManager.user.value!.id;
    currentMessageModel.messageType = messageTypeId(
        mode == ChatMessageActionMode.reply
            ? MessageContentType.reply
            : MessageContentType.file);
    currentMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();
    currentMessageModel.messageContent = ''.encrypted();
    currentMessageModel.media = media;
    currentMessageModel.repliedOnMessageContent = repliedOnMessage;

    addNewMessage(message: currentMessageModel, roomId: room.id);
    getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);
    // }

    update();

    // upload file and send message

    uploadMedia(
        messageId: localMessageId,
        media: media,
        mainFile: mainFile,
        callback: (uploadedMedia) {
          var fileContent = {
            'path': uploadedMedia.file,
            'type': media.mediaTypeId,
            'name': media.title,
            'size': media.fileSize
          };

          var content = {
            'file': fileContent,
            'messageType': messageTypeId(MessageContentType.file),
          };

          var message = {
            'userId': _userProfileManager.user.value!.id,
            'localMessageId': localMessageId,
            'is_encrypted': AppConfigConstants.enableEncryption,
            'chat_version': AppConfigConstants.chatVersion,
            'messageType': messageTypeId(mode == ChatMessageActionMode.reply
                ? MessageContentType.reply
                : MessageContentType.file),
            'message': json.encode(content).encrypted(),
            'replied_on_message': repliedOnMessage,
            'room': room.id,
            'created_by': _userProfileManager.user.value!.id,
            'created_at': currentMessageModel.createdAt,
          };

          // send message to socket
          status =
              getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

          // update in cache message

          currentMessageModel.messageContent = json.encode(content).encrypted();
          // update message in local database
          getIt<DBManager>().updateMessageContent(
              roomId: room.id,
              localMessageId: currentMessageModel.localMessageId.toString(),
              content: json.encode(content).encrypted());
        });
    setReplyMessage(message: null);
    return status;
  }

  Future<bool> sendStoryTextReplyMessage(
      {required String messageText,
      required StoryMediaModel storyMedia,
      required ChatRoomModel room}) async {
    bool status = true;

    final filter = ProfanityFilter();
    bool hasProfanity = filter.hasProfanity(messageText);
    if (hasProfanity) {
      AppUtil.showToast(message: notAllowedMessageString.tr, isSuccess: true);
      return false;
    }

    String encryptedTextMessage = messageText.encrypted();
    var content = {
      'messageType': messageTypeId(MessageContentType.text),
      'text': encryptedTextMessage,
    };

    String repliedOnStory = jsonEncode(storyMedia.toJson()).encrypted();

    if (encryptedTextMessage.removeAllWhitespace.trim().isNotEmpty) {
      String localMessageId = randomId();
      var message = {
        'userId': _userProfileManager.user.value!.id,
        'localMessageId': localMessageId,
        'is_encrypted': AppConfigConstants.enableEncryption,
        'messageType': messageTypeId(MessageContentType.textReplyOnStory),
        'message': json.encode(content).encrypted(),
        'replied_on_message': repliedOnStory,
        'chat_version': AppConfigConstants.chatVersion,
        'room': room.id,
        'created_by': _userProfileManager.user.value!.id,
        'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
      };

      //save message to socket server
      status =
          getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

      ChatMessageModel currentMessageModel = ChatMessageModel();
      currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
      currentMessageModel.chatVersion = AppConfigConstants.chatVersion;

      currentMessageModel.localMessageId = localMessageId;
      currentMessageModel.sender = _userProfileManager.user.value!;

      currentMessageModel.roomId = room.id;

      currentMessageModel.userName = youString.tr;
      currentMessageModel.senderId = _userProfileManager.user.value!.id;
      currentMessageModel.messageType =
          messageTypeId(MessageContentType.textReplyOnStory);
      currentMessageModel.messageContent = json.encode(content).encrypted();
      currentMessageModel.repliedOnMessageContent = repliedOnStory;

      currentMessageModel.createdAt =
          (DateTime.now().millisecondsSinceEpoch / 1000).round();

      getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);

      update();
    }

    return status;
  }

  Future<bool> sendStoryReactionReplyMessage(
      {required String emoji,
      required StoryMediaModel storyMedia,
      required ChatRoomModel room}) async {
    bool status = true;

    String encryptedTextMessage = emoji.encrypted();
    var content = {
      'messageType': messageTypeId(MessageContentType.text),
      'text': encryptedTextMessage,
    };

    String reactedOnStory = jsonEncode(storyMedia.toJson()).encrypted();

    if (encryptedTextMessage.removeAllWhitespace.trim().isNotEmpty) {
      String localMessageId = randomId();
      var message = {
        'userId': _userProfileManager.user.value!.id,
        'localMessageId': localMessageId,
        'is_encrypted': AppConfigConstants.enableEncryption,
        'messageType': messageTypeId(MessageContentType.reactedOnStory),
        'message': json.encode(content).encrypted(),
        'replied_on_message': reactedOnStory,
        'chat_version': AppConfigConstants.chatVersion,
        'room': room.id,
        'created_by': _userProfileManager.user.value!.id,
        'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
      };

      //save message to socket server
      status =
          getIt<SocketManager>().emit(SocketConstants.sendMessage, message);

      ChatMessageModel currentMessageModel = ChatMessageModel();
      currentMessageModel.isEncrypted = AppConfigConstants.enableEncryption;
      currentMessageModel.chatVersion = AppConfigConstants.chatVersion;

      currentMessageModel.localMessageId = localMessageId;
      currentMessageModel.sender = _userProfileManager.user.value!;

      currentMessageModel.roomId = room.id;

      currentMessageModel.userName = youString.tr;
      currentMessageModel.senderId = _userProfileManager.user.value!.id;
      currentMessageModel.messageType =
          messageTypeId(MessageContentType.reactedOnStory);
      currentMessageModel.messageContent = json.encode(content).encrypted();
      currentMessageModel.repliedOnMessageContent = reactedOnStory;

      currentMessageModel.createdAt =
          (DateTime.now().millisecondsSinceEpoch / 1000).round();

      getIt<DBManager>().saveMessage(chatMessages: [currentMessageModel]);
    }

    return status;
  }

  addNewMessage(
      {required ChatMessageModel message, required int roomId}) async {
    if (roomId != message.roomId) {
      return;
    }
    // add date separator
    if (messages.isNotEmpty) {
      // String dateTimeStr = messages.last.date;
      // if (dateTimeStr != message.date) {
      //   ChatMessageModel separatorMessage = ChatMessageModel();
      //   separatorMessage.createdAt = message.createdAt;
      //   separatorMessage.isDateSeparator = true;
      //   messages.add(separatorMessage);
      // }
    }

    messages.add(message);

    // prepare smart reply suggestion messages
    if (message.messageContentType == MessageContentType.text &&
        message.isDateSeparator == false &&
        message.isMineMessage == false) {
      smartReply.addMessageToConversationFromRemoteUser(
          message.isEncrypted == 1
              ? message.messageContent.decrypted()
              : message.messageContent,
          DateTime.now().millisecondsSinceEpoch,
          message.senderId.toString());

      // var result = await smartReply.suggestReplies([lastMsg]);
      final response = await smartReply.suggestReplies();

      smartReplySuggestions.value = List.from(response.suggestions);
      update();
    } else {
      smartReplySuggestions.clear();
      update();
    }
  }

  Future<bool> forwardSelectedMessages({required ChatRoomModel room}) async {
    bool status = true;
    for (ChatMessageModel msg in selectedMessages) {
      await forwardMessage(msg: msg, room: room).then((value) {
        status = value;
      });
    }
    return status;
  }

  Future<Map<String, String>> uploadMedia(
      {required String messageId,
      required Media media,
      required File mainFile,
      File? thumbnailFile,
      required Function(UploadedGalleryMedia) callback}) async {
    Map<String, String> gallery = {};

    await AppUtil.checkInternet().then((value) async {
      if (value) {
        // File mainFile;
        String? videoThumbnailPath;
        // String messageMediaDirectoryPath =
        //     await messageMediaDirectory(messageId);

        if (media.mediaType == GalleryMediaType.photo) {
        } else if (media.mediaType == GalleryMediaType.video) {
          await MiscApi.uploadFile(thumbnailFile!.path,
              mediaType: GalleryMediaType.photo,
              type: UploadMediaType.chat, resultCallback: (filename, filepath) {
            videoThumbnailPath = filepath;
          });
        } else if (media.mediaType == GalleryMediaType.audio) {
          // mainFile = await FileManager.saveChatMediaToDirectory(
          //     media, messageId, false, chatRoom.value!.id);

          // Uint8List mainFileData;
          // if (media.mediaByte == null) {
          //   mainFileData = media.file!.readAsBytesSync();
          // } else {
          //   mainFileData = media.mediaByte!;
          // }
          // // audio
          // String audioPath = '$messageMediaDirectoryPath/$messageId.mp3';
          // mainFile = await File(audioPath).create();
          // mainFile.writeAsBytesSync(mainFileData);
        } else {
          // Uint8List mainFileData;
          // if (media.mediaByte == null) {
          //   mainFileData = media.file!.readAsBytesSync();
          // } else {
          //   mainFileData = media.mediaByte!;
          // }
          // // file
          //
          // final extension = p.extension(media.file!.path); // '.dart'
          //
          // String filePath = '$messageMediaDirectoryPath/$messageId$extension';
          // mainFile = await File(filePath).create();
          // mainFile.writeAsBytesSync(mainFileData);
          // mainFile = await FileManager.saveChatMediaToDirectory(
          //     media, messageId, false, chatRoom.value!.id);
        }

        await MiscApi.uploadFile(mainFile.path,
            mediaType: media.mediaType!,
            type: UploadMediaType.chat, resultCallback: (filename, filepath) {
          String mainFileUploadedPath = filepath;

          // await mainFile.delete();

          UploadedGalleryMedia uploadedGalleryMedia = UploadedGalleryMedia(
              mediaType: media.mediaType == GalleryMediaType.photo
                  ? 1
                  : media.mediaType == GalleryMediaType.video
                      ? 2
                      : 3,
              thumbnail: media.mediaType == GalleryMediaType.photo
                  ? mainFileUploadedPath
                  : media.mediaType == GalleryMediaType.video
                      ? videoThumbnailPath!
                      : null,
              video: media.mediaType == GalleryMediaType.video
                  ? mainFileUploadedPath
                  : null,
              audio: media.mediaType == GalleryMediaType.audio
                  ? mainFileUploadedPath
                  : null,
              file: mainFileUploadedPath);
          callback(uploadedGalleryMedia);
        });
      } else {
        AppUtil.showToast(message: noInternetString.tr, isSuccess: false);
      }
    });
    return gallery;
  }

  deleteMessage({required int deleteScope}) async {
    // remove message in local database
    await getIt<DBManager>()
        .softDeleteMessages(messagesToDelete: selectedMessages);

    // remove saved media
    getIt<FileManager>().multipleDeleteMessageMedia(selectedMessages);

    // delete message in local cache
    messages.value = messages.map((element) {
      if (selectedMessages
          .map((element) => element.localMessageId)
          .toList()
          .contains(element.localMessageId)) {
        element.isDeleted = true;

        // print('element.chatMessageUser ${element.chatMessageUser.length}');
        // ChatMessageUser user = element.chatMessageUser
        //     .where((element) =>
        //         element.userId == _userProfileManager.user.value!.id)
        //     .first;
        // //TODO : check deleted message status
        // user.status == 4;
      } else {}
      return element;
    }).toList();
    messages.refresh();

    //delete message from server
    for (ChatMessageModel message in selectedMessages) {
      getIt<SocketManager>().emit(SocketConstants.deleteMessage, {
        'id': message.id,
        'room': message.roomId,
        'deleteScope': deleteScope
      });
    }
    // selectedMessages.clear();
    setToActionMode(mode: ChatMessageActionMode.none);
    update();
  }

  addNewContact(Contact contact) async {
    await contact.insert();
  }

//*************** updates from socket *******************//

  messagedDeleted(
      {required int messageId, required int roomId, required userId}) async {
    // update message in local cache
    if (chatRoom.value?.id == roomId) {
      messages.value = messages.map((element) {
        if (selectedMessages
            .map((element) => element.localMessageId)
            .toList()
            .contains(element.localMessageId)) {
          element.isDeleted = true;
        } else {}
        return element;
      }).toList();
      messages.refresh();
    }

    // delete media messages
    List<ChatMessageModel> messagesList = await getIt<DBManager>()
        .getMessagesById(messageId: messageId, roomId: roomId);

    // remove saved media
    getIt<FileManager>().multipleDeleteMessageMedia(messagesList);

    // delete message in local database
    getIt<DBManager>().softDeleteMessages(messagesToDelete: messagesList);
  }

  newMessageReceived(ChatMessageModel message) async {
    if (chatRoom.value?.id == message.roomId) {
      addNewMessage(message: message, roomId: message.roomId);

      isTypingMapping[message.userName] = false;
      // isTyping.value = false;
      isTypingMapping.refresh();
      if (message.messageContentType == MessageContentType.groupAction) {
        await getRoomDetail(chatRoom.value!.id, (chatroom) {
          chatRoom.value = chatroom;
          chatRoom.refresh();
        });
      }
    } else {
      if (message.messageContentType != MessageContentType.groupAction) {
        showNewMessageBanner(message, message.roomId);
      }
    }

    update();
  }

  messageUpdateReceived(Map<String, dynamic> updatedData) async {
    String? localMessageId = updatedData['localMessageId'];
    int roomId = updatedData['room'];
    int status = updatedData['current_status'];
    int messageId = updatedData['id'];
    // int createdAt = updatedData['created_at'];
    if (localMessageId != null) {
      if (chatRoom.value?.id == roomId) {
        var message =
            messages.where((e) => e.localMessageId == localMessageId).first;
        message.id = messageId;
        message.status = status;
        // message.createdAt = createdAt;
        // message.media = null;
        if (message.messageContentType == MessageContentType.reply) {
          // message.reply.media = null;
        }
        messages.refresh();

        update();
      }

      await getIt<DBManager>().updateMessageStatus(
          roomId: roomId,
          localMessageId: localMessageId,
          id: messageId,
          status: status);
    }
    if (status == 1) {
      // add chat message user to message for first time, as here we received the message id
      List<ChatRoomMember> usersInRoom =
          await getIt<DBManager>().getAllMembersInRoom(roomId);
      List<ChatMessageUser> chatMessageUsers = usersInRoom.map((e) {
        ChatMessageUser user = ChatMessageUser();
        user.id = 1;
        user.messageId = messageId;
        user.userId = e.userId;
        user.status = 1;
        return user;
      }).toList();
      getIt<DBManager>().insertChatMessageUsers(users: chatMessageUsers);
    }
  }

  userTypingStatusChanged(
      {required String userName, required int roomId, required bool status}) {
    if (chatRoom.value?.id != roomId) {
      return;
    }
    // if (chatRoom.value!.isGroupChat == false) {
    //   if (opponents.first.userDetail.userName == userName) {
    typingStatusUpdatedAt = DateTime.now();

    isTypingMapping[userName] = status;
    // isTyping.value = status;
    isTypingMapping.refresh();

    whoIsTyping.add(userName);

    if (status == true) {
      Timer(const Duration(seconds: 5), () {
        if (typingStatusUpdatedAt != null) {
          if (DateTime.now().difference(typingStatusUpdatedAt!).inSeconds > 4) {
            isTypingMapping[userName] = false;
            isTypingMapping.refresh();
            whoIsTyping.remove(userName);
          }
        } else {
          isTypingMapping[userName] = false;
          isTypingMapping.refresh();
          whoIsTyping.remove(userName);
        }
      });
    }
    //   }
    // }
    // else{
    //
    // }
  }

  userAvailabilityStatusChange({required int userId, required bool isOnline}) {
    if (chatRoom.value != null) {
      if (chatRoom.value?.isGroupChat == false) {
        chatRoom.value!.roomMembers = chatRoom.value!.roomMembers.map((member) {
          if (member.userDetail.id == userId) {
            member.userDetail.isOnline = true;
          }
          return member;
        }).toList();

        chatRoom.refresh();

        // List<ChatRoomMember> matchedMembers = chatRoom.value!.roomMembers
        //     .where((element) => element.userDetail.id == userId)
        //     .toList();
        //
        // if (matchedMembers.isNotEmpty) {
        //   ChatRoomMember matchedMember =
        //   opponents.first.userDetail.isOnline = isOnline;
        //   opponents.refresh();
        // }
      }
    }
  }

  updatedChatGroupAccessStatus(
      {required int chatRoomId, required int chatAccessGroup}) {
    if (chatRoom.value?.id == chatRoomId) {
      chatRoom.value?.groupAccess = chatAccessGroup;
      chatRoom.refresh();
    }
  }

// call
  void initiateVideoCall() {
    PermissionUtils.requestPermission(
        [Permission.camera, Permission.microphone], isOpenSettings: false,
        permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 2,
          opponent: opponent.value!);

      agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToCameraForVideoCallString.tr,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToCameraForVideoCallString.tr,
          isSuccess: false);
    });
  }

  void initiateAudioCall() {
    PermissionUtils.requestPermission([Permission.microphone],
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 1,
          opponent: opponent.value!);

      agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString.tr,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString.tr,
          isSuccess: false);
    });
  }
}
