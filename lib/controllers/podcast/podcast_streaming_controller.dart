import 'dart:ui';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foap/apiHandler/apis/podcast_api.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/screens/add_on/model/podcast_banner_model.dart';
import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'package:get/get.dart';

import '../../helper/localization_strings.dart';

class PodcastStreamingController extends GetxController {
  RxList<PodcastBannerModel> banners = <PodcastBannerModel>[].obs;

  RxList<HostModel> hosts = <HostModel>[].obs;
  RxList<PodcastModel> podcasts = <PodcastModel>[].obs;
  RxList<PodcastEpisodeModel> podcastEpisodes = <PodcastEpisodeModel>[].obs;

  Rx<PodcastModel?> podcastDetail = Rx<PodcastModel?>(null);
  Rx<HostModel?> hostDetail = Rx<HostModel?>(null);

  int hostsPage = 1;
  bool canLoadMoreHosts = true;

  int podcastsPage = 1;
  bool canLoadMorePodcasts = true;

  int podcastEpisodePage = 1;
  bool canLoadMorePodcastEpisode = true;

  clearCategories() {
    update();
  }

  clearBanners() {
    banners.clear();
    update();
  }

  clearPodcastEpisodes() {
    podcastEpisodes.clear();
    podcastEpisodePage = 1;
    canLoadMorePodcastEpisode = true;
  }

  clearPodcasts() {
    podcasts.clear();
    podcastsPage = 1;
    canLoadMorePodcasts = true;
  }

  clearHosts() {
    hosts.clear();
    hostsPage = 1;
    canLoadMoreHosts = true;
    update();
  }

  // getPodcastCategories() {
  //   PodcastApi.getPodcastCategories(resultCallback: (result) {
  //     categories.value =
  //         result.where((element) => element.podcasts.isNotEmpty).toList();
  //     categories.refresh();
  //     update();
  //   });
  // }

  getPodcastBanners() {
    PodcastApi.getPodcastBanners(resultCallback: (result) {
      banners.value = result;
      update();
    });
  }

  getHostsList(
      {int? categoryId, String? name, required VoidCallback callback}) {
    if (canLoadMoreHosts) {
      PodcastApi.getHostsList(
          page: hostsPage,
          categoryId: categoryId,
          name: name,
          resultCallback: (result, metadata) {
            hosts.value = result;
            hosts.unique((e) => e.id);
            canLoadMoreHosts = result.length >= metadata.perPage;
            if (canLoadMoreHosts) {
              hostsPage += 1;
            }

            update();
            callback();
          });
    } else {
      callback();
    }
  }

  getPodcasts({int? podcastId, String? name, required VoidCallback callback}) {
    if (canLoadMorePodcasts) {
      PodcastApi.getPodcasts(
          page: podcastsPage,
          podcastId: podcastId,
          name: name,
          resultCallback: (result, metadata) {
            podcasts.value = result;

            podcasts.unique((e) => e.id);
            canLoadMorePodcasts = result.length >= metadata.perPage;
            if (canLoadMorePodcasts) {
              podcastsPage += 1;
            }

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  getPodcastEpisode(
      {int? podcastId,
      String? name,
      required VoidCallback callback}) async {
    if (canLoadMorePodcastEpisode) {
      PodcastApi.getPodcastEpisode(
          page: podcastEpisodePage,
          podcastId: podcastId,
          name: name,
          resultCallback: (result, metadata) {
            podcastEpisodes.value = result;
            podcastEpisodes.unique((e) => e.id);
            canLoadMorePodcastEpisode = result.length >= metadata.perPage;
            if (canLoadMorePodcastEpisode) {
              podcastEpisodePage += 1;
            }

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  getPodcastById(int id, Function(PodcastModel) completionCallBack) {
    EasyLoading.show(status: loadingString.tr);

    PodcastApi.getPodcastById(
        id: id,
        resultCallback: (result) {
          EasyLoading.dismiss();
          podcastDetail.value = result;
          update();
          completionCallBack(result);
        });
  }

  getHostById(int hostId, Function(HostModel) completionCallBack) {
    EasyLoading.show(status: loadingString.tr);

    PodcastApi.getPodcastHostById(
        hostId: hostId,
        resultCallback: (result) {
          EasyLoading.dismiss();

          hostDetail.value = result;
          update();
          completionCallBack(result);
        });
  }
}
