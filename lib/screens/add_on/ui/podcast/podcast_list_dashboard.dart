import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/components/empty_states.dart';
import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/controllers/podcast/podcast_streaming_controller.dart';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/screens/add_on/model/podcast_banner_model.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_host_detail.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_detail.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PodcastListDashboard extends StatefulWidget {
  const PodcastListDashboard({Key? key}) : super(key: key);

  @override
  State<PodcastListDashboard> createState() => _PodcastListDashboardState();
}

class _PodcastListDashboardState extends State<PodcastListDashboard> {
  final PodcastStreamingController _podcastStreamingController = Get.find();
  final CarouselController _controller = CarouselController();
  int _current = 0;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _podcastStreamingController.getHostsList(callback: () {});
    _podcastStreamingController.getPodcastBanners();
    super.initState();
  }

  loadMore() {
    _podcastStreamingController.getHostsList(callback: () {
      _refreshController.loadComplete();
    });
  }

  @override
  void dispose() {
    _podcastStreamingController.clearCategories();
    _podcastStreamingController.clearBanners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            backNavigationBar(title: hostsString.tr),
            Expanded(
                child: GetBuilder<PodcastStreamingController>(
                    init: _podcastStreamingController,
                    builder: (ctx) {
                      return CustomScrollView(slivers: [
                        SliverList(
                            delegate: SliverChildListDelegate([
                          if (_podcastStreamingController.banners.isNotEmpty)
                            banner(),
                          _podcastStreamingController.hosts.isEmpty
                              ? emptyData(title: noDataString.tr, subTitle: '')
                              : SizedBox(
                                  height: _podcastStreamingController
                                          .banners.isNotEmpty
                                      ? Get.height - 315
                                      : Get.height - 100,
                                  child: podcastHosts(),
                                )
                        ]))
                      ]).addPullToRefresh(
                          refreshController: _refreshController,
                          onRefresh: () {},
                          onLoading: () {
                            loadMore();
                          },
                          enablePullUp: true,
                          enablePullDown: false);
                    })),
          ],
        ));
  }

  banner() {
    return _podcastStreamingController.banners.length == 1
        ? CachedNetworkImage(
            imageUrl: _podcastStreamingController.banners[0].coverImageUrl!,
            fit: BoxFit.cover,
            width: Get.width,
            height: 200,
          )
            .round(10)
            .setPadding(top: 10, bottom: 15, left: 15, right: 15)
            .ripple(() {
            bannerClickAction(_podcastStreamingController.banners.first);
            //2 Show
            // int? showId = _podcastStreamingController.banners[0].referenceId;
          })
        : Stack(children: [
            CarouselSlider(
              items: [
                for (PodcastBannerModel banner
                    in _podcastStreamingController.banners)
                  CachedNetworkImage(
                    imageUrl: banner.coverImageUrl!,
                    fit: BoxFit.cover,
                    width: Get.width,
                    height: 200,
                  )
                      .round(10)
                      .setPadding(top: 10, bottom: 0, left: 10, right: 10)
                      .ripple(() {
                    bannerClickAction(banner);
                  })
              ],
              options: CarouselOptions(
                autoPlayInterval: const Duration(seconds: 4),
                autoPlay: true,
                enlargeCenterPage: false,
                enableInfiniteScroll: true,
                height: 200,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _podcastStreamingController.banners
                    .asMap()
                    .entries
                    .map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColorConstants.themeColor
                                  : Colors.grey)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ).alignBottomCenter,
            ),
          ]).bp(15);
  }

  Widget podcastHosts() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: _podcastStreamingController.hosts.length,
      itemBuilder: (BuildContext context, int index) => Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: _podcastStreamingController.hosts[index].image,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ).round(10),
          ),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            _podcastStreamingController.hosts[index].name,
            weight: TextWeight.semiBold,
            maxLines: 1,
          )
        ],
      ).ripple(() {
        Get.to(() => PodcastHostDetail(
              podcastModel: _podcastStreamingController.hosts[index],
            ));
      }),
    );
  }

  bannerClickAction(PodcastBannerModel banner) {
    if (banner.bannerType == PodcastBannerType.show) {
      _podcastStreamingController.getPodcastById(banner.referenceId!,
          (show) {
        Get.to(() => PodcastDetail(podcastModel: show));
        //find channel id in array
      });
    } else if (banner.bannerType == PodcastBannerType.host) {
      _podcastStreamingController.getHostById(
          banner.referenceId!,
          (host) => {
                if (_podcastStreamingController.hostDetail.value != null)
                  {Get.to(() => PodcastHostDetail(podcastModel: host))}
              });
    }
  }
}
