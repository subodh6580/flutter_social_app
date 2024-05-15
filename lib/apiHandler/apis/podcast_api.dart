import 'package:foap/apiHandler/api_wrapper.dart';

import '../../model/api_meta_data.dart';
import '../../model/category_model.dart';
import '../../screens/add_on/model/podcast_banner_model.dart';
import '../../screens/add_on/model/podcast_model.dart';

class PodcastApi {
  static getPodcastBanners(
      {required Function(List<PodcastBannerModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.podcastBanners;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var podcastBanners = result!.data['podcast_banner'];
        var items = podcastBanners['items'];
        if (url == NetworkConstantsUtil.podcastBanners) {
          resultCallback(List<PodcastBannerModel>.from(
              items.map((x) => PodcastBannerModel.fromJson(x))));
        }
      }
    });
  }

  static getPodcastCategories(
      {required Function(List<PodcastCategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcastCategories;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {}
      var items = result!.data['category'];

      resultCallback(List<PodcastCategoryModel>.from(
          items.map((x) => PodcastCategoryModel.fromJson(x))));
    });
  }

  static getHostsList(
      {required int page,
      int? categoryId,
      String? name,
      required Function(List<HostModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.getHosts;

    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var podcasts = result!.data['podcast'];
        var items = podcasts['items'];
        resultCallback(
            List<HostModel>.from(items.map((x) => HostModel.fromJson(x))),
            APIMetaData.fromJson(result.data['podcast']['_meta']));
      }
    });
  }

  static getPodcasts(
      {required int page,
      int? podcastId,
      String? name,
      required Function(List<PodcastModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcasts;

    if (podcastId != null) {
      url = '$url&podcast_channel_id=$podcastId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var podcasts = result!.data['podcast_show'];
        var items = podcasts['items'];
        resultCallback(
            List<PodcastModel>.from(items.map((x) => PodcastModel.fromJson(x))),
            APIMetaData.fromJson(result.data['podcast_show']['_meta']));
      }
    });
  }

  static getPodcastEpisode(
      {required int page,
      int? podcastId,
      String? name,
      required Function(List<PodcastEpisodeModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcastEpisode;

    if (podcastId != null) {
      url = '$url&podcast_show_id=$podcastId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var showEpisodes = result!.data['podcastShowEpisode'];
        var items = showEpisodes['items'];
        resultCallback(
            List<PodcastEpisodeModel>.from(
                items.map((x) => PodcastEpisodeModel.fromJson(x))),
            APIMetaData.fromJson(result.data['podcastShowEpisode']['_meta']));
      }
    });
  }

  static getPodcastById(
      {int? id, required Function(PodcastModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getHostShowById;

    if (id != null) {
      url = '$url&id=$id';
    }
    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var showDetails = result!.data['podcastShowDetails'];
        resultCallback(PodcastModel.fromJson(showDetails));
      }
    });
  }

  static getPodcastHostById(
      {required int hostId,
      required Function(HostModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getPodcastHostDetail
        .replaceAll('{{host_id}}', hostId.toString());

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var showDetails = result!.data['podcastHostDetails'];
        resultCallback(HostModel.fromJson(showDetails));
      }
    });
  }
}
