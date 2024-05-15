import 'package:foap/helper/list_extension.dart';
import 'package:get/get.dart';
import '../../apiHandler/apis/gift_api.dart';
import '../../model/gift_model.dart';
import '../../model/post_gift_model.dart';

class PostGiftController extends GetxController {
  RxList<PostGiftModel> timelineGift = <PostGiftModel>[].obs;
  RxList<ReceivedGiftModel> stickerGifts = <ReceivedGiftModel>[].obs;

  int giftsPage = 1;
  bool canLoadMoreGifts = true;
  bool isLoadingGifts = false;

  int receivedGiftsPage = 1;
  bool canLoadMoreReceivedGifts = true;
  bool isLoadingReceivedGifts = false;

  clear() {
    timelineGift.clear();
    giftsPage = 1;
    canLoadMoreGifts = true;
    isLoadingGifts = false;

    receivedGiftsPage = 1;
    canLoadMoreReceivedGifts = true;
    isLoadingReceivedGifts = false;
  }

  void fetchReceivedTimelineStickerGift(int postId) {
    if (canLoadMoreReceivedGifts) {
      GiftApi.getReceivedStickerGifts(
          page: receivedGiftsPage,
          sendOnType: 3,
          postId: postId,
          resultCallback: (result, metadata) {
            canLoadMoreReceivedGifts = result.length >= metadata.perPage;
            receivedGiftsPage += 1;
            stickerGifts.addAll(result);
            // stickerGifts.unique((e)=> e.giftDetail.id);

          },
          liveId: null);
    }
  }

  void fetchReceivedTimelineGift(int postId) {
    if (canLoadMoreReceivedGifts) {
      GiftApi.getTimelineReceivedTextGifts(
          page: receivedGiftsPage,
          sendOnType: 3,
          postId: postId,
          resultCallback: (result, metadata) {
            final postGift = result;
            canLoadMoreReceivedGifts = result.length >= metadata.perPage;
            receivedGiftsPage += 1;
            for (var item in postGift) {
              if (item.giftTimelineDetail != null) {
                timelineGift.add(item.giftTimelineDetail!);
              }
            }
          });
    }
  }

  void fetchTimelinePostGift() {
    if (canLoadMoreGifts) {
      GiftApi.getTimelineTextGifts(
          page: giftsPage,
          resultCallback: (result, metadata) {
            canLoadMoreReceivedGifts = result.length >= metadata.perPage;
            giftsPage += 1;

            timelineGift.addAll(result);
            timelineGift.unique((e)=> e.id);

          });
    }
  }
}
