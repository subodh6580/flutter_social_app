import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../helper/permission_utils.dart';
import '../../model/call_history_model.dart';
import '../../model/call_model.dart';
import 'agora_call_controller.dart';

class CallHistoryController extends GetxController {
  RxList<CallHistoryModel> calls = <CallHistoryModel>[].obs;
  final AgoraCallController agoraCallController = Get.find();

  int callHistoryPage = 1;
  bool canLoadMoreCalls = true;
  bool isLoading = false;

  clear() {
    isLoading = false;
    calls.value = [];
    callHistoryPage = 1;
    canLoadMoreCalls = true;
  }

  callHistory() {
    if (canLoadMoreCalls) {
      isLoading = true;

      ChatApi.getCallHistory(
          page: callHistoryPage,
          resultCallback: (result, metadata) {

            calls.addAll(result);
            calls.unique((e)=> e.id);
            isLoading = false;

            callHistoryPage += 1;
            canLoadMoreCalls = result.length >= metadata.perPage;


            update();
          });
    }
  }

  void reInitiateCall({required CallHistoryModel call}) {
    if (call.callType == 1) {
      initiateAudioCall(opponent: call.opponent);
    } else {
      initiateVideoCall(opponent: call.opponent);
    }
  }

  void initiateVideoCall({required UserModel opponent}) {
    PermissionUtils.requestPermission(
        [Permission.camera, Permission.microphone],
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 2,
          opponent: opponent);

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

  void initiateAudioCall({required UserModel opponent}) {
    PermissionUtils.requestPermission([Permission.microphone],
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 1,
          opponent: opponent);

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
