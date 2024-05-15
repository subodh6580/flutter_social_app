import 'package:foap/controllers/post/post_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/user_post_media.dart';
import '../../components/highlights_bar.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/story/highlights_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../model/post_search_query.dart';
import '../chat/chat_detail.dart';
import '../highlights/choose_stories.dart';
import '../highlights/hightlights_viewer.dart';
import '../live/gifts_list.dart';
import '../reuseable_widgets/post_list.dart';
import '../settings_menu/settings_controller.dart';
import 'follower_following_list.dart';

class OtherUserProfile extends StatefulWidget {
  final int userId;

  const OtherUserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  OtherUserProfileState createState() => OtherUserProfileState();
}

class OtherUserProfileState extends State<OtherUserProfile>
    with SingleTickerProviderStateMixin {
  final ProfileController _profileController = Get.find();
  final HighlightsController _highlightsController = HighlightsController();
  final SettingsController _settingsController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();
  final PostController _postController = Get.find();

  List<String> tabs = [postsString, mentionsString];

  TabController? controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(vsync: this, length: tabs.length)
      ..addListener(() {});
    initialLoad();
  }

  initialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.clear();
      loadData();
    });
  }

  @override
  void didUpdateWidget(covariant OtherUserProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  @override
  void dispose() {
    _profileController.clear();
    _postController.clear();
    super.dispose();
  }

  loadData() {
    _profileController.getOtherUserDetail(userId: widget.userId);
    _profileController.getMentionPosts(widget.userId);

    PostSearchQuery query = PostSearchQuery();
    query.userId = widget.userId;
    _postController.setPostSearchQuery(query: query, callback: () {});
    _profileController.getReels(widget.userId);
    _highlightsController.getHighlights(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Stack(children: [
            if (_settingsController.appearanceChanged!.value) Container(),
            NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      leading: const SizedBox(
                        height: 30,
                        width: 30,
                        // color: AppColorConstants.themeColor,
                        child: ThemeIconWidget(ThemeIcon.backArrow),
                      ).circular.lP25.ripple(() {
                        Get.back();
                      }),
                      actions: [
                        const SizedBox(
                          height: 30,
                          width: 30,
                          // color: AppColorConstants.themeColor,
                          child: ThemeIconWidget(ThemeIcon.more),
                        ).circular.rP25.ripple(() {
                          openActionPopup();
                        }),
                      ],
                      backgroundColor: AppColorConstants.backgroundColor,
                      pinned: true,
                      expandedHeight: 550,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: [
                            addProfileView(),
                            addHighlightsView().tP25
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        getTextTabBar(
                            tabs: tabs,
                            controller: controller,
                            canScroll: false),
                      ),
                      pinned: true,
                      // floating: true,
                    )
                  ];
                },
                body: TabBarView(
                  controller: controller,
                  children: [
                    PostList(
                      postSource: PostSource.posts,
                    ),
                    MentionsList(),
                  ],
                )),
          ]),
        ));
  }

  Widget addProfileView() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          return _profileController.user.value != null
              ? Column(
                  children: [
                    Stack(
                      children: [coverImage(), imageAndNameView()],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    statsView().hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 40,
                    ),
                    buttonsView().hp(DesignConstants.horizontalPadding)
                  ],
                )
              : Container();
        });
  }

  Widget imageAndNameView() {
    return Positioned(
      left: 0,
      right: 0,
      top: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatarView(
                  user: _profileController.user.value!,
                  size: 85,
                  onTapHandler: () {
                    //open live
                  }),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Heading6Text(_profileController.user.value!.userName,
                      weight: TextWeight.medium),
                  if (_profileController.user.value!.isVerified)
                    verifiedUserTag()
                ],
              ).bP4,
              if (_profileController.user.value!.profileCategoryTypeId != 0)
                BodyLargeText(
                        _profileController.user.value!.profileCategoryTypeName,
                        weight: TextWeight.regular)
                    .bP4,
              _profileController.user.value?.country != null
                  ? BodyMediumText(
                      '${_profileController.user.value!.country},${_profileController.user.value!.city}',
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget coverImage() {
    return _profileController.user.value!.coverImage != null
        ? CachedNetworkImage(
                width: Get.width,
                height: 280,
                fit: BoxFit.cover,
                imageUrl: _profileController.user.value!.coverImage!)
            // .overlay(Colors.black26)
            .bottomRounded(20)
        : SizedBox(
            width: Get.width,
            height: 280,
            // color: AppColorConstants.themeColor.withOpacity(0.2),
          );
  }

  Widget buttonsView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const Spacer(),
        Expanded(
          child: AppThemeButton(
              height: 35,
              backgroundColor: _profileController.user.value!.followingStatus ==
                      FollowingStatus.following
                  ? AppColorConstants.themeColor
                  : AppColorConstants.cardColor,
              text: _profileController.user.value!.followingStatus ==
                      FollowingStatus.following
                  ? unFollowString.tr
                  : _profileController.user.value!.followingStatus ==
                          FollowingStatus.requested
                      ? requestedString.tr
                      : _profileController.user.value!.isFollower
                          ? followBackString.tr
                          : followString.tr,
              onPress: () {
                _profileController.followUnFollowUser(
                    user: _profileController.user.value!);
              }),
        ),

        if (_settingsController.setting.value!.enableChat)
          SizedBox(
              width: Get.width * 0.25,
              child: AppThemeButton(
                  height: 35,
                  backgroundColor: AppColorConstants.cardColor.darken(0.5),
                  text: chatString.tr,
                  onPress: () {
                    EasyLoading.show(status: loadingString.tr);
                    _chatDetailController.getChatRoomWithUser(
                        userId: _profileController.user.value!.id,
                        callback: (room) {
                          EasyLoading.dismiss();
                          Get.to(() => ChatDetail(
                                chatRoom: room,
                              ));
                        });
                  })).lP8,
        if (_settingsController.setting.value!.enableGift)
          SizedBox(
              width: Get.width * 0.30,
              child: AppThemeButton(
                  height: 35,
                  backgroundColor: AppColorConstants.cardColor.darken(0.5),
                  text: sendGiftString.tr,
                  onPress: () {
                    showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                              heightFactor: 0.8,
                              child:
                                  GiftsPageView(giftSelectedCompletion: (gift) {
                                Get.back();
                                _profileController.sendGift(gift);
                              }));
                        });
                  })).lP8,
      ],
    );
  }

  Widget statsView() {
    return Container(
      color: AppColorConstants.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                _profileController.user.value!.totalPost.toString(),
              ).bP8,
              BodySmallText(
                postsString.tr,
              ),
            ],
          ),
          // const SizedBox(
          //   width: 20,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                '${_profileController.user.value!.totalFollower}',
              ).bP8,
              BodySmallText(
                followersString.tr,
              ),
            ],
          ).ripple(() {
            if (_profileController.user.value!.totalFollower > 0) {
              Get.to(() => FollowerFollowingList(
                        isFollowersList: true,
                        userId: widget.userId,
                      ))!
                  .then((value) {
                initialLoad();
              });
            }
          }),
          // const SizedBox(
          //   width: 20,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                '${_profileController.user.value!.totalFollowing}',
              ).bP8,
              BodySmallText(
                followingString.tr,
              ),
            ],
          ).ripple(() {
            if (_profileController.user.value!.totalFollowing > 0) {
              Get.to(() => FollowerFollowingList(
                        isFollowersList: false,
                        userId: widget.userId,
                      ))!
                  .then((value) {
                initialLoad();
              });
            }
          }),
        ],
      ).p16,
    ).round(15);
  }

  void openActionPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              color: AppColorConstants.backgroundColor,
              child: Wrap(
                children: [
                  ListTile(
                      title: Center(child: BodyLargeText(reportString.tr)),
                      onTap: () async {
                        Get.back();

                        _profileController.reportUser(context);
                      }),
                  divider(),
                  ListTile(
                      title: Center(child: BodyLargeText(blockString.tr)),
                      onTap: () async {
                        Get.back();

                        _profileController.blockUser(context);
                      }),
                  divider(),
                  ListTile(
                      title: Center(child: BodyLargeText(cancelString.tr)),
                      onTap: () {
                        Get.back();
                      }),
                ],
              ),
            ));
  }

  Widget addHighlightsView() {
    return GetBuilder<HighlightsController>(
        init: _highlightsController,
        builder: (ctx) {
          return _highlightsController.isLoading == true
              ? const StoryAndHighlightsShimmer()
              : HighlightsBar(
                  highlights: _highlightsController.highlights,
                  addHighlightCallback: () {
                    Get.to(() => const ChooseStoryForHighlights());
                  },
                  viewHighlightCallback: (highlight) {
                    Get.to(() => HighlightViewer(highlight: highlight))!
                        .then((value) {
                      loadData();
                    });
                  },
                );
        });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColorConstants.backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
