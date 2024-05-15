import 'package:flutter/material.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/screens/club/search_club.dart';
import 'package:get/get.dart';
import '../../components/actionSheets/action_sheet1.dart';
import '../../components/group_avatars/group_avatar1.dart';
import '../../components/group_avatars/group_avatar2.dart';
import '../../components/shimmer_widgets.dart';
import '../../components/top_navigation_bar.dart';
import '../../controllers/clubs/clubs_controller.dart';

import '../../helper/localization_strings.dart';
import '../../model/category_model.dart';
import '../../model/club_invitation.dart';
import '../../model/generic_item.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../../theme/theme_icon.dart';
import '../../util/app_config_constants.dart';
import '../../util/app_util.dart';
import '../reuseable_widgets/club_listing.dart';
import 'categories_list.dart';
import 'category_club_listing.dart';
import 'club_detail.dart';

class ExploreClubs extends StatefulWidget {
  const ExploreClubs({Key? key}) : super(key: key);

  @override
  ExploreClubsState createState() => ExploreClubsState();
}

class ExploreClubsState extends State<ExploreClubs> {
  final ClubsController _clubsController = Get.find();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    loadData();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          if (!_clubsController.isLoadingInvitations.value) {
            _clubsController.getClubInvitations();
          }
        }
      }
    });

    super.initState();
  }

  loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clubsController.clear();

      _clubsController.getCategories();
      _clubsController.getClubs();
      _clubsController.selectedSegmentIndex(index: 0);
    });
  }

  @override
  void dispose() {
    _clubsController.clear();
    _clubsController.clearMembers();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: Container(
        height: 50,
        width: 50,
        color: AppColorConstants.themeColor,
        child: const ThemeIconWidget(
          ThemeIcon.plus,
          size: 25,
          color: Colors.white,
        ),
      ).circular.ripple(() {
        Get.to(() => CategoriesList(clubsController: _clubsController))!
            .then((value) {
          loadData();
        });
      }),
      body: Column(
        children: [
          backNavigationBarWithIcon(
              title: clubsString.tr,
              iconBtnClicked: () {
                _clubsController.clear();
                Get.to(() => const SearchClubsListing())!.then((value) {
                  loadData();
                });
              },
              icon: ThemeIcon.search),
          const SizedBox(height: 15,),
          categories(),
          const SizedBox(
            height: 30,
          ),
          links(),
          Expanded(
              child: Obx(() => _clubsController.segmentIndex.value == 3
                  ? clubsInvitationsListingWidget(_clubsController.invitations)
                  : ClubListing()))
        ],
      ),
    );
  }

  Widget categories() {
    return SizedBox(
      height: 50,
      child: Obx(() {
        List<CategoryModel> categories = _clubsController.categories;
        return _clubsController.isLoadingCategories.value
            ? const ClubsCategoriesScreenShimmer()
            : ListView.separated(
                padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return CategoryAvatarType1(category: categories[index])
                      .ripple(() {
                    Get.to(() =>
                        CategoryClubsListing(category: categories[index]))!.then((value) {
                      _clubsController.clear();
                      _clubsController.getClubs();
                    });
                  });
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    width: 10,
                  );
                });
      }),
    );
  }

  Widget links() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: HorizontalMenuBar(
                  padding:  EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
                  onSegmentChange: (segment) {
                    _clubsController.selectedSegmentIndex(index: segment);
                  },
                  selectedIndex: _clubsController.segmentIndex.value,
                  menus: [
                    allString.tr,
                    joinedString.tr,
                    myClubString.tr,
                    invitesString.tr,
                  ]),
            ),
          ],
        ));
  }

  Widget clubsInvitationsListingWidget(List<ClubInvitation> invitations) {
    return _clubsController.isLoadingClubs.value
        ? const ClubsScreenShimmer()
        : _clubsController.clubs.isEmpty
            ? Container()
            : ListView.separated(
                controller: _controller,
                padding:  EdgeInsets.only(
                    left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 20, bottom: 100),
                itemCount: invitations.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext ctx, int index) {
                  return ClubInvitationCard(
                    invitation: invitations[index],
                    acceptBtnClicked: () {
                      _clubsController.acceptClubInvitation(invitations[index]);
                    },
                    declineBtnClicked: () {
                      _clubsController
                          .declineClubInvitation(invitations[index]);
                    },
                    previewBtnClicked: () {
                      Get.to(() => ClubDetail(
                            club: invitations[index].club!,
                            needRefreshCallback: () {
                              _clubsController.getClubs();
                            },
                            deleteCallback: (club) {
                              _clubsController.clubDeleted(club);
                              AppUtil.showToast(
                                  message: clubIsDeletedString.tr,
                                  isSuccess: true);
                            },
                          ));
                    },
                  );
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const SizedBox(
                    height: 25,
                  );
                });
  }

  showActionSheet(PostModel post) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: [
                GenericItem(
                    id: '1', title: shareString.tr, icon: ThemeIcon.share),
                GenericItem(
                    id: '2', title: reportString.tr, icon: ThemeIcon.report),
                GenericItem(
                    id: '3', title: hideString.tr, icon: ThemeIcon.hide),
              ],
              itemCallBack: (item) {},
            ));
  }
}
