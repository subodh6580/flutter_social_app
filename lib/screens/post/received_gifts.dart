import 'package:flutter/material.dart';
import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/reply_chat_cells/post_gift_controller.dart';
import '../../components/user_card.dart';
import '../../helper/localization_strings.dart';
//ignore: must_be_immutable
class ReceivedGiftsList extends StatelessWidget {
  int postId;
  final PostGiftController _postGiftController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ReceivedGiftsList({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          backNavigationBar(title: giftsReceivedString.tr),
          Expanded(child: giftersView())
        ],
      ),
    ).topRounded(40);
  }

  Widget giftersView() {
    return Obx(() => ListView.separated(
        padding:
             EdgeInsets.only(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 25, bottom: 100),
        itemCount: _postGiftController.stickerGifts.length,
        itemBuilder: (ctx, index) {
          return GifterUserTile(
            gift: _postGiftController.stickerGifts[index],
          );
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(height: 15);
        }).addPullToRefresh(
        refreshController: _refreshController,
        onRefresh: () {},
        onLoading: () {
          _postGiftController.fetchReceivedTimelineStickerGift(postId);
        },
        enablePullUp: true,
        enablePullDown: false));
  }
}
