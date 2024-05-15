import 'package:foap/apiHandler/apis/rating_api.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:get/get.dart';
import '../../model/rating_model.dart';

class RatingController extends GetxController {
  RxList<RatingModel> ratings = <RatingModel>[].obs;

  int ratingsPage = 1;
  bool canLoadMoreRatings = true;
  bool ratingsIsLoading = false;

  clear() {
    ratingsPage = 1;
    canLoadMoreRatings = true;
    ratingsIsLoading = false;
  }

  getRatings({required int type, required int refId}) {
    if (canLoadMoreRatings) {
      ratingsIsLoading = true;
      RatingApi.getRatings(
          page: ratingsPage,
          type: type,
          refId: refId,
          resultCallback: (result, metadata) {
            ratingsIsLoading = false;
            ratings.addAll(result);
            ratings.unique((e) => e.id);
            canLoadMoreRatings = result.length >= metadata.perPage;
            ratingsPage += 1;
          });
    }
  }

  postRating(
      {required int type,
      required int refId,
      required double rating,
      required String review}) {
    RatingApi.submitRating(
        type: type, refId: refId, rating: rating, review: review);
  }
}
