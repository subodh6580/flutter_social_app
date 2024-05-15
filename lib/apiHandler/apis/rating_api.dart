import '../../helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/rating_model.dart';
import '../api_wrapper.dart';

class RatingApi {
  static submitRating({
    required int type,
    required int refId,
    required double rating,
    required String review,
  }) {
    var url = NetworkConstantsUtil.postRating;

    ApiWrapper().postApi(url: url, param: {
      "type": type,
      "reference_id": refId,
      "rating": rating,
      "review": review,
    }).then((response) {
      if (response?.success == true) {}
    });
  }

  static getRatings(
      {required int page,
      required int type,
      required int refId,
      required Function(List<RatingModel>, APIMetaData) resultCallback}) {
    var url = NetworkConstantsUtil.ratingList;
    url = url.replaceAll('type', type.toString());
    url = url.replaceAll('reference_id', refId.toString());
    url = '$url&page=$page';

    EasyLoading.show(status: loadingString.tr);
    ApiWrapper().getApi(url: url).then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        var items = result!.data['rating']['items'];
        resultCallback(
            List<RatingModel>.from(items.map((x) => RatingModel.fromJson(x))),
            APIMetaData.fromJson(result.data['rating']['_meta']));
      }
    });
  }
}
