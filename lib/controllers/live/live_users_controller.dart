import 'package:foap/apiHandler/apis/live_streaming_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';

class LiveUserController extends GetxController {
  RxList<UserLiveCallDetail> liveStreamUser = <UserLiveCallDetail>[].obs;
  RxInt totalLiveUsers = 0.obs;

  // fetch live users
  void getLiveUsers() async {
    LiveStreamingApi.getAllLiveUsers(resultCallback: (result) {
      liveStreamUser.addAll(result);
      liveStreamUser.unique((e)=> e.id);

    });
  }
}
