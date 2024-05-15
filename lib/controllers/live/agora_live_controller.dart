import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../apiHandler/apis/gift_api.dart';
import '../../helper/enum_linking.dart';
import '../../helper/permission_utils.dart';
import '../../manager/socket_manager.dart';
import '../../model/call_model.dart';
import '../../model/chat_message_model.dart';
import '../../model/gift_model.dart';
import '../../model/package_model.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/ad_helper.dart';
import '../../util/constant_util.dart';
import '../misc/subscription_packages_controller.dart';

class AgoraLiveController extends GetxController {
  final SubscriptionPackageController packageController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final ScrollController scrollController = ScrollController();
  final SettingsController _settingsController = Get.find();

  Rx<TextEditingController> messageTf = TextEditingController().obs;
  RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  RxList<ReceivedGiftModel> giftsReceived = <ReceivedGiftModel>[].obs;
  Rx<ReceivedGiftModel?> populateGift = Rx<ReceivedGiftModel?>(null);

  RxInt remoteUserId = 0.obs;
  Rx<GiftModel?> sendingGift = Rx<GiftModel?>(null);

  RtcEngine? engine;

  Rx<Live?> live = Rx<Live?>(null);

  // late int liveId;
  late String localLiveId;
  bool isCompetitionLive = false;

  RxList<UserModel> currentJoinedUsers = <UserModel>[].obs;
  RxList<UserModel> allJoinedUsers = <UserModel>[].obs;

  // UserModel? host;

  RxInt canLive = 0.obs;
  RxInt startLiveStreaming = 0.obs;

  String? errorMessage;

  RxBool askLiveEndConformation = false.obs;
  RxBool askBattleEndConformation = false.obs;

  RxBool isFront = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool mutedAudio = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool videoPaused = false.obs;
  RxBool liveEnd = false.obs;

  DateTime? liveStartTime;
  DateTime? liveEndTime;

  int giftsPage = 1;
  bool canLoadMoreGifts = true;
  RxBool isLoadingGifts = false.obs;
  String channelName = '';

  RxBool messageTextFocus = false.obs;

  List<int> battleTimeArray = [30, 60, 120, 300, 600, 900, 1800, 2700, 3600];

  bool cameraInitiated = false;
  RxList<int> remoteJoinedUsers = <int>[].obs;
  RxList<int> videoPausedUsers = <int>[].obs;

  clear() {
    unregisterEventHandler();
    remoteJoinedUsers.clear();
    currentJoinedUsers.clear();
    allJoinedUsers.clear();

    engine = null;
    isFront.value = false;
    messageTextFocus.value = false;
    reConnectingRemoteView.value = false;
    mutedAudio.value = false;
    mutedVideo.value = false;
    videoPaused.value = false;
    liveEnd.value = false;
    canLive.value = 0;

    messages.clear();
    giftsReceived.clear();

    askLiveEndConformation.value = false;
    askBattleEndConformation.value = false;

    giftsPage = 1;
    canLoadMoreGifts = true;
    isLoadingGifts.value = false;
    live.value = null;
    isCompetitionLive = false;
  }

  clearGiftData() {
    giftsPage = 1;
    canLoadMoreGifts = true;
    isLoadingGifts.value = false;
    giftsReceived.clear();
  }

  String get liveTime {
    int totalSeconds = liveEndTime!.difference(liveStartTime!).inSeconds;
    int h, m, s;

    h = totalSeconds ~/ 3600;

    m = ((totalSeconds - h * 3600)) ~/ 60;

    s = totalSeconds - (h * 3600) - (m * 60);

    if (h > 0) {
      return "${h}h:${m}m:${s}s";
    } else if (m > 0) {
      return "${m}m:${s}s";
    }

    return "$s sec";
  }

  String get liveDurationLength {
    int totalSeconds = liveEndTime!.difference(liveStartTime!).inSeconds;
    int h, m, s;

    h = totalSeconds ~/ 3600;
    m = ((totalSeconds - h * 3600)) ~/ 60;
    s = totalSeconds - (h * 3600) - (m * 60);

    if (h > 0) {
      return "${h}h:${m}m:${s}s";
    } else if (m > 0) {
      return "${m}m:${s}s";
    }

    return "$s sec";
  }

  int get totalCoinsEarned {
    if (giftsReceived.isNotEmpty) {
      return giftsReceived
          .map((element) => element.giftDetail.coins)
          .reduce((a, b) => a + b);
    } else {
      return 0;
    }
  }

  checkFeasibilityToLive(
      {required bool isOpenSettings,
        required Live? battle,
        required VoidCallback successCallbackHandler}) async {
    AppUtil.checkInternet().then((value) {
      if (value) {
        PermissionUtils.requestPermission(
            [Permission.camera, Permission.microphone],
            isOpenSettings: isOpenSettings, permissionGrant: () async {
          canLive.value = 1;
          errorMessage = null;
          prepareLive(
              isCompetitionLive: isCompetitionLive,
              battle: battle,
              successCallbackHandler: successCallbackHandler);
        }, permissionDenied: () {
          canLive.value = -1;
          errorMessage = pleaseAllowAccessToCameraForLiveString.tr;
        }, permissionNotAskAgain: () {
          canLive.value = -1;
          errorMessage = pleaseAllowAccessToCameraForLiveString.tr;
        });
      } else {
        canLive.value = value == true ? 1 : -1;
        if (canLive.value == 1) {
          prepareLive(
              isCompetitionLive: isCompetitionLive,
              battle: battle,
              successCallbackHandler: successCallbackHandler);
        }
      }
    });
  }

  prepareLive(
      {required bool isCompetitionLive,
        required Live? battle,
        required VoidCallback successCallbackHandler}) {
    if (battle != null) {
      // join a battle
      Future.delayed(const Duration(seconds: 3), () {
        successCallbackHandler();
        initializeLiveBattle(battle);
      });
    } else {
      // start new live
      initializeLive(isCompetitionLive: isCompetitionLive);
    }
  }

  //Initialize All The Setup For Agora Video Call
  Future<void> initializeLive({required bool isCompetitionLive}) async {
    // clear();
    this.isCompetitionLive = isCompetitionLive;
    localLiveId = randomId();
    getIt<SocketManager>().emit(SocketConstants.goLive, {
      'userId': _userProfileManager.user.value!.id,
      'localCallId': localLiveId,
    });
  }

  Future<void> initializeLiveBattle(Live live) async {
    _joinLive(live: live);
  }

  joinAsAudience({required Live live}) async {
    this.live.value = live;

    getIt<SocketManager>().emit(SocketConstants.joinLive, {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': this.live.value!.id,
    });

    _joinLive(live: live);
    Get.to(() => const LiveBroadcastScreen());
  }

  _joinLive({required Live live}) {
    if (_settingsController.setting.value!.agoraApiKey!.isEmpty) {
      update();
      return;
    }
    this.live.value = live;
    this.live.refresh();
    sendTextMessage('Joined');
    currentJoinedUsers.add(_userProfileManager.user.value!);

    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine(live: live);
      _addAgoraEventHandlers();
      var configuration = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          orientationMode: OrientationMode.orientationModeAdaptive);
      engine?.leaveChannel();
      await engine?.setVideoEncoderConfiguration(configuration);
      await engine?.setChannelProfile(
          ChannelProfileType.channelProfileLiveBroadcasting);

      live.amIHostInLive
          ? await engine?.setClientRole(
          role: ClientRoleType.clientRoleBroadcaster)
          : await engine?.setClientRole(
          role: ClientRoleType.clientRoleAudience);

      await engine?.joinChannel(
        token: live.token,
        channelId: live.channelName,
        uid: _userProfileManager.user.value!.id,
        options: const ChannelMediaOptions(),
      );
      await engine?.enableVideo();

      if (cameraInitiated == false && live.amIHostInLive) {
        onToggleCamera();
        Future.delayed(const Duration(seconds: 2), () {
          onToggleCamera();
        });
        // onToggleCamera();
      } else {
      }

      liveStartTime = DateTime.now();
      channelName = live.channelName;
    });
  }

  //Initialize Agora RTC Engine
  Future<void> _initAgoraRtcEngine({required Live live}) async {
    engine = createAgoraRtcEngine();

    await engine?.initialize(RtcEngineContext(
      appId: _settingsController.setting.value!.agoraApiKey!,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  void unregisterEventHandler() {
    engine?.unregisterEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {},
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {},
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {},
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {},
        onConnectionStateChanged: (RtcConnection connection,
            ConnectionStateType state,
            ConnectionChangedReasonType reason) async {},
        onRemoteVideoStateChanged: (RtcConnection connection,
            int remoteUid,
            RemoteVideoState state,
            RemoteVideoStateReason reason,
            int elapsed) async {}));
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  void _addAgoraEventHandlers() {
    engine?.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
           update();
          }, onLeaveChannel: (RtcConnection connection, RtcStats status) {
      }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        remoteJoinedUsers.add(remoteUid);
        update();
      }, onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        remoteJoinedUsers.remove(remoteUid);

        update();
      }, onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      }, onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType state,
          ConnectionChangedReasonType reason) async {
        if (state == ConnectionStateType.connectionStateConnected) {
        } else if (state == ConnectionStateType.connectionStateReconnecting ||
            state == ConnectionStateType.connectionStateConnecting) {
          // reConnectingRemoteView.value = true;
        }
      }, onFirstRemoteVideoFrame: (RtcConnection connection, int remoteUid,
          int width, int height, int elapsed) {
      }, onRemoteVideoStateChanged: (RtcConnection connection,
          int remoteUid,
          RemoteVideoState state,
          RemoteVideoStateReason reason,
          int elapsed) async {
        if ((state == RemoteVideoState.remoteVideoStateFailed ||
            state == RemoteVideoState.remoteVideoStateStopped ||
            state == RemoteVideoState.remoteVideoStateFrozen) &&
            reason ==
                RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted) {
          videoPaused.value = true;
          videoPausedUsers.add(remoteUid);
        } else {
          videoPaused.value = false;
          videoPausedUsers.remove(remoteUid);
        }
      }, onLocalVideoStateChanged: (VideoSourceType source,
          LocalVideoStreamState state, LocalVideoStreamError error) {
        // print('onLocalVideoStateChanged $state');
      }, onCameraReady: () {
        // print('camera is ready now');
      }, onVideoDeviceStateChanged: (String deviceId,
          MediaDeviceType deviceType, MediaDeviceStateType deviceState) {
        // print('onVideoDeviceStateChanged $deviceState');
      }, onLocalVideoStats: (RtcConnection connection, LocalVideoStats stats) {
        // print('onLocalVideoStats $stats');
      }, onFirstLocalVideoFrame:
          (VideoSourceType source, int width, int height, int elapsed) {
        // print('onFirstLocalVideoFrame');

        cameraInitiated = true;
      }, onFirstLocalVideoFramePublished:
          (RtcConnection connection, int elapsed) {
        // print('onFirstLocalVideoFramePublished');
      }),
    );
  }

  //Use This Method To End Call
  void onCallEnd({required bool isHost}) async {
    engine?.leaveChannel();
    // engine.destroy();
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    // Emit End live Event Into Socket

    if (isHost) {
      leaveFromLiveAsHost();
      clearGiftData();
      loadGiftsReceived(liveId: live.value!.id);

      // Get.back();
    } else {
      leaveFromLiveAsAudience();
    }

    liveEndTime = DateTime.now();
    liveEnd.value = true;
  }

  closeLive() {
    Get.back();
    Timer(const Duration(seconds: 1), () {
      clear();
    });
  }

  leaveFromLiveAsHost() {
    // leave from battle
    // if (live.value?.battleDetail?.battleStatus == BattleStatus.started) {
    // getIt<SocketManager>().emit(SocketConstants.endLiveBattle, {
    //   'battleId': live.value?.battleDetail!.id,
    // });
    // }

    //end live
    getIt<SocketManager>().emit(
        SocketConstants.endLive,
        ({
          'userId': _userProfileManager.user.value!.id,
          'liveCallId': live.value?.id
        }));

    liveEndTime = DateTime.now();
    liveEnd.value = true;
    live.refresh();
  }

  leaveFromLiveAsAudience() {
    sendTextMessage('Left');
    getIt<SocketManager>().emit(
        SocketConstants.leaveLive,
        ({
          'userId': _userProfileManager.user.value!.id,
          'liveCallId': live.value?.id
        }));

    clear();
    Get.back();
    InterstitialAds().show();
  }

  sendTextMessage(String messageText) {
    // if (messageTf.value.text.removeAllWhitespace.trim().isNotEmpty) {
    String localMessageId = randomId();
    String encrtyptedMessage = messageText.encrypted();
    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': live.value!.id,
      'messageType': messageTypeId(MessageContentType.text),
      'message': encrtyptedMessage,
      'localMessageId': localMessageId,
      'picture': _userProfileManager.user.value!.picture,
      'username': _userProfileManager.user.value!.userName,
      'is_encrypted': 1,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    getIt<SocketManager>().emit(SocketConstants.sendMessageInLive, message);

    ChatMessageModel localMessageModel = ChatMessageModel();
    localMessageModel.localMessageId = localMessageId;
    localMessageModel.roomId = live.value!.id;
    // localMessageModel.messageTime = justNow;
    localMessageModel.userName = youString;
    // localMessageModel.userPicture = _userProfileManager.user.value!.picture;
    localMessageModel.senderId = _userProfileManager.user.value!.id;
    localMessageModel.messageType = messageTypeId(MessageContentType.text);
    localMessageModel.messageContent = messageText;

    localMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    messages.add(localMessageModel);
    messageTf.value.text = '';
    update();
    // }
  }

  sendGiftMessage(String giftImage, int coins) {
    String localMessageId = randomId();
    var content = {'giftImage': giftImage, 'coins': coins.toString()};
    String encrtyptedMessage = json.encode(content).encrypted();

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': live.value!.id,
      'messageType': messageTypeId(MessageContentType.gift),
      'message': encrtyptedMessage,
      'localMessageId': localMessageId,
      'picture': _userProfileManager.user.value!.picture,
      'username': _userProfileManager.user.value!.userName,
      'is_encrypted': 1,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    getIt<SocketManager>().emit(SocketConstants.sendMessageInLive, message);

    ChatMessageModel localMessageModel = ChatMessageModel();
    localMessageModel.localMessageId = localMessageId;
    localMessageModel.roomId = live.value!.id;
    // localMessageModel.messageTime = justNow;
    localMessageModel.userName = youString;
    // localMessageModel.userPicture = _userProfileManager.user.value!.picture;
    localMessageModel.senderId = _userProfileManager.user.value!.id;
    localMessageModel.messageType = messageTypeId(MessageContentType.gift);
    localMessageModel.messageContent = json.encode(content);

    localMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    messages.add(localMessageModel);
    messageTf.value.text = '';
    update();
  }

  sendGift({required GiftModel gift, LiveCallHostUser? host}) {
    if (_userProfileManager.user.value!.coins > gift.coins) {
      populateGift.value = ReceivedGiftModel(
          giftDetail: gift, sender: _userProfileManager.user.value!);

      getIt<SocketManager>().emit(SocketConstants.sendGiftLiveCall, {
        'userId': host == null
            ? live.value!.mainHostUserDetail.id
            : host.userDetail.id,
        'liveCallId': live.value!.id,
        'battleId': live.value!.battleDetail == null
            ? '0'
            : live.value!.battleDetail?.id,
        'giftId': gift.id
      });
      Timer(const Duration(seconds: 2), () {
        populateGift.value = null;
      });
    } else {
      List<PackageModel> availablePackages = packageController.packages
          .where((package) => package.coin >= gift.coins)
          .toList();
      PackageModel package = availablePackages.first;
      buyPackage(package);
    }
  }

  buyPackage(PackageModel package) {
    if (AppConfigConstants.isDemoApp) {
      AppUtil.showDemoAppConfirmationAlert(
          title: 'Demo app',
          subTitle:
          'This is demo app so you can not make payment to test it, but still you will get some coins',
          okHandler: () {
            packageController.subscribeToDummyPackage(randomId());
          });
      return;
    }
    if (packageController.isAvailable.value) {
      // For production build
      packageController.selectedPurchaseId.value = Platform.isIOS
          ? package.inAppPurchaseIdIOS
          : package.inAppPurchaseIdAndroid;
      List<ProductDetails> matchedProductArr = packageController.products
          .where((element) =>
      element.id == packageController.selectedPurchaseId.value)
          .toList();
      if (matchedProductArr.isNotEmpty) {
        ProductDetails matchedProduct = matchedProductArr.first;
        PurchaseParam purchaseParam = PurchaseParam(
            productDetails: matchedProduct, applicationUserName: null);
        packageController.inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam,
            autoConsume: packageController.kAutoConsume || Platform.isIOS);
      } else {
        AppUtil.showToast(message: noProductAvailableString, isSuccess: false);
      }
    } else {
      AppUtil.showToast(message: storeIsNotAvailableString, isSuccess: false);
    }
  }

  // *************** actions by host ***************//

  //Switch Camera
  onToggleCamera() {
    engine?.switchCamera().then((value) {
      isFront.value = !isFront.value;
    }).catchError((err) {});
  }

  //Audio On / Off
  void onToggleMuteAudio() {
    mutedAudio.value = !mutedAudio.value;
    engine?.muteLocalAudioStream(mutedAudio.value);
  }

  //Video On / Off
  void onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    engine?.muteLocalVideoStream(mutedVideo.value);
  }

  void dontEndLiveCall() {
    askLiveEndConformation.value = false;
  }

  void askConfirmationForEndCall() {
    askLiveEndConformation.value = true;
  }

  void dontEndLiveBattle() {
    askBattleEndConformation.value = false;
  }

  void askConfirmationForEndBattle() {
    askBattleEndConformation.value = true;
  }

  void liveBattleCompleted() {
    if (live.value?.battleStatus == BattleStatus.started) {
      getIt<SocketManager>().emit(SocketConstants.endLiveBattle, {
        'battleId': live.value!.battleDetail!.id,
      });
      showBattleResultAndClearData();
    }
    askBattleEndConformation.value = false;
  }

  void showBattleResultAndClearData() async {
    live.value?.battleDetail?.battleStatus = BattleStatus.completed;
    live.refresh();

    if (live.value!.battleDetail!.opponentHost.userDetail.isMe) {
      await engine?.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
  }

  void closeWinnerInfo() {
    live.value!.clearBattleData();
    live.refresh();
  }

  void messageTextFocusToggle() {
    messageTextFocus.value = !messageTextFocus.value;
  }

  //*************** updates from socket *******************//

  startLive({required BattleDetail battleDetail}) {
    Timer(const Duration(seconds: 2), () {
      live.value!.battleDetail!.battleStatus = BattleStatus.started;
      live.refresh();
    });

    getIt<SocketManager>().emit(SocketConstants.replyInvitationInLive, {
      'battleId': battleDetail.id,
      'status': 2,
    });
  }

  declineInvite(BattleDetail battleDetail) {
    getIt<SocketManager>().emit(SocketConstants.replyInvitationInLive, {
      'battleId': battleDetail.id,
      'status': 3,
    });
  }

  userAcceptedLiveBattle({
    required int liveId,
    required BattleDetail battleDetail,
    // required UserModel user
  }) {
    live.value!.invitedUserDetail = null;

    if (live.value?.id == liveId) {
      onNewUserJoined(battleDetail.opponentHost.userDetail);
      live.value!.battleDetail = battleDetail;
      live.value!.battleDetail!.battleStatus = BattleStatus.accepted;

      Timer(const Duration(seconds: 2), () {
        live.value!.battleDetail!.battleStatus = BattleStatus.started;
        live.refresh();
      });

      live.refresh();
    }
  }

  liveCallHostsUpdated(
      {required int liveId,
        required BattleDetail? battleDetail,
        required List<LiveCallHostUser> hosts}) {
    if (live.value?.id == liveId) {
      if (live.value?.battleDetail != null && hosts.isEmpty) {
        liveBattleEnded(
            liveId: live.value!.id, battleId: live.value!.battleDetail!.id);
        live.refresh();
        return;
      }
      if (hosts.isEmpty &&
          (live.value!.battleDetail?.amIMainHostInLive == false)) {
      } else {
        if (live.value!.battleDetail == null) {
          live.value!.battleDetail = battleDetail;
        }
        live.value!.battleDetail?.battleUsers = hosts;
      }

      live.refresh();
    }
  }

  liveBattleEnded({required int liveId, required int battleId}) {
    clearGiftData();
    loadGiftsReceived(liveId: live.value!.id, battleId: battleId);
    showBattleResultAndClearData();
  }

  onGiftReceived(
      {required int liveId,
        required GiftModel gift,
        required UserModel sentBy,
        required int sentToUserId}) {
    if (live.value?.id == liveId) {
      if (sentToUserId == _userProfileManager.user.value!.id) {
        populateGift.value =
            ReceivedGiftModel(giftDetail: gift, sender: sentBy);
        Timer(const Duration(seconds: 2), () {
          populateGift.value = null;
        });
      }
    }
  }

  onNewUserJoined(UserModel user) {
    currentJoinedUsers.add(user);
    if (!allJoinedUsers.contains(user)) {
      allJoinedUsers.add(user);
    }
    update();
  }

  onUserLeave({required int userId, required int liveId}) {
    if (live.value?.id == liveId) {
      currentJoinedUsers.removeWhere((element) => element.id == userId);
      update();
    }
  }

  onLiveEndMessageReceived(int liveId) {
    engine?.leaveChannel();

    WakelockPlus.disable();

    currentJoinedUsers.clear();
    messages.clear();
    if (live.value?.id == liveId) {
      liveEndTime = DateTime.now();
      liveEnd.value = true;
      live.value!.clearBattleData();
    }
    update();
  }

  onNewMessageReceived(ChatMessageModel message) {
    if (live.value?.battleDetail?.amIHostInLive == true &&
        message.messageContentType == MessageContentType.gift) {
      GiftModel gift = GiftModel(
          id: 1,
          name: '',
          logo: message.giftContent.image,
          coins: message.giftContent.coins);

      UserModel sender = UserModel();
      sender.id = message.senderId;
      sender.userName = message.userName;
      sender.picture = message.userPicture;
      ReceivedGiftModel receivedGiftDetail =
      ReceivedGiftModel(giftDetail: gift, sender: sender);

      populateGift.value = ReceivedGiftModel(giftDetail: gift, sender: sender);
      giftsReceived.add(receivedGiftDetail);

      Timer(const Duration(seconds: 2), () {
        populateGift.value = null;
      });
    }
    messages.add(message);
    update();
  }

  liveCreatedConfirmation(dynamic data) {
    if (data['localCallId'] == localLiveId) {
      int liveId = data['liveCallId'];

      String agoraToken = data['token'];
      String channelName = data['channelName'];

      Live live = Live(
          channelName: channelName,
          // isHosting: true,
          mainHostUserDetail: _userProfileManager.user.value!,
          // battleUsers: [],
          token: agoraToken,
          id: liveId);

      _joinLive(live: live);

      startLiveStreaming.value = 1;
      update();
    }
  }

  showLiveStreaming() {
    startLiveStreaming.value = 2;
    startLiveStreaming.refresh();
  }

  // gifts

  loadGiftsReceived({required int liveId, int? battleId}) {
    if (canLoadMoreGifts) {
      GiftApi.getLiveCallReceivedStickerGifts(
          page: giftsPage,
          liveId: liveId,
          battleId: battleId,
          resultCallback: (gifts, users, metadata) {
            live.value!.battleDetail?.battleUsers = users;
            giftsReceived.addAll(gifts);

            if (metadata != null) {
              canLoadMoreGifts = gifts.length >= metadata.perPage;
            }

            giftsPage += 1;
            update();
          });
    }
  }
}
