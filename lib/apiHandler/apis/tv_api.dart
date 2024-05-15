import 'package:foap/apiHandler/api_wrapper.dart';
import 'package:foap/helper/imports/models.dart';

class TVModuleApi {
  static getTVCategories(
      {required Function(List<TvCategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getTVCategories;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];

        resultCallback(List<TvCategoryModel>.from(
            items.map((x) => TvCategoryModel.fromJson(x))));
      }
    });
  }

  static getTVShows(
      {int? liveTvId,
      String? name,
      required Function(List<TVShowModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getTVShows;

    if (liveTvId != null) {
      url = '$url&tv_channel_id=$liveTvId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var tvShows = result!.data['tv_show'];
        var items = tvShows['items'];
        resultCallback(
            List<TVShowModel>.from(items.map((x) => TVShowModel.fromJson(x))));
      }
    });
  }

  static getTVShowById(
      {int? showId, required Function(TVShowModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getTVShowById;

    if (showId != null) {
      url = '$url&id=$showId';
    }

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var tvShowDetails = result!.data['tvShowDetails'];
        resultCallback(TVShowModel.fromJson(tvShowDetails));
      }
    });
  }

  static getTVShowEpisodes(
      {int? showId,
      String? name,
      required Function(List<TVShowEpisodeModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getTVShowEpisodes;

    if (showId != null) {
      url = '$url&tv_show_id=$showId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var tvShowEpisode = result!.data['tvShowEpisode'];
        var items = tvShowEpisode['items'];
        // if (url == NetworkConstantsUtil.getTVShowEpisodes) {
          resultCallback(List<TVShowEpisodeModel>.from(
              items.map((x) => TVShowEpisodeModel.fromJson(x))));
        // }
      }
    });
  }

  static getTvCategories(int id) async {
    var url = NetworkConstantsUtil.postDetail;
    url = url.replaceAll('{id}', id.toString());
    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {}
    });
  }

  static getTvs(
      {int? categoryId,
      String? name,
      bool? isLive,
      required int page,
      required Function(List<TvModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.liveTvs;

    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (name != null) {
      url = '$url&name=$name';
    }
    if (isLive != null) {
      url = '$url&is_live=${isLive == true ? 1 : 0}';
    }

    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['live_tv']['items'];
        resultCallback(
            List<TvModel>.from(items.map((x) => TvModel.fromJson(x))),
            APIMetaData.fromJson(result.data['live_tv']['_meta']));
      }
    });
  }

  static getTVChannelById(
      {required int tvId, required Function(TvModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getTVChannel
        .replaceAll('{{channel_id}}', tvId.toString());

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var tvChannelDetail = result!.data['tvChannelDetails'];
        resultCallback(TvModel.fromJson(tvChannelDetail));
      }
    });
  }

  static likeUnlikeTv(bool like, int tvId) async {
    var url =
        (like ? NetworkConstantsUtil.favTv : NetworkConstantsUtil.unfavTv);

    ApiWrapper()
        .postApi(url: url, param: {"id": tvId.toString()}).then((result) {
      if (result?.success == true) {}
    });
  }

  static getFavLiveTvs(
      {required int page,
      required Function(List<TvModel>, APIMetaData) resultCallback}) async {
    var url = '${NetworkConstantsUtil.favTvList}?page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['live_tv']['items'];
        resultCallback(
            List<TvModel>.from(items.map((x) => TvModel.fromJson(x))),
            APIMetaData.fromJson(result.data['live_tv']['_meta']));
      }
    });
  }

  static getSubscribedLiveTvs(
      {required int page,
      required Function(List<TvModel>, APIMetaData) resultCallback}) async {
    var url = '${NetworkConstantsUtil.subscribedTvList}?page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['live_tv']['items'];
        resultCallback(
            List<TvModel>.from(items.map((x) => TvModel.fromJson(x))),
            APIMetaData.fromJson(result.data['live_tv']['_meta']));
      }
    });
  }

  static getTvBanners(
      {required Function(List<TVBannersModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.tvBanners;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var tvBanners = result!.data['tv_banner'];
        var items = tvBanners['items'];
        if (url == NetworkConstantsUtil.tvBanners) {
          resultCallback(List<TVBannersModel>.from(
              items.map((x) => TVBannersModel.fromJson(x))));
        }
      }
    });
  }

  static subscribeTv(
      {required TvModel tvModel,
      required Function(bool) resultCallback}) async {
    var url = NetworkConstantsUtil.subscribeLiveTv;

    ApiWrapper().postApi(url: url, param: {
      'id': tvModel.id.toString(),
      'transaction_id': ''
    }).then((result) {
      if (result?.success == true) {
        resultCallback(true);
      } else {
        resultCallback(false);
      }
    });
  }

  static stopWatchingTv(
      {required TvModel tvModel,
      required Function(bool) resultCallback}) async {
    var url = NetworkConstantsUtil.stopWatchingTv;

    ApiWrapper().postApi(url: url, param: {
      'id': tvModel.id.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback(true);
      } else {
        resultCallback(false);
      }
    });
  }
}
