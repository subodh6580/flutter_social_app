import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../model/post_model.dart';

class SavedPostController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  DataWrapper postDataWrapper = DataWrapper();

  clear() {
    postDataWrapper = DataWrapper();
    posts.value = [];
    update();
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint("Hello222");
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
        isSaved: 1,
        page: postDataWrapper.page,
        resultCallback: (result, metadata) {
          posts.addAll(result);
          posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
          posts.unique((e) => e.id);
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
