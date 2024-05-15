import 'package:foap/controllers/chat_and_call/chat_history_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_room_detail_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/chat/group/public_group_detail.dart';
import '../../../components/chat_history_tile.dart';

class PublicChatGroupListing extends StatelessWidget {
  final ChatHistoryController _chatHistoryController = Get.find();
  final ChatRoomDetailController _chatRoomDetailController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  final ScrollController _controller = ScrollController();

  PublicChatGroupListing({Key? key}) : super(key: key);

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
          if (!_chatHistoryController.publicGroupsDataWrapper.isLoading.value) {
            _chatHistoryController.loadMorePublicGroups(() {});
          }
        }
      }
    });

    return Obx(() => _chatHistoryController
            .publicGroupsDataWrapper.isLoading.value
        ? const ClubsScreenShimmer()
        : _chatHistoryController.publicGroups.isEmpty
            ? emptyData(title: noDataString, subTitle: '')
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8),
                controller: _controller,
                padding: EdgeInsets.only(
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    top: 20,
                    bottom: 150),
                itemCount: _chatHistoryController.publicGroups.length,
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext ctx, int index) {
                  return PublicChatGroupCard(
                    room: _chatHistoryController.publicGroups[index],
                    joinBtnClicked: () {
                      _chatRoomDetailController.addUsersToPublicRoom(
                          room: _chatHistoryController.publicGroups[index],
                          selectedFriends: [_userProfileManager.user.value!]);
                    },
                    leaveBtnClicked: () {
                      _chatRoomDetailController.leavePublicGroup(
                          _chatHistoryController.publicGroups[index]);
                    },
                    previewBtnClicked: () {
                      _chatRoomDetailController.setCurrentRoom(
                          _chatHistoryController.publicGroups[index]);
                      Get.to(() => const PublicGroupDetail());
                    },
                  );
                },
              ));
  }
}
