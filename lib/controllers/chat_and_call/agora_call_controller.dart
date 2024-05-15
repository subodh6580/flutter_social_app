import 'dart:io';
import 'package:foap/controllers/chat_and_call/voip_controller.dart';
import 'package:foap/helper/imports/call_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/dashboard_imports.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../helper/permission_utils.dart';
import '../../main.dart';
import '../../manager/socket_manager.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/ad_helper.dart';
import '../../util/constant_util.dart';
import '../../util/shared_prefs.dart';


class AgoraCallController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxInt remoteUserId = 0.obs;

  RtcEngine? engine;

  RxBool isFront = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool videoPaused = false.obs;

  RxBool mutedAudio = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool switchMainView = false.obs;
  RxBool remoteJoined = false.obs;
  final SettingsController _settingsController = Get.find();

  // int callId = 0;
  final player = AudioPlayer();

  late String localCallId;
  UserModel? opponent;

  //Initialize All The Setup For Agora Video Call

  setIncomingCallId(int id) {
    // callId = id;
  }

  clear() {
    isFront.value = false;
    reConnectingRemoteView.value = false;
    videoPaused.value = false;

    mutedAudio.value = false;
    mutedVideo.value = false;
    switchMainView.value = false;
    remoteJoined.value = false;
  }

  makeCallRequest({required Call call}) async {
    opponent = call.opponent;
    localCallId = randomId();

    getIt<SocketManager>().emit(
        SocketConstants.callCreate,
        ({
          CallArgParams.senderId: _userProfileManager.user.value!.id,
          CallArgParams.receiverId: call.opponent.id,
          CallArgParams.callType: call.callType,
          CallArgParams.localCallId: localCallId,
          // CallArgParams.channelName: channelName
        }));
  }

  Future<void> initializeCalling({
    required Call call,
  }) async {
    // logFile.writeAsStringSync('initializeCalling \n', mode: FileMode.append);

    if (_settingsController.setting.value!.agoraApiKey!.isEmpty) {
      // logFile.writeAsStringSync('initializeCalling agora key empty\n', mode: FileMode.append);
      update();
      return;
    }

    // logFile.writeAsStringSync('initializeCalling  agora key found1\n', mode: FileMode.append);

    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine(
          callType:
          call.callType == 1 ? AgoraCallType.audio : AgoraCallType.video);
      _addAgoraEventHandlers();
      var configuration = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          orientationMode: OrientationMode.orientationModeAdaptive);

      await engine!.setVideoEncoderConfiguration(configuration);
      await engine!.leaveChannel();

      await engine!.joinChannel(
        token: call.token,
        channelId: call.channelName,
        uid: _userProfileManager.user.value!.id,
        options: const ChannelMediaOptions(),
      );

      if (call.callType == 1) {
        // logFile.writeAsStringSync('AudioCallingScreen\n',
        //     mode: FileMode.append);

        Get.to(() => AudioCallingScreen(call: call));
      } else {
        Get.to(() => VideoCallingScreen(call: call));
      }
      update();
    });
  }

  //Initialize Agora RTC Engine
  Future<void> _initAgoraRtcEngine({required AgoraCallType callType}) async {
    // _engine = await RtcEngine.create(_settingsController.setting.value!.agoraApiKey!);

    engine = createAgoraRtcEngine();

    await engine!.initialize(RtcEngineContext(
      appId: _settingsController.setting.value!.agoraApiKey!,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    if (callType == AgoraCallType.video) {
      await engine!.enableVideo();
      await engine!.startPreview();
    }
  }

  //Switch Camera
  onToggleCamera() {
    engine!.switchCamera().then((value) {
      isFront.value = !isFront.value;
    }).catchError((err) {});
  }

  void toggleMainView() {
    switchMainView.value = !switchMainView.value;
    update();
  }

  //Audio On / Off
  void onToggleMuteAudio() {
    mutedAudio.value = !mutedAudio.value;
    engine!.muteLocalAudioStream(mutedAudio.value);
  }

  //Video On / Off
  void onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    engine!.muteLocalVideoStream(mutedVideo.value);
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  void _addAgoraEventHandlers() {
    engine!.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("local user ${connection.localUid} joined");
          }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("remote user $remoteUid joined");
        remoteJoined.value = true;
        remoteUserId.value = remoteUid;
        update();
      }, onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        // if (elapsed == UserOfflineReason.Dropped) {
        //   Wakelock.disable();
        // } else {
        // final info = 'userOffline: $uid';
        remoteUserId.value = 0;
        update();
        // _timerKey.currentState?.cancelTimer();
        // }
      }, onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      }, onConnectionStateChanged: (RtcConnection connection,
          ConnectionStateType state,
          ConnectionChangedReasonType reason) async {
        if (state == ConnectionStateType.connectionStateConnected) {
          reConnectingRemoteView.value = false;
        } else if (state == ConnectionStateType.connectionStateReconnecting) {
          reConnectingRemoteView.value = true;
        }
      }, onRemoteVideoStateChanged: (RtcConnection connection,
          int remoteUid,
          RemoteVideoState state,
          RemoteVideoStateReason reason,
          int elapsed) async {
        // if (state == RemoteVideoState.remoteVideoStateFailed ||
        //     state == RemoteVideoState.remoteVideoStateStopped ||
        //     state == RemoteVideoState.remoteVideoStateFrozen) {
        //   videoPaused.value = true;
        // } else {
        //   videoPaused.value = false;
        // }
      }),
    );
  }

  // call

  callStatusUpdateReceived(Map<String, dynamic> updatedData) {
    int status = updatedData['status'];

    // callId = 0;
    Call call = Call(
        uuid: updatedData['uuid'],
        channelName: '',
        isOutGoing: false,
        opponent: UserModel(),
        token: '',
        callType: 0,
        callId: updatedData['id']);

    if (status == 5 || status == 2) {
      if (Platform.isIOS) {
        getIt<VoipController>().endCall(call);
      }
      receivedEndCallNotification(call);
    } else if (status == 4) {
      player.stop();
    }
  }

  outgoingCallConfirmationReceived(Map<String, dynamic> updatedData) async {
    String uuid = updatedData['uuid'];
    int id = updatedData['id'];
    String localCallId = updatedData['localCallId'];
    var agoraToken = updatedData['token'];
    var channelName = updatedData['channelName'];
    int callType = updatedData['callType'];

    Call call = Call(
        uuid: uuid,
        channelName: channelName!,
        isOutGoing: true,
        opponent: opponent!,
        token: agoraToken!,
        callType: callType,
        callId: id);

    if (this.localCallId == localCallId) {
      // callId = id;
      initializeCalling(call: call);
      if (Platform.isIOS) {
        getIt<VoipController>().outGoingCall(call);
      }
      await player.setAsset('assets/ringtone.mp3');
      player.play();
    }
  }

  incomingCallReceived(Map<String, dynamic> updatedData) {
    // int id = updatedData['id'];
    int callType = updatedData['callType'];
    String userImage = updatedData['userImage'];
    String username = updatedData['username'];
    int callerId = updatedData['callerId'];
    // String channelName = updatedData['channelName'];
    // String agoraToken = updatedData['token'];

    // callId = id;

    UserModel opponent = UserModel();
    opponent.id = callerId;
    opponent.userName = username;
    opponent.picture = userImage;

    if (callType == 1) {
      // audio call
      // Get.to(() =>
      //     AudioCallingScreen(
      //         opponent: opponent,
      //         channelName: channelName,
      //         token: agoraToken,
      //         isOutGoing: false //widget.isForOutGoing,
      //     ));
    } else {
      // video call
      // Call call = Call(
      //     callId: id,
      //     channelName: channelName,
      //     isOutGoing: false,
      //     opponent: opponent,
      //     callType: callType,
      //     token: agoraToken);
      // Get.to(() => VideoCallingScreen(
      //       call: call,
      //     ));
    }
  }

  void acceptCall({required Call call}) {
    // logFile.writeAsStringSync('permissionGranted acceptCall 1\n', mode: FileMode.append);
    getIt<SocketManager>().emit(SocketConstants.onAcceptCall, {
      'uuid': call.uuid,
      'userId': _userProfileManager.user.value!.id,
      'status': 4,
    });

    //Todo: this need to be checked
    remoteUserId.value = call.opponent.id;
    remoteJoined.value = true;
    initializeCalling(
      call: call,
    );
    player.stop();
  }

  void initiateAcceptCall({required Call call}) async {
    askForPermissionsForCall(call: call);
  }

  askForPermissionsForCall({required Call call}) {
    // logFile.writeAsStringSync('askForPermissionsForCall 1\n', mode: FileMode.append);
    PermissionUtils.requestPermission(
        call.callType == 1
            ? [Permission.microphone]
            : [Permission.camera, Permission.microphone],
        isOpenSettings: false, permissionGrant: () async {
      // logFile.writeAsStringSync('permissionGranted 1\n', mode: FileMode.append);
      acceptCall(call: call);
    }, permissionDenied: () {
      declineCall(call: call);
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      declineCall(call: call);
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false);
    });
  }

  //Use This Method To End Call
  void receivedEndCallNotification(Call call) async {
    player.stop();
    if (remoteJoined.value == true) {
      engine?.leaveChannel();
      // engine?.destroy();

      clear();
    }
    // callId = 0;
    remoteJoined.value = false;
    Get.back();

    InterstitialAds().show();

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }
    SharedPrefs().setCallNotificationData(null);
  }

  void onCallEnd(Call call) async {
    player.stop();

    if (remoteJoined.value == true) {
      if (Platform.isAndroid) {
        receivedEndCallNotification(call);
        Get.back();
      }
      getIt<SocketManager>().emit(SocketConstants.onCompleteCall, {
        'uuid': call.uuid,
        'userId': _userProfileManager.user.value!.id,
        'status': 5,
        // 'channelName': call.channelName
      });
    } else {
      if (Platform.isAndroid) {
        receivedEndCallNotification(call);
        Get.back();
      }
      getIt<SocketManager>().emit(SocketConstants.onRejectCall, {
        'uuid': call.uuid,
        'userId': _userProfileManager.user.value!.id,
        'status': 2
      });
    }
    if (Platform.isIOS) {
      getIt<VoipController>().endCall(call);
    }

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }
    SharedPrefs().setCallNotificationData(null);
  }

  void declineCall({required Call call}) async {
    getIt<SocketManager>().emit(SocketConstants.onRejectCall, {
      'uuid': call.uuid,
      'userId': _userProfileManager.user.value!.id,
      'status': 2
    });
    if (Platform.isIOS) {
      getIt<VoipController>().endCall(call);
    }
    // callId = 0;
    remoteJoined.value = false;
    Get.back();

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }
    SharedPrefs().setCallNotificationData(null);
  }

  void timeOutCall(Call call) async {
    getIt<SocketManager>().emit(SocketConstants.onNotAnswered, {
      'uuid': call.uuid,
      'userId': _userProfileManager.user.value!.id,
      'status': 3
    });
    if (Platform.isIOS) {
      getIt<VoipController>().endCall(call);
    }
    // callId = 0;
    remoteJoined.value = false;
    Get.back();
  }
}
