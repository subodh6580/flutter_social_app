import 'dart:async';
import 'dart:ui';
import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:get/get.dart';
import '../../helper/user_profile_manager.dart';
import '../../model/data_wrapper.dart';
import '../../screens/dashboard/dashboard_screen.dart';

class ChatHistoryController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();
  final DashboardController _dashboardController = Get.find();

  List<ChatRoomModel> allRooms = [];
  RxList<ChatRoomModel> publicGroups = <ChatRoomModel>[].obs;

  RxList<ChatRoomModel> searchedRooms = <ChatRoomModel>[].obs;

  Map<String, dynamic> typingStatus = {};
  DataWrapper publicGroupsDataWrapper = DataWrapper();
  DataWrapper chatRoomDataWrapper = DataWrapper();

  getChatRooms() async {
    allRooms = await getIt<DBManager>().getAllRooms();

    searchedRooms.value = allRooms;
     update();

    // if (allRooms.isEmpty) {
    ChatApi.getChatRooms(resultCallback: (result) async {
      List<ChatRoomModel> groupChatRooms = result
          // .where((element) => element.isGroupChat == true)
          .toList();
      await getIt<DBManager>().saveRooms(groupChatRooms);

      allRooms = await getIt<DBManager>().getAllRooms();
      // allRooms = await getIt<DBManager>().mapUnReadCount(groupChatRooms);
      searchedRooms.value = allRooms;
      searchedRooms.value = searchedRooms
          .where((e) => e.isGroupChat == true || (e.roomMembers.length > 1))
          .toList();
      update();
    });
    // } else {
    //   isLoading = false;
    // }
  }

  refreshPublicGroups(VoidCallback callback) {
    publicGroupsDataWrapper = DataWrapper();
    getPublicChatRooms(callback);
  }

  loadMorePublicGroups(VoidCallback callback) {
    if (publicGroupsDataWrapper.haveMoreData.value) {
      getPublicChatRooms(callback);
    } else {
      callback();
    }
  }

  getPublicChatRooms(VoidCallback callback) async {
    publicGroupsDataWrapper.isLoading.value = true;

    ChatApi.getPublicChatRooms(
        page: publicGroupsDataWrapper.page,
        resultCallback: (result, metaData) async {
          publicGroupsDataWrapper.isLoading.value = false;
          publicGroups.addAll(result);

          publicGroupsDataWrapper.haveMoreData.value =
              metaData.currentPage <= metaData.pageCount;
          publicGroupsDataWrapper.page += 1;
          callback();
          update();
        });
  }

  searchTextChanged(String text) {
    if (text.isEmpty) {
      searchedRooms.value = allRooms;
      update();
      return;
    }
    searchedRooms.value = allRooms.where((room) {
      if (room.isGroupChat) {
        return room.name!.toLowerCase().contains(text);
      } else {
        return room.opponent.userDetail.userName.toLowerCase().contains(text);
      }
    }).toList();
    searchedRooms.refresh();
    update();
  }

  clearUnreadCount({required ChatRoomModel chatRoom}) async {
    getIt<DBManager>().clearUnReadCount(roomId: chatRoom.id);
    int roomsWithUnreadMessageCount =
        await getIt<DBManager>().roomsWithUnreadMessages();
    _dashboardController.updateUnreadMessageCount(roomsWithUnreadMessageCount);

    getChatRooms();
    update();
  }

  deleteRoom(ChatRoomModel chatRoom) {
    allRooms.removeWhere((element) => element.id == chatRoom.id);
    getIt<DBManager>().deleteRooms([chatRoom]);
    update();
    ChatApi.deleteChatRoom(chatRoom.id);
  }

  // ******************* updates from socket *****************//

  newMessageReceived(ChatMessageModel message) async {
    List<ChatRoomModel> existingRooms =
        allRooms.where((room) => room.id == message.roomId).toList();

    if (existingRooms.isNotEmpty &&
        message.roomId != _chatDetailController.chatRoom.value?.id) {
      ChatRoomModel room = existingRooms.first;
      room.lastMessage = message;
      room.whoIsTyping.remove(message.userName);
      typingStatus[message.userName] = null;

      // room.unreadMessages += 1;
      // allRooms.refresh();
      searchedRooms.refresh();
      update();
      getIt<DBManager>().updateUnReadCount(roomId: message.roomId);
    }

    getChatRooms();
  }

  userTypingStatusChanged(
      {required String userName, required int roomId, required bool status}) {
    var matchedRooms = allRooms.where((element) => element.id == roomId);

    if (matchedRooms.isNotEmpty) {
      var room = matchedRooms.first;

      if (typingStatus[userName] == null) {
        room.whoIsTyping.add(userName);
        searchedRooms.refresh();
      }

      typingStatus[userName] = DateTime.now();

      // room.isTyping = status;
      // searchedRooms.refresh();
      // update();
      if (status == true) {
        Timer(const Duration(seconds: 5), () {
          if (typingStatus[userName] != null) {
            if (DateTime.now().difference(typingStatus[userName]!).inSeconds >
                4) {
              room.whoIsTyping.remove(userName);
              typingStatus[userName] = null;
              searchedRooms.refresh();
              update();
            }
          }
        });
      }
      update();
    }
  }

  userAvailabilityStatusChange({required int userId, required bool isOnline}) {
    var matchedRooms =
        allRooms.where((element) => element.opponent.id == userId);

    if (matchedRooms.isNotEmpty) {
      var room = matchedRooms.first;
      room.isOnline = isOnline;
      room.opponent.userDetail.isOnline = isOnline;
      searchedRooms.refresh();
      // update();
    }
  }

  joinPublicGroup(ChatRoomModel room) {
    final UserProfileManager userProfileManager = Get.find();

    publicGroups.value = publicGroups.map((element) {
      if (element.id == room.id) {
        ChatRoomMember member = ChatRoomMember(
            id: 0,
            userDetail: userProfileManager.user.value!,
            roomId: room.id,
            userId: userProfileManager.user.value!.id,
            isAdmin: 0);

        element.roomMembers.add(member);
      }
      return element;
    }).toList();
    publicGroups.refresh();
  }

  leavePublicGroup(ChatRoomModel room) {
    final UserProfileManager userProfileManager = Get.find();

    publicGroups.value = publicGroups.map((element) {
      if (element.id == room.id) {
        element.roomMembers.removeWhere((element) =>
            element.userDetail.id == userProfileManager.user.value!.id);
      }
      return element;
    }).toList();
    publicGroups.refresh();
  }
}
