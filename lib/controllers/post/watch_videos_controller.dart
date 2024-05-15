import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../model/post_model.dart';

class WatchVideosController extends GetxController {
  RxList<PostModel> videos = <PostModel>[].obs;
  DataWrapper postDataWrapper = DataWrapper();

  clear() {
    postDataWrapper = DataWrapper();
    videos.value = [];
    update();
  }

  @override
  void onInit() {
    super.onInit();
    refreshData(() {});
  }

  refreshData(VoidCallback callback) {
    clear();
    getPosts(callback);
  }

  loadMore(VoidCallback callback) {
    if (postDataWrapper.haveMoreData.value == true) {
      getPosts(callback);
    } else {
      callback();
    }
  }

  void getPosts(VoidCallback callback) async {
    postDataWrapper.isLoading.value = true;
    PostApi.getPosts(
        isVideo: 1,
        page: postDataWrapper.page,
        resultCallback: (result, metadata) {
          videos.addAll(result);
          videos.sort((a, b) => b.createDate!.compareTo(a.createDate!));
          videos.unique((e) => e.id);
          postDataWrapper.isLoading.value = false;

          postDataWrapper.totalRecords.value = metadata.totalCount;
          postDataWrapper.haveMoreData.value =
              metadata.pageCount >= metadata.currentPage;

          postDataWrapper.page += 1;

          callback();
          update();
        });
  }
}
