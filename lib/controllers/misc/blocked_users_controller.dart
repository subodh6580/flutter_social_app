import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/users_api.dart';
import 'package:foap/helper/list_extension.dart';

class BlockedUsersController extends GetxController {
  RxList<UserModel> usersList = <UserModel>[].obs;
  bool isLoading = false;

  int blockedUserPage = 1;
  bool canLoadMoreBlockedUser = true;

  clear() {
    usersList.value = [];
    isLoading = false;
    blockedUserPage = 1;
    canLoadMoreBlockedUser = true;
  }

  getBlockedUsers() {
    if (canLoadMoreBlockedUser) {
      isLoading = true;

      UsersApi.getBlockedUsers(
          page: blockedUserPage,
          resultCallback: (result, metadata) {
            isLoading = false;
            EasyLoading.dismiss();
            usersList.addAll(result);
            usersList.unique((e)=> e.id);

            blockedUserPage += 1;
            canLoadMoreBlockedUser = result.length >= metadata.perPage;

            update();
          });
    }
  }

  unBlockUser(int userId) {
    isLoading = true;
    UsersApi.unBlockUser(
        userId: userId,
        resultCallback: () {
          isLoading = false;
          usersList.removeWhere((element) => element.id == userId);
          update();
        });
  }
}
