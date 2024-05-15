import 'dart:ui';
import 'package:foap/apiHandler/api_wrapper.dart';
import '../../model/api_meta_data.dart';
import '../../model/story_model.dart';

class StoryApi {
  static postStory(
      {required List<Map<String, String>> gallery,
        required VoidCallback successHandler}) async {
    var url = NetworkConstantsUtil.addStory;

    var param = {
      "stories": gallery,
    };

    await ApiWrapper().postApi(url: url, param: param).then((status) {
      if (status?.success == true) {
        successHandler();
      }
    });
  }

  static getMyStories(
      {required Function(List<StoryMediaModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.myStories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['story']['items'];
        resultCallback(List<StoryMediaModel>.from(
            items.map((x) => StoryMediaModel.fromJson(x))));
      }
    });
  }

  static getStories(
      {required Function(List<StoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.stories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['story'];
        resultCallback(
            List<StoryModel>.from(items.map((x) => StoryModel.fromJson(x))));
      }
    });
  }

  static Future<void> getMyCurrentActiveStories(
      {required Function(List<StoryMediaModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.myCurrentActiveStories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['story']['items'];

        resultCallback(List<StoryMediaModel>.from(
            items.map((x) => StoryMediaModel.fromJson(x))));

        return;
      }
    });
  }

  static deleteStory({required int id, required VoidCallback callback}) async {
    var url = NetworkConstantsUtil.deleteStory + id.toString();

    await ApiWrapper().deleteApi(url: url).then((value) {
      callback();
    });
  }

  static viewStory({required int storyId}) {
    var url = NetworkConstantsUtil.viewStory;

    ApiWrapper()
        .postApi(url: url, param: {'story_id': storyId}).then((result) {});
  }

  static getStoryViewers(
      {required int storyId,
        required int page,
        required Function(List<StoryViewerModel>, APIMetaData)
        resultCallback}) async {
    var url = NetworkConstantsUtil.storyViewedByUsers;
    url = url.replaceAll('{{story_id}}', storyId.toString());
    url = '$url&page=$page';
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['story-view']['items'];
        resultCallback(
            List<StoryViewerModel>.from(
                items.map((x) => StoryViewerModel.fromJson(x))),
            APIMetaData.fromJson(result.data['story-view']['_meta']));
      }
    });
  }

  static getStoryDetail(
      {required int storyId,
        required Function(StoryModel) resultCallback}) async {
    var url = '${NetworkConstantsUtil.storyDetail}$storyId';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var story = result!.data['story'];
        resultCallback(StoryModel.fromJson(story));
      }
    });
  }
}
