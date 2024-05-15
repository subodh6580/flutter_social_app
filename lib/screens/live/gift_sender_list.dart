import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/user_card.dart';
import '../../controllers/live/agora_live_controller.dart';

class GiftSenders extends StatelessWidget {
  final AgoraLiveController _agoraLiveController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final int liveId;
  final int? battleId;

  GiftSenders({Key? key, required this.liveId, this.battleId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Heading4Text(
          giftsReceivedString.tr,
          weight: TextWeight.semiBold,
        ),
        Container(
          height: 5,
          width: 180,
          color: AppColorConstants.themeColor,
        ).round(10).tP8,
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: Obx(() => Container(
                color: AppColorConstants.cardColor,
                child: ListView.separated(
                    padding:  EdgeInsets.only(
                        left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 25, bottom: 100),
                    itemCount: _agoraLiveController.giftsReceived.length,
                    itemBuilder: (ctx, index) {
                      return GifterUserTile(
                        gift: _agoraLiveController.giftsReceived[index],
                      );
                    },
                    separatorBuilder: (ctx, index) {
                      return const SizedBox(height: 15);
                    }).addPullToRefresh(
                    refreshController: _refreshController,
                    onRefresh: () {},
                    onLoading: () {
                      _agoraLiveController.loadGiftsReceived(
                          liveId: liveId, battleId: battleId);
                    },
                    enablePullUp: true,
                    enablePullDown: false),
              ).topRounded(50)),
        ),
      ],
    );
  }
}
