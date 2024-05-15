import 'package:foap/apiHandler/apis/gift_api.dart';
import 'package:get/get.dart';
import '../../model/category_model.dart';
import '../../model/gift_model.dart';

class GiftController extends GetxController {
  RxList<GiftCategoryModel> giftsCategories = <GiftCategoryModel>[].obs;
  RxList<GiftModel> gifts = <GiftModel>[].obs;
  RxList<GiftModel> topGifts = <GiftModel>[].obs;

  RxInt selectedSegment = 0.obs;

  segmentChanged(int segment) {
    selectedSegment.value = segment;
    loadGifts(giftsCategories[segment].id);
  }

  loadGiftCategories() {
    gifts.clear();
    update();
    GiftApi.getStickerGiftCategories(resultCallback: (result) {
      giftsCategories.value = result;
      loadGifts(giftsCategories.first.id);
    });
  }

  loadMostUsedGifts() {
    GiftApi.getMostUsedStickerGifts(resultCallback: (result) {
      topGifts.value = result;

      update();
    });
  }

  loadGifts(int categoryId) {
    GiftApi.getStickerGiftsByCategory(categoryId, resultCallback: (result) {
      gifts.value = result;

      update();
    });
  }
}
