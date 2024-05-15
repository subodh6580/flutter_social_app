import 'dart:io';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:share_plus/share_plus.dart';
import '../../manager/socket_manager.dart';

class ChatRoomDetailController extends GetxController {
  RxList<ChatMessageModel> photos = <ChatMessageModel>[].obs;
  RxList<ChatMessageModel> videos = <ChatMessageModel>[].obs;
  RxList<ChatMessageModel> starredMessages = <ChatMessageModel>[].obs;
  final ChatDetailController _chatDetailController = Get.find();
  final ChatHistoryController _chatHistoryController = Get.find();

  Rx<ChatRoomModel?> currentRoom = Rx<ChatRoomModel?>(null);

  RxInt selectedSegment = 0.obs;

  setCurrentRoom(ChatRoomModel? room) {
    currentRoom.value = room;
  }

  makeUserAsAdmin(UserModel user, ChatRoomModel chatRoom) {
    getIt<SocketManager>().emit(SocketConstants.makeUserAdmin,
        {'room': chatRoom.id, 'userId': user.id});
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom, callback: () {});
  }

  removeUserAsAdmin(UserModel user, ChatRoomModel chatRoom) {
    getIt<SocketManager>().emit(SocketConstants.removeUserAdmin,
        {'room': chatRoom.id, 'userId': user.id});
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom, callback: () {});
  }

  removeUserFormGroup(
      {required UserModel user, required ChatRoomModel chatRoom}) {
    getIt<SocketManager>().emit(SocketConstants.removeUserFromGroupChat,
        {'room': chatRoom.id, 'userId': user.id});

    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom, callback: () {});
  }

  addUsersToPublicRoom(
      {required ChatRoomModel room, required List<UserModel> selectedFriends}) {
    final UserProfileManager userProfileManager = Get.find();

    for (UserModel user in selectedFriends) {
      // add user in group via socket api

      getIt<SocketManager>().emit(SocketConstants.addUserInChatRoom,
          {'userId': user.id.toString(), 'room': room.id});
    }

    // add member in current viewing group
    if (currentRoom.value != null) {
      ChatRoomMember member = ChatRoomMember(
          id: 0,
          userDetail: userProfileManager.user.value!,
          roomId: room.id,
          userId: userProfileManager.user.value!.id,
          isAdmin: 0);

      currentRoom.value!.roomMembers.add(member);
      currentRoom.refresh();
    }

    // add member in group showing in listing
    _chatHistoryController.joinPublicGroup(room);
  }

  addUsersToRoom(
      {required ChatRoomModel room, required List<UserModel> selectedFriends}) {
    for (UserModel user in selectedFriends) {
      // add user in group via socket api

      getIt<SocketManager>().emit(SocketConstants.addUserInChatRoom,
          {'userId': user.id.toString(), 'room': room.id});

      _chatDetailController.chatRoom.value?.roomMembers
          .add(user.toChatRoomMember);
    }

    _chatDetailController.update();
  }

  leavePublicGroup(ChatRoomModel chatRoom) {
    final UserProfileManager userProfileManager = Get.find();

    // remove user from group via socket api
    getIt<SocketManager>()
        .emit(SocketConstants.leaveGroupChat, {'room': chatRoom.id});

    // remove member from current viewing group
    if (currentRoom.value != null) {
      currentRoom.value!.roomMembers.removeWhere((element) =>
      element.userDetail.id == userProfileManager.user.value!.id);
      currentRoom.refresh();
    }

    // remove member from group showing in listing
    _chatHistoryController.leavePublicGroup(chatRoom);
  }

  leaveGroup(ChatRoomModel chatRoom) {
    getIt<SocketManager>()
        .emit(SocketConstants.leaveGroupChat, {'room': chatRoom.id});
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom,
        callback: () {
          Get.back();
        });
  }

  updateGroupAccess(int access) {
    getIt<SocketManager>().emit(SocketConstants.updateChatAccessGroup, {
      'room': _chatDetailController.chatRoom.value!.id,
      'chatAccessGroup': access
    });

    _chatDetailController.getUpdatedChatRoomDetail(
        room: _chatDetailController.chatRoom.value!, callback: () {});
  }

  deleteGroup(ChatRoomModel chatRoom) {
    getIt<DBManager>().deleteRooms([chatRoom]);
    _chatDetailController.getUpdatedChatRoomDetail(
        room: chatRoom,
        callback: () {
          Get.back();
        });
  }

  getStarredMessages(ChatRoomModel room) async {
    starredMessages.value =
    await getIt<DBManager>().getStarredMessages(roomId: room.id);
    update();
  }

  unStarMessages() {
    for (ChatMessageModel message in _chatDetailController.selectedMessages) {
      _chatDetailController.unStarMessage(message);

      starredMessages.remove(message);
      if (starredMessages.isEmpty) {
        Get.back();
      } else {
        starredMessages.refresh();
      }
    }
  }

  segmentChanged(int index, int roomId) {
    selectedSegment.value = index;

    if (selectedSegment.value == 0) {
      loadImageMessages(roomId);
    } else {
      loadVideoMessages(roomId);
    }

    update();
  }

  exportChat({required int roomId, required bool includeMedia}) async {
    String? mediaFolderPath;
    Directory chatMediaDirectory;
    final appDir = await getApplicationDocumentsDirectory();
    mediaFolderPath = '${appDir.path}/${roomId.toString()}';

    chatMediaDirectory = Directory(mediaFolderPath);

    if (chatMediaDirectory.existsSync() == false) {
      await Directory(mediaFolderPath).create();
    }
    List messages =
    await getIt<DBManager>().getAllMessages(roomId: roomId, offset: 0);

    File chatTextFile = File('${chatMediaDirectory.path}/chat.text');
    if (chatTextFile.existsSync()) {
      chatTextFile.delete();
      chatTextFile = File('${chatMediaDirectory.path}/chat.text');
    }

    String messagesString = '';
    for (ChatMessageModel message in messages) {
      if (message.messageContentType == MessageContentType.text &&
          message.isDateSeparator == false) {
        messagesString += '\n';
        messagesString +=
        '[${message.messageTime}] ${message.isMineMessage ? 'Me' : message.userName}: ${message.isDeleted == true ? thisMessageIsDeletedString.tr : message.messageContent}';
      }
    }

    chatTextFile.writeAsString(messagesString);

    if (includeMedia) {
      try {
        final tempDir = await getTemporaryDirectory();
        File zipFile = File('${tempDir.path}/chat.zip');
        if (zipFile.existsSync()) {
          zipFile.delete();
          zipFile = File('${tempDir.path}/chat.zip');
        }

        ZipFile.createFromDirectory(
            sourceDir: chatMediaDirectory,
            zipFile: zipFile,
            recurseSubDirs: true);
        Share.shareXFiles([XFile(zipFile.path)]);
      } catch (e) {
        // print(e);
      }
    } else {
      Share.shareXFiles([XFile(chatTextFile.path)]);
    }
  }

  loadImageMessages(int roomId) async {
    photos.value = await getIt<DBManager>()
        .getMessages(roomId: roomId, contentType: MessageContentType.photo);
    update();
  }

  loadVideoMessages(int roomId) async {
    videos.value = await getIt<DBManager>()
        .getMessages(roomId: roomId, contentType: MessageContentType.video);
    update();
  }

  deleteRoomChat(ChatRoomModel chatRoom) {
    getIt<DBManager>().deleteMessagesInRoom(chatRoom);
  }
}
