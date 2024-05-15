//Initialize Socket Connection
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/controllers/chat_and_call/agora_call_controller.dart';
import 'package:foap/controllers/live/agora_live_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_history_controller.dart';
import 'package:foap/controllers/home/home_controller.dart';
import 'package:foap/controllers/tv/live_tv_streaming_controller.dart';
import 'package:foap/controllers/chat_and_call/voip_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/helper/socket_constants.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/util/constant_util.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
export 'package:foap/helper/socket_constants.dart';

class CachedRequest {
  String event;
  Map<String, dynamic> data;

  CachedRequest({required this.event, required this.data});
}

class SocketManager {
  io.Socket? _socketInstance;
  String? channelName;
  String? channelToken;
  List<CachedRequest> cachedRequests = [];

  final ChatHistoryController _chatController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();
  final DashboardController _dashboardController = Get.find();
  final AgoraCallController _agoraCallController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();
  final HomeController _homeController = Get.find();
  final TvStreamingController _liveTvStreamingController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  StreamSubscription<FGBGType>? subscription;

  disconnect() {
    _socketInstance?.disconnect();
    _socketInstance = null;
  }

//Initialize Socket Connection
  dynamic connect() {
    if (_socketInstance != null) return;
    _socketInstance = io.io(
      ApiConstants.socketUrl,
      <String, dynamic>{
        ApiConstants.transportsHeader: [
          ApiConstants.webSocketOption,
          ApiConstants.pollingOption
        ],
      },
    );
    getIt<VoipController>().listenerSetup();

    // if(_socketInstance!.connected == false){
    _socketInstance?.connect();
    // }
    socketGlobalListeners();

    subscription = FGBGEvents.stream.listen((event) {
      if (event == FGBGType.foreground) {
        _socketInstance?.connect();
      } else {
        _socketInstance?.disconnect();
      }
      // FGBGType.foreground or FGBGType.background
    });
  }

//Socket Global Listener Events
  dynamic socketGlobalListeners() {
    _socketInstance?.onAny((event, data) {
      // Handle the incoming event and data here
    });
    _socketInstance?.on(SocketConstants.eventConnect, onConnect);
    _socketInstance?.on(SocketConstants.eventDisconnect, onDisconnect);
    _socketInstance?.on(SocketConstants.onSocketError, onConnectError);
    _socketInstance?.on(SocketConstants.eventConnectTimeout, onConnectError);

    // call end points handlers
    _socketInstance?.on(SocketConstants.incomingCall, handleOnCallReceived);

    _socketInstance?.on(
        SocketConstants.onCallRequestConfirm, handleOnCallConfirmation);
    _socketInstance?.on(
        SocketConstants.onCallStatusUpdated, handleOnCallStatusUpdate);

    // chat end point handlers
    _socketInstance?.on(SocketConstants.sendMessage, onReceiveMessage);
    _socketInstance?.on(
        SocketConstants.updateMessageStatus, updateMessageStatus);
    _socketInstance?.on(SocketConstants.deleteMessage, onDeleteMessage);
    _socketInstance?.on(SocketConstants.addUserInChatRoom, addedInRoom);

    _socketInstance?.on(SocketConstants.typing, onReceiveTyping);
    // _socketInstance?.on(SocketConstants.readMessage, readMessage);

    _socketInstance?.on(
        SocketConstants.offlineStatusEvent, onOfflineStatusEvent);
    _socketInstance?.on(SocketConstants.onlineStatusEvent, onOnlineStatusEvent);

    _socketInstance?.on(SocketConstants.leaveGroupChat, leaveGroupChat);
    _socketInstance?.on(SocketConstants.removeUserAdmin, removeUserAdmin);
    _socketInstance?.on(
        SocketConstants.removeUserFromGroupChat, removeUserFromGroupChat);
    _socketInstance?.on(SocketConstants.makeUserAdmin, makeUserAdmin);
    _socketInstance?.on(
        SocketConstants.updateChatAccessGroup, updateChatAccessGroup);

    // live end point handlers
    _socketInstance?.on(SocketConstants.joinLive, liveJoinedByUser);
    // _socketInstance?.on(SocketConstants.sendMessageInLive, onOnlineStatusEvent);
    _socketInstance?.on(
        SocketConstants.liveCreatedConfirmation, liveCreatedConfirmation);
    _socketInstance?.on(SocketConstants.leaveLive, onUserLeaveLive);
    _socketInstance?.on(SocketConstants.endLive, onLiveEnd);
    _socketInstance?.on(SocketConstants.sendMessageInLive, newMessageInLive);
    _socketInstance?.on(
        SocketConstants.newGiftReceivedInLiveCall, newGiftReceivedInLiveCall);

    _socketInstance?.on(
        SocketConstants.liveBattleHostUpdated, liveBattleHostUpdated);
    _socketInstance?.on(SocketConstants.endLiveBattle, endLiveBattle);
    // live tv
    _socketInstance?.on(
        SocketConstants.sendMessageInLiveTv, onReceiveMessageInLiveTv);
  }

  //  To Emit Event Into Socket
  bool emit(String event, Map<String, dynamic> data) {
    log('emiting ${_socketInstance!.connected}');
    if (_socketInstance!.connected == true) {
      log('event == $event ========== data = ${jsonDecode(json.encode(data))}');
      _socketInstance?.emit(event, jsonDecode(json.encode(data)));
    } else {
      // print('socked is not connected');
      cachedRequests.add(CachedRequest(event: event, data: data));
    }
    return _socketInstance!.connected;
  }

//Get This Event After Successful Connection To Socket
  dynamic onConnect(_) {


    emit(SocketConstants.login, {
      'userId': _userProfileManager.user.value!.id,
      'username': _userProfileManager.user.value!.userName
    });

    for (CachedRequest request in cachedRequests) {
      // print('sending cached event ${request.event}');
      emit(request.event, request.data);
    }
    cachedRequests.clear();
  }

  //Get This Event After Connection Lost To Socket Due To Network Or Any Other Reason
  dynamic onDisconnect(_) {
    // print("===> Socket Disconnected....................");
  }

  //Get This Event After Connection Error To Socket With Error
  dynamic onConnectError(error) {
    // print("===> ConnectError socket.................... $error");
  }

  //Get This Event When your call is created
  void handleOnCallConfirmation(dynamic response) {
    _agoraCallController.outgoingCallConfirmationReceived(response);
  }

  //Get This Event When you Received Call From Other User
  void handleOnCallReceived(dynamic response) {
    // voipController.incomingCall();
    // agoraCallController.incomingCallReceived(response);

    // if (response != null) {
    //   final data = ResCallRequestModel.fromJson(response);
    //   Get.to(() => PickUpScreen(
    //       resCallRequestModel: data,
    //       resCallAcceptModel: ResCallAcceptModel(),
    //       isForOutGoing: false));
    // }
  }

//Get This Event When Other User Accepts/decline/completed Your Call
  void handleOnCallStatusUpdate(dynamic response) async {
    _agoraCallController.callStatusUpdateReceived(response);
  }

//******************* Chat ****************************//

  void onReceiveMessage(dynamic response) async {
    ChatMessageModel message = ChatMessageModel.fromJson(response);
    int? senderId = response['userId'] ?? response['created_by'];
    if (senderId != null) {
      String senderName = response['username'];
      UserModel user = UserModel();
      user.id = senderId;
      user.userName = senderName;

      message.sender = user;

      // ChatMessageModel message = ChatMessageModel.fromJson(response);

      await getIt<DBManager>().newMessageReceived(message);
      // await _chatDetailController.newMessageReceived(message);
      // _chatController.newMessageReceived(message);

      int roomsWithUnreadMessageCount =
          await getIt<DBManager>().roomsWithUnreadMessages();

      _dashboardController
          .updateUnreadMessageCount(roomsWithUnreadMessageCount);
    }
  }

  void onDeleteMessage(dynamic response) {
    int deleteScope = response['deleteScope'] as int;
    int roomId = response['room'] as int;
    int messageId = response['id'] as int;
    int userId = response['user_id'] as int;

    if (deleteScope == 2) {
      _chatDetailController.messagedDeleted(
          messageId: messageId, roomId: roomId, userId: userId);
    }
  }

  void onReceiveTyping(dynamic response) {
    var userName = response['username'];
    var roomId = response['room'];

    _chatController.userTypingStatusChanged(
        userName: userName, roomId: roomId, status: true);
    _chatDetailController.userTypingStatusChanged(
        roomId: roomId, userName: userName, status: true);
  }

  void updateMessageStatus(dynamic response) {
    _chatDetailController.messageUpdateReceived(response);
  }

  void onOfflineStatusEvent(dynamic response) {
    var userId = response['userId'];

    _chatController.userAvailabilityStatusChange(
        userId: userId, isOnline: false);
    _chatDetailController.userAvailabilityStatusChange(
        userId: userId, isOnline: false);
  }

  void onOnlineStatusEvent(dynamic response) {
    var userId = response['userId'];
    _chatController.userAvailabilityStatusChange(
        userId: userId, isOnline: true);
    _chatDetailController.userAvailabilityStatusChange(
        userId: userId, isOnline: true);
  }

  addedInRoom(dynamic response) {
    int userIdActionedBy = response['userIdActiondBy'];
    if (userIdActionedBy != _userProfileManager.user.value!.id) {
      response['action'] =
          1; // 1 for added, 2 for removed , 3 for made admin , 4 for removed from admin, 5 left , 6 removed from group
      Map<String, dynamic> chatMessage = {};
      chatMessage['id'] = 0;
      chatMessage['local_message_id'] = randomId();
      chatMessage['room'] = response['room'];
      chatMessage['messageType'] = 100;
      chatMessage['message'] = jsonEncode(response).encrypted();
      chatMessage['created_by'] = response['userIdActiondBy'];
      chatMessage['created_at'] = response['created_at'];

      ChatMessageModel message = ChatMessageModel.fromJson(chatMessage);

      getIt<DBManager>().newMessageReceived(message);
    }
  }

  // group chat
  leaveGroupChat(dynamic response) {
    response['action'] =
        5; // 1 for added, 2 for removed , 3 for made admin ,4 remove form admins, 5 left
    Map<String, dynamic> chatMessage = {};
    chatMessage['id'] = 0;
    chatMessage['local_message_id'] = randomId();
    chatMessage['room'] = response['room'];
    chatMessage['messageType'] = 100;
    chatMessage['message'] = jsonEncode(response).encrypted();
    chatMessage['created_by'] = response['userId'];
    chatMessage['created_at'] = response['created_at'];

    ChatMessageModel message = ChatMessageModel.fromJson(chatMessage);

    getIt<DBManager>().newMessageReceived(message);
  }

  removeUserAdmin(dynamic response) {
    response['action'] =
        4; // 1 for added, 2 for removed , 3 for made admin ,4 left
    Map<String, dynamic> chatMessage = {};
    chatMessage['id'] = 0;
    chatMessage['local_message_id'] = randomId();
    chatMessage['room'] = response['room'];
    chatMessage['messageType'] = 100;
    chatMessage['message'] = jsonEncode(response).encrypted();
    chatMessage['created_by'] = response['userIdActiondBy'];
    chatMessage['created_at'] = response['created_at'];

    ChatMessageModel message = ChatMessageModel.fromJson(chatMessage);
    // _chatController.newMessageReceived(message);
    // _chatDetailController.newMessageReceived(message);
    getIt<DBManager>().newMessageReceived(message);
  }

  removeUserFromGroupChat(dynamic response) {
    response['action'] =
        2; // 1 for added, 2 for removed , 3 for make admin ,4 left
    Map<String, dynamic> chatMessage = {};
    chatMessage['id'] = 0;
    chatMessage['local_message_id'] = randomId();
    chatMessage['room'] = response['room'];
    chatMessage['messageType'] = 100;
    chatMessage['message'] = jsonEncode(response).encrypted();
    chatMessage['created_by'] = response['userIdActiondBy'];
    chatMessage['created_at'] = response['created_at'];

    ChatMessageModel message = ChatMessageModel.fromJson(chatMessage);
    // _chatController.newMessageReceived(message);
    // _chatDetailController.newMessageReceived(message);
    getIt<DBManager>().newMessageReceived(message);
  }

  makeUserAdmin(dynamic response) {
    response['action'] =
        3; // 1 for added, 2 for removed , 3 for made admin ,4 left
    Map<String, dynamic> chatMessage = {};
    chatMessage['id'] = 0;
    chatMessage['local_message_id'] = randomId();
    chatMessage['room'] = response['room'];
    chatMessage['messageType'] = 100;
    chatMessage['message'] = jsonEncode(response).encrypted();
    chatMessage['created_by'] = response['userIdActiondBy'];
    chatMessage['created_at'] = response['created_at'];

    ChatMessageModel message = ChatMessageModel.fromJson(chatMessage);
    // _chatController.newMessageReceived(message);
    // _chatDetailController.newMessageReceived(message);
    getIt<DBManager>().newMessageReceived(message);
  }

  updateChatAccessGroup(dynamic response) {
    _chatDetailController.updatedChatGroupAccessStatus(
        chatRoomId: response['room'],
        chatAccessGroup: response['chatAccessGroup']);
  }

  // live

  void liveJoinedByUser(dynamic response) {
    int userId = response['userId'];
    UsersApi.getOtherUser(
        userId: userId,
        resultCallback: (result) {
          _agoraLiveController.onNewUserJoined(result);
        });
  }

  void newMessageInLive(dynamic response) {
    ChatMessageModel message = ChatMessageModel.fromJson(response);
    _agoraLiveController.onNewMessageReceived(message);
  }

  void liveCreatedConfirmation(dynamic response) {
    _agoraLiveController.liveCreatedConfirmation(response);
  }

  void onUserLeaveLive(dynamic response) {
    int userId = response['userId'];
    int liveId = response['liveCallId'];

    _agoraLiveController.onUserLeave(userId: userId, liveId: liveId);
  }

  void onLiveEnd(dynamic response) {
    _homeController.liveUsersUpdated();
    _agoraLiveController.onLiveEndMessageReceived(response['liveCallId']);
  }

  void liveBattleHostUpdated(dynamic response) async {
    int liveId = response['liveCallId'];

    List<LiveCallHostUser> battleUsers =
        (response['battleInfo']['liveBattleHosts'] as List)
            .map((e) => LiveCallHostUser.fromJson(e))
            .toList();

    // for (Map<String, dynamic> host in response['battleInfo']
    //     ['liveBattleHosts']) {
    //   await UsersApi.getOtherUser(
    //       userId: host['userId'],
    //       resultCallback: (user) {
    //         hostUsers.add(LiveCallHostUser(
    //             battleId: host['battleId'],
    //             userDetail: user,
    //             totalCoins: host['totalCoin'] == null
    //                 ? 0
    //                 : int.parse(host['totalCoin'].toString()),
    //             totalGifts: host['totalGift'] == null
    //                 ? 0
    //                 : int.parse(host['totalGift'].toString()),
    //             isMainHost: host['isSuperHost'] == 1));
    //       });
    // }

    _agoraLiveController.liveCallHostsUpdated(
        liveId: liveId,
        hosts: battleUsers,
        battleDetail: battleUsers.isNotEmpty
            ? BattleDetail.fromJson(response['battleInfo']['battleDetail'])
            : null);
  }

  void endLiveBattle(dynamic response) async {
    int liveId = response['liveCallId'];
    int battleId = response['battleId'];

    _agoraLiveController.liveBattleEnded(liveId: liveId, battleId: battleId);
  }

  void newGiftReceivedInLiveCall(dynamic response) async {
    int liveId = response['liveCallId'];
    int giftId = response['giftId'];
    String giftUrl = response['giftUrl'];
    String giftName = response['name'];
    int giftCoins = response['coin'];
    int senderId = response['senderId'];
    String senderName = response['senderName'];

    String senderImage = response['senderImageUrl'];
    int receiverId = response['userId'];

    UserModel sentBy = UserModel();
    sentBy.id = senderId;
    sentBy.userName = senderName;
    sentBy.picture = senderImage;

    GiftModel gift =
        GiftModel(id: giftId, name: giftName, logo: giftUrl, coins: giftCoins);

    List<LiveCallHostUser> hostUsers = [];

    for (Map<String, dynamic> host in response['battleInfo']
        ['liveBattleHosts']) {
      await UsersApi.getOtherUser(
          userId: host['userId'],
          resultCallback: (user) {
            hostUsers.add(LiveCallHostUser(
                // battleId: host['battleId'],
                userDetail: user,
                totalCoins: host['totalCoin'] == null
                    ? 0
                    : int.parse(host['totalCoin'].toString()),
                totalGifts: host['totalGift'] == null
                    ? 0
                    : int.parse(host['totalGift'].toString()),
                isMainHost: host['isSuperHost'] == 1));
          });
    }

    _agoraLiveController.onGiftReceived(
        liveId: liveId, gift: gift, sentBy: sentBy, sentToUserId: receiverId);
    _agoraLiveController.liveCallHostsUpdated(
        liveId: liveId,
        hosts: hostUsers,
        battleDetail: hostUsers.isNotEmpty
            ? BattleDetail.fromJson(response['battleInfo']['battleDetail'])
            : null);
  }

  // live tv
  void onReceiveMessageInLiveTv(dynamic response) async {
    ChatMessageModel message = ChatMessageModel.fromJson(response);

    await _liveTvStreamingController.newMessageReceived(message);
  }
}
