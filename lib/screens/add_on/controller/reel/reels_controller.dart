import 'package:foap/components/post_card_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/post_model.dart';
import 'package:foap/model/post_search_query.dart';
import 'package:foap/helper/list_extension.dart';

import '../../../../apiHandler/apis/post_api.dart';

class ReelsController extends GetxController {
  PageController pageController = PageController();

  RxList<PostModel> publicReels = <PostModel>[].obs;
  RxList<PostModel> filteredReels = <PostModel>[].obs;
  RxList<PostModel> likedReels = <PostModel>[].obs;

  Rx<PostModel?> currentViewingReel = Rx<PostModel?>(null);

  bool isLoadingReelsWithAudio = false;
  int reelsWithAudioCurrentPage = 1;
  bool canLoadMoreReelsWithAudio = true;

  bool isLoadingReels = false;
  int reelsCurrentPage = 1;
  bool canLoadMoreReels = true;
  PostSearchQuery reelSearchQuery = PostSearchQuery();

  clearReels() {
    isLoadingReels = false;
    reelsCurrentPage = 1;
    canLoadMoreReels = true;
    // currentViewingReel.value = null;
    print('clearReels');

    update();
  }

  clearReelsWithAudio() {
    isLoadingReelsWithAudio = false;
    reelsWithAudioCurrentPage = 1;
    canLoadMoreReelsWithAudio = true;
    filteredReels.clear();
  }

  setCurrentViewingReel(PostModel reel) {
    print('setCurrentViewingReel');
    currentViewingReel.value = reel;
    currentViewingReel.refresh();
    update();
  }

  currentPageChanged(int index, PostModel reel) {
    setCurrentViewingReel(reel);
  }

  addReels(List<PostModel> reelsList, int? startPage) {
    filteredReels.clear();
    reelsCurrentPage = startPage ?? 1;
    filteredReels.addAll(reelsList);
    filteredReels.unique((e) => e.id);

    update();
  }

  // void addNewReel(PostModel post) {
  //   int index = 0;
  //   if (currentViewingReel.value != null) {
  //     index = publicReels
  //         .indexWhere((element) => element.id == currentViewingReel.value!.id);
  //     if (index == -1) {
  //       index = 0;
  //     }
  //   }
  //
  //   if (index > 0) {
  //     pageController.jumpToPage(index);
  //   }
  //
  //   publicReels.insert(index, post);
  //   publicReels.refresh();
  //
  //   Future.delayed(const Duration(milliseconds: 1500), () {
  //     update();
  //   });
  // }

  setReelsSearchQuery(PostSearchQuery query) {
    if (query != reelSearchQuery) {
      clearReels();
    }
    update();
    reelSearchQuery = query;
    getReels();
  }

  void getReels() async {
    if (canLoadMoreReels == true) {
      isLoadingReels = true;

      PostApi.getPosts(
          isReel: 1,
          userId: reelSearchQuery.userId,
          isPopular: reelSearchQuery.isPopular,
          isFollowing: reelSearchQuery.isFollowing,
          isSold: reelSearchQuery.isSold,
          isMine: reelSearchQuery.isMine,
          isRecent: reelSearchQuery.isRecent,
          title: reelSearchQuery.title,
          hashtag: reelSearchQuery.hashTag,
          page: reelsCurrentPage,
          resultCallback: (result, metadata) {
            publicReels.addAll(result);
            publicReels.unique((e) => e.id);

            publicReels.sort((a, b) => b.createDate!.compareTo(a.createDate!));

            isLoadingReels = false;
            if (reelsCurrentPage == 1 && publicReels.isNotEmpty) {
              currentPageChanged(0, publicReels.first);
            }
            if (reelsCurrentPage >= metadata.pageCount) {
              canLoadMoreReels = false;
            } else {
              canLoadMoreReels = true;
            }
            reelsCurrentPage += 1;
            // totalPages = metadata.pageCount;

            update();
          });
    }
  }

  void getReelsWithAudio(int audioId) async {
    if (canLoadMoreReelsWithAudio == true) {
      isLoadingReelsWithAudio = true;

      PostApi.getPosts(
          isReel: 1,
          audioId: audioId,
          page: reelsWithAudioCurrentPage,
          resultCallback: (result, metadata) {
            filteredReels.addAll(result);
            filteredReels.unique((e) => e.id);

            isLoadingReelsWithAudio = false;

            if (reelsWithAudioCurrentPage == 1) {
              currentPageChanged(0, publicReels.first);
            }

            reelsWithAudioCurrentPage += 1;
            if (result.length == metadata.pageCount) {
              canLoadMoreReelsWithAudio = true;
              // totalPages = response.metaData!.pageCount;
            } else {
              canLoadMoreReelsWithAudio = false;
            }
            update();
          });
    }
  }

  void likeUnlikeReel({required PostModel post}) {
    post.isLike = !post.isLike;
    if (post.isLike) {
      likedReels.add(post);
      currentViewingReel.value?.totalLike += 1;
    } else {
      likedReels.remove(post);
      currentViewingReel.value?.totalLike -= 1;
    }
    likedReels.refresh();
    // post.totalLike = post.isLike ? (post.totalLike) + 1 : (post.totalLike) - 1;
    PostApi.likeUnlikePost(like: post.isLike, postId: post.id);
  }

  deletePost({required PostModel post}) {
    final PostCardController postCardController = Get.find();
    postCardController.deletePost(post: post, callback: () {});

    publicReels.removeWhere((element) => element.id == post.id);
    filteredReels.removeWhere((element) => element.id == post.id);
    likedReels.removeWhere((element) => element.id == post.id);

    AppUtil.showToast(message: deletedString.tr, isSuccess: true);
  }

  void blockUser({required int userId, required VoidCallback callback}) {
    final PostCardController postCardController = Get.find();
    postCardController.blockUser(userId: userId, callback: () {});

    publicReels.removeWhere((element) => element.user.id == userId);
    filteredReels.removeWhere((element) => element.user.id == userId);
    likedReels.removeWhere((element) => element.user.id == userId);
  }

  sharePost({required PostModel post}) {
    final PostCardController postCardController = Get.find();
    postCardController.sharePost(post: post);
  }
}
