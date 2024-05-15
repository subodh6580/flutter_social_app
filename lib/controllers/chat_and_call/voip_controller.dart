import 'package:flutter_callkit_incoming/entities/call_event.dart'
    as call_event;
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart'
    as callkit;
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/call_model.dart';
import 'agora_call_controller.dart';

class CallData {
  String uuid;
  int id;
  String callerName;
  int callerId;
  String callerImage;
  String channelName;
  String token;
  int type;

  CallData({
    required this.uuid,
    required this.id,
    required this.callerName,
    required this.callerId,
    required this.callerImage,
    required this.channelName,
    required this.token,
    required this.type,
  });

  factory CallData.fromJson(Map<String, dynamic> json) => CallData(
        uuid: json["id"],
        callerName: json["nameCaller"],
        type: json["type"],
        id: json["extra"]["id"],
        callerId: json["extra"]["callerId"],
        callerImage: json["extra"]["callerImage"],
        channelName: json["extra"]["channelName"],
        token: json["extra"]["token"],
      );
}

class VoipController {
  final AgoraCallController agoraCallController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  endCall(Call call) {
    callkit.FlutterCallkitIncoming.endCall(call.uuid);
  }

  listenerSetup() {
    callkit.FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case call_event.Event.actionCallIncoming:
          break;
        case call_event.Event.actionCallStart:
          break;
        case call_event.Event.actionCallAccept:
          Future.delayed(const Duration(seconds: 1), () {
            CallData callData = CallData.fromJson(event.body);

            UserModel opponent = UserModel();
            opponent.id = callData.callerId;
            opponent.userName = callData.callerName;
            opponent.picture = callData.callerImage;

            Call call = Call(
                uuid: callData.uuid,
                callId: callData.id,
                channelName: callData.channelName,
                isOutGoing: false,
                token: callData.token,
                callType: callData.type == 0 ? 1 : 2,
                opponent: opponent);
            agoraCallController.initiateAcceptCall(call: call);
          });

          break;
        case call_event.Event.actionCallDecline:
          Call call = Call(
              uuid: event.body['id'],
              channelName: '',
              isOutGoing: false,
              opponent: UserModel(),
              token: '',
              callType: 0,
              callId: 0);
          //endCall(call);
          agoraCallController.declineCall(call: call);
          break;
        case call_event.Event.actionCallEnded:
          Call call = Call(
              uuid: event.body['id'],
              channelName: '',
              isOutGoing: false,
              opponent: UserModel(),
              token: '',
              callType: 0,
              callId: 0);
          // var params = <String, dynamic>{'id': event.body['id']};
          callkit.FlutterCallkitIncoming.endCall(event.body['id']);
          agoraCallController.receivedEndCallNotification(call);
          break;
        case call_event.Event.actionCallTimeout:
          Call call = Call(
              uuid: event.body['id'],
              channelName: '',
              isOutGoing: false,
              opponent: UserModel(),
              token: '',
              callType: 0,
              callId: 0);
          // CallData callData = CallData.fromJson(event.body);
          // if (callData.callerId != _userProfileManager.user.value?.id &&
          //     _userProfileManager.user.value?.id != null) {
          // Call call = Call(
          //     uuid: callData.uuid,
          //     channelName: callData.channelName,
          //     isOutGoing: false,
          //     opponent: UserModel(),
          //     token: callData.token,
          //     callType: callData.type == 0 ? 1 : 2,
          //     callId: callData.id);
          // var params = <String, dynamic>{'id': event.body['id']};
          callkit.FlutterCallkitIncoming.endCall(event.body['id']);
          agoraCallController.declineCall(call: call);
          // }

          break;
        case call_event.Event.actionCallCallback:
          break;
        case call_event.Event.actionCallToggleHold:
          // TODO: only iOS
          break;
        case call_event.Event.actionCallToggleMute:
          // TODO: only iOS
          break;
        case call_event.Event.actionCallToggleDmtf:
          // TODO: only iOS
          break;
        case call_event.Event.actionCallToggleGroup:
          // TODO: only iOS
          break;
        case call_event.Event.actionCallToggleAudioSession:
          // TODO: only iOS
          break;
        // case call_event.Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
        //   // TODO: only iOS
        //   break;
        default:
          break;
      }
    });
  }

  outGoingCall(Call call) async {
    CallKitParams params = CallKitParams(
        id: call.uuid,
        nameCaller: call.opponent.userName,
        handle: call.channelName,
        type: call.callType == 1 ? 0 : 1,
        extra: <String, dynamic>{
          'id': call.callId,
          'callerId': _userProfileManager.user.value!.id,
          'callerImage': _userProfileManager.user.value!.picture,
          'channelName': call.channelName,
          'token': call.token
        },
        ios: const IOSParams(handleType: 'generic'));

    await callkit.FlutterCallkitIncoming.startCall(params);
  }

  missCall(Call call) async {
    CallKitParams params = CallKitParams(
        id: call.uuid,
        nameCaller: call.opponent.userName,
        handle: call.channelName,
        type: call.callType == 1 ? 0 : 1,
        extra: <String, dynamic>{
          'id': call.callId,
          'callerId': _userProfileManager.user.value!.id,
          'callerImage': _userProfileManager.user.value!.picture,
          'channelName': call.channelName,
          'token': call.token
        },
        ios: const IOSParams(handleType: 'generic'));

    await callkit.FlutterCallkitIncoming.showMissCallNotification(params);
  }

  endAllCalls() async {
    await callkit.FlutterCallkitIncoming.endAllCalls();
  }
}
