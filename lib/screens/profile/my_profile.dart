import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/update_profile.dart';
import 'package:foap/screens/profile/user_post_media.dart';
import 'package:foap/screens/settings_menu/settings.dart';
import '../../components/highlights_bar.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/post/post_controller.dart';
import '../../controllers/story/highlights_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../model/post_search_query.dart';
import '../highlights/choose_stories.dart';
import '../highlights/hightlights_viewer.dart';
import '../reuseable_widgets/post_list.dart';
import '../settings_menu/settings_controller.dart';
import 'follower_following_list.dart';

class MyProfile extends StatefulWidget {
  final bool showBack;

  const MyProfile({Key? key, required this.showBack}) : super(key: key);

  @override
  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile>
    with SingleTickerProviderStateMixin {
  final ProfileController _profileController = Get.find();
  final HighlightsController _highlightsController = HighlightsController();
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
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
  void didUpdateWidget(covariant MyProfile oldWidget) {
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
    _profileController.getMyProfile();
    _profileController.getMentionPosts(_userProfileManager.user.value!.id);
    PostSearchQuery query = PostSearchQuery();
    query.userId = _userProfileManager.user.value!.id;
    _postController.setPostSearchQuery(query: query, callback: () {});
    _profileController.getReels(_userProfileManager.user.value!.id);

    _highlightsController.getHighlights(
        userId: _userProfileManager.user.value!.id);
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
                      backgroundColor: Colors.yellow,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      expandedHeight: 540.0,
                      toolbarHeight: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: [
                            addProfileView(),
                            addHighlightsView()
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        getTextTabBar(tabs: tabs, controller: controller,canScroll: false),
                      ),
                      pinned: true,
                      // floating: true,
                    )
                  ];
                },
                body: TabBarView(
                  controller: controller,
                  children: [
                    PostList(postSource: PostSource.posts,),
                    MentionsList(),
                  ],
                )),
          ]),
        ));
  }

  Widget addProfileView() {
    return Stack(
      children: [
        SizedBox(
          height: 480,
          child: GetBuilder<ProfileController>(
              init: _profileController,
              builder: (ctx) {
                return _profileController.user.value != null
                    ? Stack(
                        children: [
                          _profileController.user.value!.coverImage != null
                              ? CachedNetworkImage(
                                      width: Get.width,
                                      height: 300,
                                      fit: BoxFit.cover,
                                      imageUrl: _profileController
                                          .user.value!.coverImage!)
                                  .bottomRounded(40)
                              : Container(
                                  width: Get.width,
                                  height: 300,
                                  color: AppColorConstants.themeColor
                                      .withOpacity(0.2),
                                ).bottomRounded(40),
                          Container(
                            height: 300,
                            color: Colors.black26,
                          ).bottomRounded(40),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 100,
                            child: Column(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  UserAvatarView(
                                      user: _profileController.user.value!,
                                      size: 85,
                                      onTapHandler: () {}),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Heading6Text(
                                        _profileController.user.value!.userName,
                                        weight: TextWeight.medium,
                                        color: Colors.white,
                                      ),
                                      if (_profileController
                                          .user.value!.isVerified)
                                        verifiedUserTag()
                                    ],
                                  ).bP4,
                                  if (_profileController
                                          .user.value!.profileCategoryTypeId !=
                                      0)
                                    BodyLargeText(
                                      _profileController
                                          .user.value!.profileCategoryTypeName,
                                      weight: TextWeight.medium,
                                      color: Colors.white70,
                                    ).bP4,
                                  _profileController.user.value!.country != null
                                      ? BodyMediumText(
                                          '${_profileController.user.value!.country}, ${_profileController.user.value!.city}',
                                          color: Colors.white70,
                                        )
                                      : Container(),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Container(
                                    color: AppColorConstants.cardColor.darken(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Heading4Text(
                                              _profileController
                                                  .user.value!.totalPost
                                                  .toString(),
                                              weight: TextWeight.medium,
                                            ).bP8,
                                            BodySmallText(
                                              postsString.tr,
                                            ),
                                          ],
                                        ),
                                        // const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Heading4Text(
                                              '${_profileController.user.value!.totalFollower}',
                                              weight: TextWeight.medium,
                                            ).bP8,
                                            BodySmallText(
                                              followersString.tr,
                                            ),
                                          ],
                                        ).ripple(() {
                                          if (_profileController
                                                  .user.value!.totalFollower >
                                              0) {
                                            Get.to(() => FollowerFollowingList(
                                                      isFollowersList: true,
                                                      userId:
                                                          _userProfileManager
                                                              .user.value!.id,
                                                    ))!
                                                .then((value) {
                                              loadData();
                                            });
                                          }
                                        }),
                                        // const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Heading4Text(
                                              '${_profileController.user.value!.totalFollowing}',
                                              weight: TextWeight.medium,
                                            ).bP8,
                                            BodySmallText(
                                              followingString.tr,
                                            ),
                                          ],
                                        ).ripple(() {
                                          if (_profileController
                                                  .user.value!.totalFollowing >
                                              0) {
                                            Get.to(() => FollowerFollowingList(
                                                    isFollowersList: false,
                                                    userId: _userProfileManager
                                                        .user.value!.id))!
                                                .then((value) {
                                              loadData();
                                            });
                                          }
                                        }),
                                      ],
                                    ).p16,
                                  ).round(15),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  AppThemeButton(
                                      height: 40,
                                      text: editProfileString.tr,
                                      onPress: () {
                                        Get.to(() => const UpdateProfile())!
                                            .then((value) {
                                          loadData();
                                        });
                                      })
                                ]).p16,
                          ),
                        ],
                      )
                    : Container();
              }),
        ),
        Positioned(top: 0, left: 0, right: 0, child: appBar())
      ],
    );
  }

  addHighlightsView() {
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

  Widget appBar() {
    return Container(
      color: Colors.black26,
      height: 100,
      child: widget.showBack == true
          ? backNavigationBarWithIcon(
              title: '',
              icon: ThemeIcon.setting,
              iconColor: Colors.white,
              iconBtnClicked: () {
                Get.to(() => const Settings());
              }).tp(40)
          : titleNavigationBarWithIcon(
              title: '',
              icon: ThemeIcon.setting,
              iconColor: Colors.white,
              completion: () {
                Get.to(() => const Settings());
              }).tp(40),
    );
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
