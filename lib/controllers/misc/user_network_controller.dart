import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/users_api.dart';
import 'package:foap/helper/list_extension.dart';

class UserNetworkController extends GetxController {
  RxList<UserModel> followers = <UserModel>[].obs;
  RxList<UserModel> following = <UserModel>[].obs;

  RxBool isLoading = true.obs;

  int page = 1;
  bool canLoadMore = true;

  clear() {
    page = 1;
    canLoadMore = true;
    isLoading.value = false;

    following.value = [];
    followers.value = [];
  }

  getFollowers(int userId) {
    if (canLoadMore) {
      isLoading.value = true;

      UsersApi.getFollowerUsers(
          userId: userId,
          page: page,
          resultCallback: (result, metadata) {
            isLoading.value = false;
            followers.addAll(result);
            followers.unique((e)=> e.id);

            page += 1;
            canLoadMore =  result.length >= metadata.perPage;

            update();
          });
    }
  }

  getFollowingUsers(int userId) {
    if (canLoadMore) {
      isLoading.value = true;

      UsersApi.getFollowingUsers(
          page: page,
          userId: userId,
          resultCallback: (result, metadata) {
            isLoading.value = false;
            following.addAll(result);
            following.unique((e)=> e.id);

            page += 1;
            canLoadMore = result.length >= metadata.perPage;

            update();
          });
    }
  }

  followUser(UserModel user) {
    user.followingStatus =
    user.isPrivate ? FollowingStatus.requested : FollowingStatus.following;

    if (following.where((e) => e.id == user.id).isNotEmpty) {
      following[following.indexWhere((element) => element.id == user.id)] =
          user;
    }
    if (followers.where((e) => e.id == user.id).isNotEmpty) {
      followers[followers.indexWhere((element) => element.id == user.id)] =
          user;
    }
    update();
    UsersApi.followUnfollowUser(isFollowing: true, userId: user.id)
        .then((value) {
      update();
    });
  }

  unFollowUser(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;
    if (following.where((e) => e.id == user.id).isNotEmpty) {
      UserModel matchedUser =
          following.where((element) => element.id == user.id).first;
      matchedUser.followingStatus = FollowingStatus.notFollowing;
    }
    if (followers.where((e) => e.id == user.id).isNotEmpty) {
      UserModel matchedUser =
          followers.where((element) => element.id == user.id).first;
      matchedUser.followingStatus = FollowingStatus.notFollowing;
    }
    update();
    UsersApi.followUnfollowUser(isFollowing: false, userId: user.id)
        .then((value) {
      update();
    });
  }
}
