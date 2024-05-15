import 'package:foap/apiHandler/apis/live_streaming_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/live_model.dart';
import 'package:get/get.dart';
import 'package:foap/helper/list_extension.dart';

class LiveHistoryController extends GetxController {
  RxList<LiveModel> lives = <LiveModel>[].obs;

  bool isLoading = false;
  int currentPage = 1;
  bool canLoadMore = true;

  clear() {
    isLoading = false;
    currentPage = 1;
    canLoadMore = true;
  }

  getLiveHistory() {
    if (canLoadMore == true) {
      isLoading = true;

      LiveStreamingApi.getLiveHistory(
          page: currentPage,
          resultCallback: (result, metadata) {
            lives.addAll(result);
            lives.unique((e)=> e.id);

            isLoading = false;
            currentPage += 1;
            canLoadMore = result.length >= metadata.perPage;

            update();
          });
    }
  }
}
