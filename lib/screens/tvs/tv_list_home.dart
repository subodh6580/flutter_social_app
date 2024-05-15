import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../controllers/misc/rating_controller.dart';
import '../../model/category_model.dart';
import '../../model/tv_banner_model.dart';
import 'package:foap/model/live_tv_model.dart';
import 'package:foap/helper/imports/tv_imports.dart';

class TvListHome extends StatefulWidget {
  const TvListHome({Key? key}) : super(key: key);

  @override
  State<TvListHome> createState() => _TvListHomeState();
}

class _TvListHomeState extends State<TvListHome> {
  final TvStreamingController _tvStreamingController = Get.find();
  final CarouselController _controller = CarouselController();
  int _current = 0;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _tvStreamingController.getTvCategories();
    _tvStreamingController.getTvBanners();
    loadTvsData();

    super.initState();
  }

  loadTvsData() {
    _tvStreamingController.getLiveTv(callback: () {
      _refreshController.loadComplete();
    });
  }

  @override
  void dispose() {
    _tvStreamingController.clearTvs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            backNavigationBar(title: tvsString.tr),
            const SizedBox(height: 8,),
            Expanded(
                child: GetBuilder<TvStreamingController>(
                    init: _tvStreamingController,
                    builder: (ctx) {
                      return CustomScrollView(
                        slivers: [
                          SliverList(
                              delegate: SliverChildListDelegate([
                            if (_tvStreamingController.banners.isNotEmpty)
                              banner(),
                            if (_tvStreamingController.tvs.isNotEmpty)
                              currentlyLiveTv(),
                            ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 100),
                                shrinkWrap: true,
                                itemCount:
                                    _tvStreamingController.categories.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return tvChannelsByCategory(
                                      _tvStreamingController.categories[index]);
                                })
                          ]))
                        ],
                      );
                    })),
          ],
        ));
  }

  banner() {
    return _tvStreamingController.banners.length == 1
        ? CachedNetworkImage(
            imageUrl: _tvStreamingController.banners.first.coverImageUrl ?? "",
            fit: BoxFit.cover,
            width: Get.width,
            height: 200,
          )
            .round(10)
            .setPadding(top: 10, bottom: 0, left: 15, right: 15)
            .ripple(() {
            bannerClickAction(_tvStreamingController.banners.first);
          })
        : Stack(children: [
            CarouselSlider(
              items: [
                for (TVBannersModel banner in _tvStreamingController.banners)
                  CachedNetworkImage(
                    imageUrl: banner.coverImageUrl ?? "",
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
                children:
                    _tvStreamingController.banners.asMap().entries.map((entry) {
                  return Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? AppColorConstants.themeColor
                                : Colors.grey)
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  ).ripple(() {
                    _controller.animateToPage(entry.key);
                  });
                }).toList(),
              ).alignBottomCenter,
            ),
          ]);
  }

  currentlyLiveTv() {
    return CarouselSlider(
      items: [
        for (TvModel tv in _tvStreamingController.tvs)
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: tv.image,
                fit: BoxFit.cover,
                width: Get.width,
                height: 200,
              ).backgroundCard().p16.ripple(() {
                Get.to(() => LiveTvPlayer(
                      tvModel: tv,
                    ));
              }),
              Positioned(
                  bottom: 25,
                  right: 25,
                  child: Image.asset(
                    'assets/live.png',
                    height: 28,
                  ))
            ],
          )
      ],
      options: CarouselOptions(
        autoPlayInterval: const Duration(seconds: 4),
        autoPlay: _tvStreamingController.tvs.length > 1,
        enlargeCenterPage: false,
        enableInfiniteScroll: _tvStreamingController.tvs.length > 1,
        height: 200,
        viewportFraction: _tvStreamingController.tvs.length > 1 ? 0.8 : 1,
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  tvChannelsByCategory(TvCategoryModel model) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Heading6Text(model.name, weight: TextWeight.medium)
              .setPadding(top: 20, bottom: 8, left: DesignConstants.horizontalPadding, right: 0),
          const Spacer(),
          const ThemeIconWidget(
            ThemeIcon.nextArrow,
            size: 15,
          ).rP16.ripple(() {
            Get.to(() => TvListByCategory(category: model));
          }),
        ],
      ),
      SizedBox(
        height: 170,
        child: ListView.separated(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: model.tvs.length,
          itemBuilder: (BuildContext context, int index) => CachedNetworkImage(
            imageUrl: model.tvs[index].image,
            fit: BoxFit.cover,
            height: 170,
            width: 180,
          ).round(10).ripple(() {
            Get.to(() => TVChannelDetail(
                  tvModel: model.tvs[index],
                ));
          }),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(width: 8);
          },
        ),
      ),
    ]);
  }

  bannerClickAction(TVBannersModel banner) {
    if (banner.bannerType == TvBannerType.show) {
      _tvStreamingController.getTvShowById(banner.referenceId!, () {
        _tvStreamingController.getTvChannelById(
            _tvStreamingController.showDetail.value!.tvChannelId!, () {
          if (_tvStreamingController.tvChannelDetail.value != null) {
            Get.lazyPut(() => RatingController());
            Get.to(() => TVShowDetail(
                tvModel: _tvStreamingController.tvChannelDetail.value!,
                showModel: _tvStreamingController.showDetail.value!));
          }
        });
        //find channel id in array
      });
    }
    // else {
    //   TvModel? tvModel;
    //   for (var category in _tvStreamingController.categories) {
    //     var foundTv = category.tvs
    //         .where((element) =>
    //             element.id ==
    //             _tvStreamingController.showDetail.value?.tvChannelId)
    //         .toList();
    //     if (foundTv.isNotEmpty) {
    //       tvModel = foundTv.first;
    //       break;
    //     }
    //   }
    //
    //   Get.to(() => TVChannelDetail(
    //         tvModel: tvModel!,
    //       ));
    // }
  }
}
