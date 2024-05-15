import '../../model/api_meta_data.dart';
import '../../model/category_model.dart';
import '../../screens/add_on/model/reel_music_model.dart';
import '../api_wrapper.dart';

class ReelApi {
  static getReelCategories(
      {required Function(List<CategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.reelAudioCategories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];

        resultCallback(List<CategoryModel>.from(
            items.map((x) => CategoryModel.fromJson(x))));
      }
    });
  }

  static getAudios(
      {int? categoryId,
      String? title,
      required Function(List<ReelMusicModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.audios;
    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (title != null) {
      url = '$url&name=$title';
    }

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['audio']['items'];
          resultCallback(
              List<ReelMusicModel>.from(
                  items.map((x) => ReelMusicModel.fromJson(x))),
              APIMetaData.fromJson(result.data['audio']['_meta']));

      }
    });
  }
}
