import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/users_api.dart';
import 'package:foap/helper/list_extension.dart';

import '../../model/search_model.dart';

class UsersController extends GetxController {
  RxList<UserModel> searchedUsers = <UserModel>[].obs;
  int accountsPage = 1;
  bool canLoadMoreAccounts = true;
  RxBool accountsIsLoading = false.obs;
  String searchText = '';

  UserSearchModel searchModel = UserSearchModel();

  clear() {
    searchModel = UserSearchModel();
    clearPagingInfo();
    searchText = '';
  }

  setIsOnlineFilter() {
    searchModel.isOnline = 1;
    loadUsers(() {});
  }

  setSearchFromParam(SearchFrom source) {
    searchModel.searchFrom = source;
    loadUsers(() {});
  }

  setIsExactMatchFilter() {
    searchModel.isExactMatch = 1;
    loadUsers(() {});
  }

  setSearchTextFilter(String text, VoidCallback callback) {
    if (text != searchText) {
      searchText = text;
      searchModel.searchText = text;

      clearPagingInfo();
      loadUsers(callback);
    }
  }

  clearPagingInfo() {
    searchedUsers.clear();
    accountsPage = 1;
    canLoadMoreAccounts = true;
    accountsIsLoading.value = false;
  }

  loadUsers(VoidCallback callback) {
    if (canLoadMoreAccounts) {
      accountsIsLoading.value = true;

      UsersApi.searchUsers(
          searchModel: searchModel,
          page: accountsPage,
          resultCallback: (result, metadata) {
            accountsIsLoading.value = false;
            searchedUsers.addAll(result);
            searchedUsers.unique((e) => e.id);

            canLoadMoreAccounts = result.length >= metadata.perPage;
            accountsPage += 1;
            callback();

            update();
          });
    } else {
      callback();
    }
  }

  followUser(UserModel user) {
    user.followingStatus =
    user.isPrivate ? FollowingStatus.requested : FollowingStatus.following;
    if (searchedUsers.where((e) => e.id == user.id).isNotEmpty) {
      searchedUsers[
      searchedUsers.indexWhere((element) => element.id == user.id)] = user;
    }
    // if (suggestedUsers.where((e) => e.id == user.id).isNotEmpty) {
    //   suggestedUsers[
    //   suggestedUsers.indexWhere((element) => element.id == user.id)] = user;
    // }
    update();

    UsersApi.followUnfollowUser(isFollowing: true, userId: user.id);
  }

  unFollowUser(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;
    if (searchedUsers.where((e) => e.id == user.id).isNotEmpty) {
      searchedUsers[
      searchedUsers.indexWhere((element) => element.id == user.id)] = user;
    }
    // if (suggestedUsers.where((e) => e.id == user.id).isNotEmpty) {
    //   suggestedUsers[
    //   suggestedUsers.indexWhere((element) => element.id == user.id)] = user;
    // }
    update();
    UsersApi.followUnfollowUser(isFollowing: false, userId: user.id);
  }
}
