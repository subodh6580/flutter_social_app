import 'dart:ui';
import 'package:foap/apiHandler/api_wrapper.dart';

import '../../model/highlights.dart';

class HighlightsApi {
  static createHighlights(
      {required String name,
      required String image,
      required String stories,
      required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.addHighlight;

    var param = {
      "name": name,
      "image": image,
      "story_ids": stories,
    };

    ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static addSToryToHighlight({
    required int collectionId,
    required int postId,
  }) {
    var url = NetworkConstantsUtil.addStoryToHighlight;

    var param = {
      "collection_id": collectionId.toString(),
      "post_id": postId.toString(),
    };

    ApiWrapper().postApi(url: url, param: param).then((result) {});
  }

  static getHighlights(
      {required int userId,
      required Function(List<HighlightsModel>) resultCallback}) {
    var url = NetworkConstantsUtil.highlights + userId.toString();

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['highlight'];
          resultCallback(List<HighlightsModel>.from(
              items.map((x) => HighlightsModel.fromJson(x))));

      }
    });
  }

  static Future<void> deleteStoryFromHighlights(int id) async {
    var url = NetworkConstantsUtil.removeStoryFromHighlight;

    var param = {
      "id": id.toString(),
    };

    await ApiWrapper().postApi(url: url, param: param).then((result) {});
    return;
  }

  static Future<void> deleteHighlight(int id) async {
    var url = '${NetworkConstantsUtil.deleteHighlight}$id';

    await ApiWrapper().deleteApi(url: url).then((result) {});
    return;
  }
}
