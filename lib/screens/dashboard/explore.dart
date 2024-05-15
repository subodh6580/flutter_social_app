import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../components/search_bar.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/misc/explore_controller.dart';
import '../../controllers/post/post_controller.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../home_feed/quick_links.dart';
import '../reuseable_widgets/club_listing.dart';
import '../reuseable_widgets/hashtags.dart';
import '../reuseable_widgets/post_list.dart';
import '../reuseable_widgets/users_list.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final ExploreController exploreController = ExploreController();
  final PostController postController = Get.find();

  List<String> segments = [
    postsString,
    accountString,
    hashTagsString,
    clubsString,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Explore oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    exploreController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: KeyboardDismissOnTap(
            child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Expanded(
                  child: SFSearchBar(
                      showSearchIcon: true,
                      iconColor: AppColorConstants.themeColor,
                      onSearchChanged: (value) {
                        exploreController.searchTextChanged(value);
                      },
                      onSearchStarted: () {
                        //controller.startSearch();
                      },
                      onSearchCompleted: (searchTerm) {}),
                ),
                Obx(() => exploreController.searchText.isNotEmpty
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            color: AppColorConstants.themeColor,
                            child: ThemeIconWidget(
                              ThemeIcon.close,
                              color: AppColorConstants.backgroundColor,
                              size: 25,
                            ),
                          ).round(20).ripple(() {
                            exploreController.closeSearch();
                          }),
                        ],
                      )
                    : Container())
              ],
            ).setPadding(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding,
                top: 25),
            Expanded(
                child: DefaultTabController(
                    length: segments.length,
                    child: Obx(() => exploreController.searchText.isNotEmpty
                        ? Column(
                            children: [
                              SMTabBar(tabs: segments,canScroll: true,),
                              // segmentView(),
                              // divider(height: 0.2),
                              Expanded(
                                child: TabBarView(children: [
                                  PostList(
                                    postSource: PostSource.posts,
                                  ),
                                  UsersList(),
                                  HashTagsList(),
                                  ClubListing(),
                                ]),
                              )
                            ],
                          )
                        : QuickLinkWidget(
                            callback: () {},
                          )))),
          ],
        )),
      ),
    );
  }

  Widget segmentView() {
    return HorizontalSegmentBar(
        width: Get.width,
        onSegmentChange: (segment) {
          exploreController.segmentChanged(segment);
        },
        segments: [
          topString.tr,
          accountString.tr,
          hashTagsString.tr,
          // locations,
        ]);
  }
}
