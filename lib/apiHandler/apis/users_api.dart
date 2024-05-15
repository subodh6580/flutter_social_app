
import 'package:foap/apiHandler/api_wrapper.dart';
import '../../helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/search_model.dart';

class UsersApi {
  static getSuggestedUsers(
      {required int page, required Function(List<UserModel>) resultCallback}) {
    var url = '${NetworkConstantsUtil.getSuggestedUsers}&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var topUsers = result!.data['topUser'];

        resultCallback(
          List<UserModel>.from(topUsers.map((x) => UserModel.fromJson(x))),
        );
      }
    });
  }

  static searchUsers(
      {required UserSearchModel searchModel,
        required int page,
        required Function(List<UserModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.findFriends;
    //searchFrom  ----- 1=username,2=email,3=phone
    String searchFromValue = searchModel.searchFrom == null
        ? ''
        : searchModel.searchFrom == SearchFrom.username
        ? '1'
        : searchModel.searchFrom == SearchFrom.email
        ? '2'
        : '3';
    url =
    '${url}searchText=${searchModel.searchText ?? ''}&searchFrom=$searchFromValue&isExactMatch=${searchModel.isExactMatch ?? ''}&is_chat_user_online=${searchModel.isOnline == 1 ? '1' : ''}&page=$page';
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var topUsers = result!.data['user']['items'];
        resultCallback(
            List<UserModel>.from(topUsers.map((x) => UserModel.fromJson(x))),
            APIMetaData.fromJson(result.data['user']['_meta']));
      }
    });
  }

  static Future<void> getOtherUser(
      {required int userId,
      required Function(UserModel) resultCallback}) async {
    var url = NetworkConstantsUtil.otherUser;
    url = url.replaceFirst('{{id}}', userId.toString());

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        resultCallback(UserModel.fromJson(result!.data['user']));
        return;
      }
    });
  }

  static otherUserProfileView({required int refId, required int sourceType}) {
    var url = NetworkConstantsUtil.userView;

    ApiWrapper().postApi(url: url, param: {
      'reference_id': refId.toString(),
      'source_type': sourceType.toString()
    });
  }

  static Future<void> followUnfollowUser(
      {required bool isFollowing, required int userId}) async {
    var url = (isFollowing
        ? NetworkConstantsUtil.followUser
        : NetworkConstantsUtil.unfollowUser);

    await ApiWrapper().postApi(url: url, param: {
      "user_id": userId.toString(),
    }).then((result) {
      if (result?.success == true) {
        return;
      }
    });
  }

  static Future<void> followMultipleUsers({required String userIds}) async {
    var url = NetworkConstantsUtil.followMultipleUser;

    await ApiWrapper().postApi(url: url, param: {
      "user_ids": userIds,
    }).then((result) {
      if (result?.success == true) {
        return;
      }
    });
  }

  static Future<void> reportUser(
      {required int userId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.reportUser;
    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper().postApi(
        url: url,
        param: {"report_to_user_id": userId.toString()}).then((result) {
      EasyLoading.dismiss();

      if (result?.success == true) {
        resultCallback();
        return;
      }
    });
  }

  static Future<void> blockUser(
      {required int userId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.blockUser;
    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper().postApi(
        url: url, param: {"blocked_user_id": userId.toString()}).then((result) {
      EasyLoading.dismiss();

      if (result?.success == true) {
        resultCallback();
        return;
      }
    });
  }

  static Future<void> unBlockUser(
      {required int userId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.unBlockUser;
    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper().postApi(
        url: url, param: {"blocked_user_id": userId.toString()}).then((result) {
      EasyLoading.dismiss();

      if (result?.success == true) {
        resultCallback();
        return;
      }
    });
  }

  static getBlockedUsers(
      {required int page,
      required Function(List<UserModel>, APIMetaData) resultCallback}) {
    var url = '${NetworkConstantsUtil.blockedUsers}&page=$page';

    EasyLoading.show(status: loadingString.tr);
    ApiWrapper().getApi(url: url).then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        var blockedUser = result!.data['blockedUser']['items'];

        var items = (blockedUser as List<dynamic>)
            .where((element) => element['blockedUserDetail'] != null)
            .map((e) => e['blockedUserDetail'])
            .toList();

        // resultCallback(
        //     List<UserModel>.from(items.map((x) => UserModel.fromJson(x))),
        //     APIMetaData.fromJson(result.data['blockedUser']['_meta']));

        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))),
            APIMetaData.fromJson(result.data['blockedUser']['_meta']));
      }
    });
  }

  static getFollowerUsers(
      {required int? userId,
      int page = 1,
      required Function(List<UserModel>, APIMetaData) resultCallback}) async {
    final UserProfileManager userProfileManager = Get.find();

    var url =
        '${NetworkConstantsUtil.followers}${userId ?? userProfileManager.user.value!.id}&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = (result!.data['follower']['items'] as List<dynamic>)
            .map((e) => e['followerUserDetail'])
            .toList();
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))),
            APIMetaData.fromJson(result.data['follower']['_meta']));
      }
    });
  }

  static getFollowingUsers(
      {int? userId,
      int page = 1,
      required Function(List<UserModel>, APIMetaData) resultCallback}) async {
    final UserProfileManager userProfileManager = Get.find();

    var url =
        '${NetworkConstantsUtil.following}${userId ?? userProfileManager.user.value!.id}&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = (result!.data['following']['items'] as List<dynamic>)
            .map((e) => e['followingUserDetail'])
            .toList();
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))),
            APIMetaData.fromJson(result.data['following']['_meta']));
      }
    });
  }
}
