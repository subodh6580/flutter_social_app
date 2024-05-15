import 'package:foap/apiHandler/apis/club_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:get/get.dart';
import '../../helper/user_profile_manager.dart';
import '../../model/user_model.dart';
import 'package:foap/helper/list_extension.dart';

class InviteFriendsToClubController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<UserModel> following = <UserModel>[].obs;
  RxList<UserModel> selectedFriends = <UserModel>[].obs;
  String searchText = '';

  RxBool isLoading = true.obs;
  int page = 1;
  bool canLoadMore = true;

  clear() {
    page = 1;
    canLoadMore = true;
    isLoading.value = false;

    following.value = [];
  }

  getFollowingUsers() {
    if (canLoadMore) {
      isLoading.value = true;
      UsersApi.getFollowingUsers(
          page: page,
          userId: _userProfileManager.user.value!.id,
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

  sendClubJoinInvite(int clubId) {
    if (selectedFriends.isNotEmpty) {
      ClubApi.sendClubInvite(
          clubId: clubId,
          userIds:
              selectedFriends.map((element) => element.id).toList().join(','),
          message: '');
      Get.back();
    }
  }

  searchTextChanged(String text) {
    searchText = text;
  }

  selectFriend(UserModel user) {
    if (selectedFriends.contains(user)) {
      selectedFriends.remove(user);
    } else {
      selectedFriends.add(user);
    }
    update();
  }
}
