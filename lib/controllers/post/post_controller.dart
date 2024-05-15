import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../model/data_wrapper.dart';
import '../../model/post_model.dart';
import '../../model/post_search_query.dart';

class PostController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> videos = <PostModel>[].obs;

  RxList<PostModel> mentions = <PostModel>[].obs;
  RxList<UserModel> likedByUsers = <UserModel>[].obs;

  Rx<PostInsight?> insight = Rx<PostInsight?>(null);

  int totalPages = 100;

  DataWrapper postDataWrapper = DataWrapper();
  DataWrapper mentionsDataWrapper = DataWrapper();
  DataWrapper videosDataWrapper = DataWrapper();

  PostSearchQuery? postSearchQuery;
  MentionedPostSearchQuery? mentionedPostSearchQuery;

  DataWrapper postLikedByDataWrapper = DataWrapper();

  clear() {
    totalPages = 100;
    postDataWrapper = DataWrapper();
    mentionsDataWrapper = DataWrapper();

    posts.value = [];
    mentions.value = [];

    clearVideos();
    clearPostLikedByUsers();
    update();
  }

  clearVideos() {
    videos.clear();
    videosDataWrapper = DataWrapper();
  }

  clearPostLikedByUsers() {
    likedByUsers.clear();
    postLikedByDataWrapper = DataWrapper();
  }

  addPosts(List<PostModel> postsList, int? startPage, int? totalPages) {
    mentionsDataWrapper.page = startPage ?? 1;
    postDataWrapper.page = startPage ?? 1;
    this.totalPages = totalPages ?? 100;

    posts.addAll(postsList);
    posts.unique((e) => e.id);
    update();
  }

  setPostSearchQuery({required PostSearchQuery query, required VoidCallback callback}) {
    if (query != postSearchQuery) {
      clear();
    }
    update();
    postSearchQuery = query;
    getPosts(callback);
  }

  setMentionedPostSearchQuery(MentionedPostSearchQuery query) {
    mentionedPostSearchQuery = query;
    getMyMentions();
  }

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    mentions.removeWhere((element) => element.id == post.id);

    posts.refresh();
    mentions.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    mentions.removeWhere((element) => element.user.id == post.user.id);

    posts.refresh();
    mentions.refresh();
  }

  void getPosts(VoidCallback callback) async {
    if (postDataWrapper.haveMoreData.value == true &&
        totalPages > postDataWrapper.page) {
      postDataWrapper.isLoading.value = true;

      PostApi.getPosts(
          userId: postSearchQuery!.userId,
          isPopular: postSearchQuery!.isPopular,
          isFollowing: postSearchQuery!.isFollowing,
          isSold: postSearchQuery!.isSold,
          isMine: postSearchQuery!.isMine,
          isRecent: postSearchQuery!.isRecent,
          title: postSearchQuery!.title,
          hashtag: postSearchQuery!.hashTag,
          page: postDataWrapper.page,
          resultCallback: (result, metadata) {
            posts.addAll(result);
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e) => e.id);
            postDataWrapper.isLoading.value = false;

            postDataWrapper.totalRecords.value = metadata.totalCount;
            postDataWrapper.haveMoreData.value =
                metadata.pageCount >= metadata.currentPage;

            postDataWrapper.page += 1;

            callback();

            update();
          });
    }
    else{
      callback();
    }
  }

  void getVideos(VoidCallback callback) async {
    if (videosDataWrapper.haveMoreData.value == true &&
        totalPages > videosDataWrapper.page) {
      videosDataWrapper.isLoading.value = true;

      PostApi.getPosts(
          userId: postSearchQuery!.userId,
          isPopular: postSearchQuery!.isPopular,
          isFollowing: postSearchQuery!.isFollowing,
          isSold: postSearchQuery!.isSold,
          isMine: postSearchQuery!.isMine,
          isRecent: postSearchQuery!.isRecent,
          title: postSearchQuery!.title,
          hashtag: postSearchQuery!.hashTag,
          page: videosDataWrapper.page,
          resultCallback: (result, metadata) {
            posts.addAll(result);
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e) => e.id);
            videosDataWrapper.isLoading.value = false;

            videosDataWrapper.totalRecords.value = metadata.totalCount;
            videosDataWrapper.haveMoreData.value =
                metadata.pageCount >= metadata.currentPage;

            videosDataWrapper.page += 1;

            callback();

            update();
          });
    }
    else{
      callback();
    }
  }

  void getMyMentions() {
    if (mentionsDataWrapper.haveMoreData.value) {
      PostApi.getMentionedPosts(
          userId: mentionedPostSearchQuery!.userId,
          resultCallback: (result, metadata) {
            mentionsDataWrapper.isLoading.value = false;
            mentions.addAll(result.reversed.toList());
            mentions.unique((e) => e.id);

            mentionsDataWrapper.totalRecords.value = metadata.totalCount;

            mentionsDataWrapper.page += 1;
            mentionsDataWrapper.haveMoreData.value =
                metadata.pageCount >= metadata.currentPage;

            update();
          });
    }
  }

  void reportPost(int postId) {
    PostApi.reportPost(
        postId: postId,
        resultCallback: () {
          AppUtil.showToast(
              message: postReportedSuccessfullyString.tr, isSuccess: true);
        });
  }

  viewInsight(int postId) {
    PostApi.getPostInsight(postId, resultCallback: (result) {
      insight.value = result;
      insight.refresh();
    });
  }

  void getPostLikedByUsers(
      {required int postId, required VoidCallback callback}) async {
    if (postLikedByDataWrapper.haveMoreData.value == true) {
      postLikedByDataWrapper.isLoading.value = true;

      PostApi.postLikedByUsers(
          postId: postId,
          page: postLikedByDataWrapper.page,
          resultCallback: (result, metadata) {
            likedByUsers.addAll(result);
            likedByUsers.unique((e) => e.id);
            postLikedByDataWrapper.isLoading.value = false;

            postLikedByDataWrapper.totalRecords.value = metadata.totalCount;
            postLikedByDataWrapper.haveMoreData.value =
                metadata.pageCount >= metadata.currentPage;

            postLikedByDataWrapper.page += 1;

            callback();

            update();
          });
    }
  }

}
