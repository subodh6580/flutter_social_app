import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card.dart';
import '../../controllers/post/post_controller.dart';
import '../../controllers/post/saved_post_controller.dart';
import '../../controllers/post/watch_videos_controller.dart';

class PostList extends StatelessWidget {
  final PostController _postController = Get.find();
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  final PostSource postSource;

  PostList({Key? key, required this.postSource}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return postSource == PostSource.videos
        ? videosPosts()
        : postSource == PostSource.saved
        ? savedPosts()
        : posts();
  }

  Widget posts() {
    return Obx(() => Container(
        child: _postController.postDataWrapper.isLoading.value
            ? const PostBoxShimmer()
            : _postController.posts.isNotEmpty
            ? ListView.separated(
          padding: const EdgeInsets.only(top: 20, bottom: 100),
          itemCount: _postController.posts.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) => PostCard(
              model: _postController.posts[index],
              removePostHandler: () {},
              blockUserHandler: () {},),
          separatorBuilder: (BuildContext context, int index) =>
          divider(height: 10).vP16,
        ).addPullToRefresh(
            refreshController: _refreshController,
            onRefresh: () {},
            onLoading: () {
              _postController.getPosts(() {});
            },

            enablePullUp: true,
            enablePullDown: false)
            : SizedBox(
          height: Get.size.height * 0.5,
          child: emptyPost(title: noPostFoundString.tr, subTitle: ''),
        )));
  }

  Widget savedPosts() {
    final SavedPostController savedPostController = Get.find();

    return Obx(() => Container(
        child: savedPostController.postDataWrapper.isLoading.value
            ? const PostBoxShimmer()
            : savedPostController.posts.isNotEmpty
            ? ListView.separated(
          padding: const EdgeInsets.only(top: 20, bottom: 100),
          itemCount: savedPostController.posts.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) => PostCard(
              model: savedPostController.posts[index],
              removePostHandler: () {},
              blockUserHandler: () {}),
          separatorBuilder: (BuildContext context, int index) =>
          divider(height: 10).vP16,
        ).addPullToRefresh(
            refreshController: _refreshController,
            onRefresh: () {
              savedPostController.refreshData(() {
                _refreshController.refreshCompleted();
              });
            },
            onLoading: () {
              savedPostController.loadMore(() {
                _refreshController.loadComplete();
              });
            },
            enablePullUp: true,
            enablePullDown: true)
            : SizedBox(
          height: Get.size.height * 0.5,
          child: emptyPost(title: noPostFoundString.tr, subTitle: ''),
        )));
  }

  Widget videosPosts() {
    final WatchVideosController watchVideosController = Get.find();

    return Obx(() => Container(
        child: watchVideosController.postDataWrapper.isLoading.value
            ? const PostBoxShimmer()
            : watchVideosController.videos.isNotEmpty
            ? ListView.separated(
          padding: const EdgeInsets.only(top: 20, bottom: 100),
          itemCount: watchVideosController.videos.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) => PostCard(
              model: watchVideosController.videos[index],
              removePostHandler: () {},
              blockUserHandler: () {}),
          separatorBuilder: (BuildContext context, int index) =>
          divider(height: 10).vP16,
        ).addPullToRefresh(
            refreshController: _refreshController,
            onRefresh: () {
              watchVideosController.refreshData(() {
                _refreshController.refreshCompleted();
              });
            },
            onLoading: () {
              watchVideosController.loadMore(() {
                _refreshController.loadComplete();
              });
            },
            enablePullUp: true,
            enablePullDown: true)
            : SizedBox(
          height: Get.size.height * 0.5,
          child:
          emptyPost(title: noVideoFoundString.tr, subTitle: ''),
        )));
  }
}
