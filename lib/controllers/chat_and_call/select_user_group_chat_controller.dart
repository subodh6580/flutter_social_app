import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:get/get.dart';
import '../../model/user_model.dart';
import 'package:foap/helper/list_extension.dart';

class SelectUserForGroupChatController extends GetxController {
  RxList<UserModel> friends = <UserModel>[].obs;
  RxList<UserModel> selectedFriends = <UserModel>[].obs;

  int page = 1;
  bool canLoadMore = true;
  bool isLoading = false;

  String searchText = '';

  clear() {
    page = 1;
    canLoadMore = true;
    isLoading = false;
    selectedFriends.clear();
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

  getFriends() {
    if (canLoadMore) {
      isLoading = true;
      UsersApi.getFollowingUsers(
          page: page,
          resultCallback: (result, metadata) {
            isLoading = false;
            friends.addAll(result);
            friends.unique((e)=> e.id);

            page += 1;
            canLoadMore = result.length >= metadata.perPage;

            update();
          });
    }
  }
}
