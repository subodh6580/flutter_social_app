import 'package:foap/controllers/post/post_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/user_card.dart';
import '../../controllers/misc/user_network_controller.dart';
import '../profile/other_user_profile.dart';

class LikedByUsers extends StatefulWidget {
  final int postId;

  const LikedByUsers({Key? key, required this.postId}) : super(key: key);

  @override
  LikedByUsersState createState() => LikedByUsersState();
}

class LikedByUsersState extends State<LikedByUsers> {
  final PostController _postController = Get.find();
  final UserNetworkController _userNetworkController = UserNetworkController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    _postController.getPostLikedByUsers(
        postId: widget.postId,
        callback: () {
          _refreshController.loadComplete();
        });
  }

  @override
  void dispose() {
    _postController.clearPostLikedByUsers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBar(title: likesString.tr),
            Expanded(
              child: GetBuilder<PostController>(
                  init: _postController,
                  builder: (ctx) {
                    ScrollController scrollController = ScrollController();
                    scrollController.addListener(() {
                      if (scrollController.position.maxScrollExtent ==
                          scrollController.position.pixels) {
                        // if (!_userNetworkController.isLoading.value) {
                        //   _userNetworkController
                        //       .getFollowingUsers(widget.userId);
                        // }
                      }
                    });

                    List<UserModel> usersList = _postController.likedByUsers;
                    return _postController
                            .postLikedByDataWrapper.isLoading.value
                        ? const ShimmerUsers()
                            .hp(DesignConstants.horizontalPadding)
                        : Column(
                            children: [
                              usersList.isEmpty
                                  ? noUserFound(context)
                                  : Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 50),
                                        controller: scrollController,
                                        itemCount: usersList.length,
                                        itemBuilder: (context, index) {
                                          return UserTile(
                                            profile: usersList[index],
                                            viewCallback: () {
                                              Get.to(() => OtherUserProfile(
                                                        userId:
                                                            usersList[index].id,
                                                      ))!
                                                  .then(
                                                      (value) => {loadData()});
                                            },
                                            followCallback: () {
                                              _userNetworkController
                                                  .followUser(usersList[index]);
                                            },
                                            unFollowCallback: () {
                                              _userNetworkController
                                                  .unFollowUser(
                                                      usersList[index]);
                                            },
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            height: 20,
                                          );
                                        },
                                      )
                                          .hp(DesignConstants.horizontalPadding)
                                          .addPullToRefresh(
                                              refreshController:
                                                  _refreshController,
                                              onRefresh: () {},
                                              onLoading: () {
                                                loadData();
                                              },
                                              enablePullUp: true,
                                              enablePullDown: false),
                                    ),
                            ],
                          );
                  }),
            ),
          ],
        ));
  }
}
