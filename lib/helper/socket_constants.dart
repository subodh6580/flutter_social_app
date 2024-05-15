import 'package:foap/util/app_config_constants.dart';

//////******* Do not make any change in this file **********/////////

class SocketConstants {
  //Default events
  static const String eventConnect = "connect";
  static const String eventDisconnect = "disconnect";
  static const String eventConnectTimeout = "connect_timeout";
  static const String onSocketError = "onSocketError";

  //Video Call  events
  static const String connectCall = "connectCall";

  // callType:   1=audio,2=video
  static const String callCreate = "callCreate";
  static const String onCallRequestConfirm = "callCreateConfirm";
  static const String incomingCall = "callIncoming";

  // ringing =1, rejected=2, not_answer =3,picked=4, completed=5'
  static const String onAcceptCall = "performActionOnCall";
  static const String onRejectCall = "performActionOnCall";
  static const String onNotAnswered = "performActionOnCall";
  static const String onCompleteCall = "performActionOnCall";

  static const String onCallStatusUpdated = "callStatusUpdate";

  // chat
  static const String login = "login";
  static const String addUserInChatRoom = "addUser";
  static const String sendMessage = "sendMessage";
  static const String typing = "typing";
  static const String readMessage = "readMessage";
  static const String updateMessageStatus = "updateMessageCurrentStatus";
  static const String onlineStatusEvent = "userOnline";
  static const String offlineStatusEvent = "userOffline";
  static const String deleteMessage = "deleteMessage";

  // group chat
  static const String leaveGroupChat = "leftRoom";
  static const String removeUserFromGroupChat = "removeUserFromRoom";
  static const String makeUserAdmin = "makeRoomAdmin";
  static const String removeUserAdmin = "removeRoomAdmin";
  static const String updateChatAccessGroup = "updateChatAccessGroup";

  // live
  static const String goLive = "goLive";
  static const String liveCreatedConfirmation = "goLiveConfirm";
  static const String joinLive = "addUserLiveCall";
  static const String sendMessageInLive = "sendMessageLiveCall";
  static const String endLive = "endLiveCall";
  static const String leaveLive = "leaveUserLiveCall";
  static const String inviteInLive = "inviteUserInLiveBattle";
  static const String invitedInLive = "newliveBattleInvitation";

  static const String replyInvitationInLive = "replyLiveBattleInvitation";
  static const String inviteInLiveConfirmation =
      "inviteUserInLiveBattleConfirm";
  static const String liveBattleStatusUpdated = "liveBattleInvitationUpated";
  static const String liveBattleHostUpdated = "liveBattleHostUpdated";
  static const String endLiveBattle = "endLiveBattle";

  static const String sendGiftLiveCall = "sendGiftLiveCall";
  static const String newGiftReceivedInLiveCall = "newGiftReceivedliveCall";

  // livetv
  static const String joinLiveTv = "addUserLiveTv";
  static const String sendMessageInLiveTv = "sendMessageLiveTv";

//Message types
// Text - 1
// Image - 2
// Video - 3
// Gif - 4
// Sticker - 5
// Contact - 6
// Location - 7
// Reply - 8
// Forward - 9
}

class ApiConstants {
  static const String transportsHeader = 'transports';
  static const String webSocketOption = 'websocket';
  static const String pollingOption = 'polling';
  static const String socketUrl = AppConfigConstants.socketApiBaseUrl;
}

class AppConstants {
  static const String mobileConnectionStatus = "ConnectivityResult.mobile";
  static const String wifiConnectionStatus = "ConnectivityResult.wifi";
// static const String agoraAppId = "<Your Agora APP Id>";
}

class CallArgParams {
  static const String senderId = "userId";
  static const String receiverId = "recieverId";
  static const String callType = "callType";
  static const String localCallId = "localCallId";
  static const String status = "status";
  static const String channelName = "channelName";
}
