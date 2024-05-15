import '../../helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/live_model.dart';
import '../api_wrapper.dart';


class LiveStreamingApi {
  static getAllLiveUsers(
      {String? name,
      String? profileCategoryType,
      bool? isFollowing,
      required Function(List<UserLiveCallDetail>) resultCallback}) {
    var url =
        '${NetworkConstantsUtil.liveUsers}?expand=userdetails&name=&profile_category_type=&is_following=';

    EasyLoading.show(status: loadingString.tr);
    ApiWrapper().getApi(url: url).then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        final liverStreamUser = result!.data['liveStreamUser']['items'];
        // model.totalLiveUsers = int.parse(data['total_live_users'] ?? '0');
        resultCallback(
            List<UserLiveCallDetail>.from(liverStreamUser.map((user) {
          final item = UserLiveCallDetail.fromJson(user);
          return item;
        })));
      }
    });
  }

  static getCurrentLiveUsers(
      {required Function(List<UserModel>) resultCallback}) async {
    UserProfileManager userProfileManager = Get.find();
    var url =
        '${NetworkConstantsUtil.currentLiveUsers}${userProfileManager.user.value!.id}';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = (result!.data['following'] as List<dynamic>)
            .map((e) => e['followingUserDetail'])
            .toList();
        if (items.isNotEmpty) {
          resultCallback(
              List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));
        }
      }
    });
  }

  // static getRandomLiveUsers(
  //     {required Function(List<UserModel>, APIMetaData) resultCallback}) async {
  //   var url = NetworkConstantsUtil.randomLives;
  //
  //   ApiWrapper().getApi(url: url).then((result) {
  //     if (result?.success == true) {
  //       var items = result!.data['user']['items'];
  //
  //       resultCallback(
  //           List<UserModel>.from(items.map((x) => UserModel.fromJson(x))),
  //           APIMetaData.fromJson(result.data['user']['_meta']));
  //     }
  //   });
  // }

  static getLiveHistory(
      {required int page,
      required Function(List<LiveModel>, APIMetaData) resultCallback}) async {
    var url = '${NetworkConstantsUtil.liveHistory}&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['live_history']['items'];
        resultCallback(
            List<LiveModel>.from(items.map((x) => LiveModel.fromJson(x))),
            APIMetaData.fromJson(result.data['live_history']['_meta']));
      }
    });
  }
}
