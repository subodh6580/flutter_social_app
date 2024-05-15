import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/group_avatars/group_avatar2.dart';
import '../../components/shimmer_widgets.dart';
import '../../controllers/clubs/clubs_controller.dart';
import '../../helper/localization_strings.dart';
import '../../util/app_config_constants.dart';
import '../../util/app_util.dart';
import '../club/club_detail.dart';

class ClubListing extends StatelessWidget {
  final ClubsController _clubsController = Get.find();
  final ScrollController _controller = ScrollController();

  ClubListing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return clubsListingWidget();
  }

  Widget clubsListingWidget() {
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
        } else {
          if (!_clubsController.isLoadingClubs.value) {
            _clubsController.getClubs();
          }
        }
      }
    });

    return Obx(() => _clubsController.isLoadingClubs.value
        ? const ClubsScreenShimmer()
        : _clubsController.clubs.isEmpty
            ? Container()
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8),
                controller: _controller,
                padding: EdgeInsets.only(
                    left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 20, bottom: 100),
                itemCount: _clubsController.clubs.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext ctx, int index) {
                  return ClubCard(
                    club: _clubsController.clubs[index],
                    joinBtnClicked: () {
                      _clubsController.joinClub(_clubsController.clubs[index]);
                    },
                    leaveBtnClicked: () {
                      _clubsController.leaveClub(_clubsController.clubs[index]);
                    },
                    previewBtnClicked: () {
                      Get.to(() => ClubDetail(
                            club: _clubsController.clubs[index],
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
                // separatorBuilder: (BuildContext ctx, int index) {
                //   return const SizedBox(
                //     height: 25,
                //   );
                // }
              ));
  }
}
