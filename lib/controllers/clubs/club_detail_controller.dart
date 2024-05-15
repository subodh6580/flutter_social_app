import 'package:foap/apiHandler/apis/club_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../manager/db_manager.dart';
import '../../model/club_join_request.dart';
import '../../model/club_model.dart';
import '../../model/post_model.dart';
import '../../model/post_search_query.dart';
import '../../screens/dashboard/posts.dart';
import '../../screens/profile/other_user_profile.dart';
import '../chat_and_call/chat_detail_controller.dart';
import 'package:foap/helper/list_extension.dart';

class ClubDetailController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<ClubJoinRequest> joinRequests = <ClubJoinRequest>[].obs;

  Rx<ClubModel?> club = Rx<ClubModel?>(null);
  PostSearchQuery postSearchQuery = PostSearchQuery();

  int postsPage = 1;
  bool canLoadMorePosts = true;
  RxBool isLoading = false.obs;

  int jonRequestsPage = 1;
  bool canLoadMoreJoinRequests = true;

  clear() {
    isLoading.value = false;
    posts.clear();
    joinRequests.clear();
    postsPage = 1;
    canLoadMorePosts = true;

    jonRequestsPage = 1;
    canLoadMoreJoinRequests = true;
  }

  setClub(ClubModel clubObj) {
    club.value = clubObj;
    club.refresh();

    update();
  }

  void getPosts({required int clubId, required VoidCallback callback}) async {
    if (canLoadMorePosts == true) {
      postSearchQuery.isRecent = 1;
      postSearchQuery.clubId = clubId;
      isLoading.value = true;

      PostApi.getPosts(
          userId: postSearchQuery.userId,
          isPopular: postSearchQuery.isPopular,
          isFollowing: postSearchQuery.isFollowing,
          isSold: postSearchQuery.isSold,
          isMine: postSearchQuery.isMine,
          isRecent: postSearchQuery.isRecent,
          title: postSearchQuery.title,
          hashtag: postSearchQuery.hashTag,
          clubId: postSearchQuery.clubId,
          page: postsPage,
          resultCallback: (result, metadata) {
            posts.addAll(
                result.where((element) => element.gallery.isNotEmpty).toList());
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e)=> e.id);

            isLoading.value = false;

            if (postsPage >= metadata.pageCount) {
              canLoadMorePosts = false;
            } else {
              canLoadMorePosts = true;
            }
            postsPage += 1;

            callback();
          });
    }
  }

  getClubJoinRequests({required int clubId}) {
    if (canLoadMoreJoinRequests == true) {
      isLoading.value = true;

      ClubApi.getClubJoinRequests(
          clubId: clubId,
          page: jonRequestsPage,
          resultCallback: (result, metadata) {
            joinRequests.addAll(result);
            joinRequests.unique((e)=> e.id);

            isLoading.value = false;

            if (jonRequestsPage >= metadata.pageCount) {
              canLoadMoreJoinRequests = false;
            } else {
              canLoadMoreJoinRequests = true;
            }
            jonRequestsPage += 1;
          });
    }
  }

  postTextTapHandler({required PostModel post, required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
                hashTag: text.replaceAll('#', ''),
              ))!
          .then((value) {
        getPosts(clubId: postSearchQuery.clubId!, callback: () {});
      });
    } else {
      String userTag = text.replaceAll('@', '');
      if (post.mentionedUsers
          .where((element) => element.userName == userTag)
          .isNotEmpty) {
        int mentionedUserId = post.mentionedUsers
            .where((element) => element.userName == userTag)
            .first
            .id;
        Get.to(() => OtherUserProfile(userId: mentionedUserId))!.then((value) {
          getPosts(clubId: postSearchQuery.clubId!, callback: () {});
        });
      }
    }
  }

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    posts.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);

    posts.refresh();
  }

  joinClub() {
    if (club.value!.isRequestBased == true) {
      club.value!.isRequested = true;
      club.refresh();

      ClubApi.sendClubJoinRequest(clubId: club.value!.id!);
    } else {
      club.value!.isJoined = true;
      club.refresh();

      ClubApi.joinClub(
          clubId: club.value!.id!,
          resultCallback: () {
            if (club.value!.enableChat == 1) {
              _chatDetailController.getRoomDetail(club.value!.chatRoomId!,
                  (chatRoom) {
                getIt<DBManager>().saveRooms([chatRoom]);
              });
            }
          });
    }
  }

  leaveClub() {
    club.value!.isJoined = false;
    club.refresh();

    ClubApi.leaveClub(clubId: club.value!.id!);
  }

  acceptClubJoinRequest(ClubJoinRequest request) {
    joinRequests.remove(request);
    joinRequests.refresh();
    update();

    ClubApi.acceptDeclineClubJoinRequest(
        requestId: request.id!, replyStatus: 10);
  }

  declineClubJoinRequest(ClubJoinRequest request) {
    joinRequests.remove(request);
    joinRequests.refresh();
    update();

    ClubApi.acceptDeclineClubJoinRequest(
        requestId: request.id!, replyStatus: 3);
  }
}
