import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../model/post_model.dart';
import '../../model/user_model.dart';
import 'package:foap/helper/list_extension.dart';

class SelectUserForChatController extends GetxController {
  final ChatDetailController chatDetailController = Get.find();

  RxList<UserModel> following = <UserModel>[].obs;

  RxList<UserModel> processingActionUsers = <UserModel>[].obs;
  RxList<UserModel> completedActionUsers = <UserModel>[].obs;
  RxList<UserModel> failedActionUsers = <UserModel>[].obs;

  int followingPage = 1;
  bool canLoadMoreFollowing = true;
  bool followingIsLoading = false;

  String searchText = '';

  clear() {
    followingPage = 1;
    canLoadMoreFollowing = true;
    followingIsLoading = false;

    processingActionUsers.clear();
    failedActionUsers.clear();
    completedActionUsers.clear();
    following.clear();
  }

  searchTextChanged(String text) {
    searchText = text;
  }

  getFollowingUsers() {
    if (canLoadMoreFollowing) {
      followingIsLoading = true;
      UsersApi.getFollowingUsers(
          page: followingPage,
          resultCallback: (result, metadata) {
            followingIsLoading = false;
            following.addAll(result);
            following.unique((e)=> e.id);

            followingPage += 1;
            if (result.length == metadata.perPage) {
              canLoadMoreFollowing = true;
            } else {
              canLoadMoreFollowing = false;
            }
            update();
          });
    }
  }

  sendMessage({required UserModel toUser, PostModel? post}) {
    updateActionForUser(toUser, 1);
    if (post != null) {
      chatDetailController.getChatRoomWithUser(
          userId: toUser.id,
          callback: (room) {
            chatDetailController
                .sendPostAsMessage(post: post, room: room)
                .then((status) {
              if (status == true) {
                updateActionForUser(toUser, 2);
              } else {
                updateActionForUser(toUser, 0);
              }
              update();
            });
          });
    } else {
      chatDetailController.getChatRoomWithUser(
          userId: toUser.id,
          callback: (room) {
            chatDetailController
                .forwardSelectedMessages(room: room)
                .then((status) {
              if (status == true) {
                updateActionForUser(toUser, 2);
              } else {
                updateActionForUser(toUser, 0);
              }
              update();
            });
          });
    }
  }

  updateActionForUser(UserModel user, int action) {
    if (action == 0) {
      failedActionUsers.add(user);
    }
    if (action == 1) {
      processingActionUsers.add(user);
      failedActionUsers.remove(user);
    }
    if (action == 2) {
      completedActionUsers.add(user);
      processingActionUsers.remove(user);
      failedActionUsers.remove(user);
    }
  }
}
