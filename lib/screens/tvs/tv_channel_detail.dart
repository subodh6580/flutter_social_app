import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/tv_imports.dart';
import 'package:foap/model/live_tv_model.dart';
import 'package:readmore/readmore.dart' as read_more;

import '../../components/live_tv_player.dart';
import '../../components/media_card.dart';
import '../../controllers/misc/rating_controller.dart';

class TVChannelDetail extends StatefulWidget {
  final TvModel tvModel;

  const TVChannelDetail({Key? key, required this.tvModel}) : super(key: key);

  @override
  State<TVChannelDetail> createState() => _TVChannelDetailState();
}

class _TVChannelDetailState extends State<TVChannelDetail> {
  final TvStreamingController _tvStreamingController = Get.find();

  @override
  void initState() {
    if (widget.tvModel.isLiveBroadcasting == true) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft
      ]);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add Your Code here.
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          AutoOrientation.portraitAutoMode();
        } else {
          AutoOrientation.landscapeAutoMode();
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tvStreamingController.setCurrentViewingTv(widget.tvModel);
      _tvStreamingController.getTvShows(liveTvId: widget.tvModel.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        AutoOrientation.portraitAutoMode();
      } else {
        AutoOrientation.landscapeAutoMode();
      }
      return Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 30,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ThemeIconWidget(
                        ThemeIcon.backArrow,
                        size: 18,
                        color: AppColorConstants.iconColor,
                      ),
                    ),
                  ).ripple(() {
                    Get.back();
                  }),
                  BodyLargeText(widget.tvModel.name, weight: TextWeight.medium),
                  Obx(() => ThemeIconWidget(
                        _tvStreamingController.currentViewingTv.value?.isFav ==
                                1
                            ? ThemeIcon.favFilled
                            : ThemeIcon.fav,
                        size: 18,
                        color: _tvStreamingController
                                    .currentViewingTv.value?.isFav ==
                                1
                            ? Colors.red
                            : AppColorConstants.iconColor,
                      ).ripple(() {
                        _tvStreamingController.favUnfavTv(
                            _tvStreamingController.currentViewingTv.value!);
                      })),
                ],
              ).setPadding(
                  left: DesignConstants.horizontalPadding,
                  right: DesignConstants.horizontalPadding,
                  top: 50,
                  bottom: 16),
              Expanded(
                child: ListView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.tvModel.isLiveBroadcasting == true
                                ? SocialifiedVideoPlayer(
                                    tvModel: widget.tvModel,
                                    url: widget.tvModel.tvUrl,
                                    play: true,
                                    orientation: orientation,
                                    isPlayingTv: true,
                                    // showMinimumHeight: isKeyboardVisible,
                                  )
                                : SizedBox(
                                    width: Get.width,
                                    height: 250,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.tvModel.image,
                                      fit: BoxFit.cover,
                                      width: Get.width,
                                      height: 200,
                                    )),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Heading6Text(
                                    widget.tvModel.name,
                                    weight: TextWeight.bold,
                                  ).bP25,
                                  read_more.ReadMoreText(
                                      widget.tvModel.description,
                                      trimLines: 2,
                                      trimMode: read_more.TrimMode.Line,
                                      colorClickableText: Colors.white,
                                      trimCollapsedText: showMoreString.tr,
                                      trimExpandedText:
                                          '    ${showLessString.tr}',
                                      style: TextStyle(
                                          fontSize: FontSizes.b2,
                                          fontWeight: TextWeight.regular,
                                          color:
                                              AppColorConstants.mainTextColor),
                                      moreStyle: TextStyle(
                                          fontSize: FontSizes.b2,
                                          fontWeight: TextWeight.bold,
                                          color:
                                              AppColorConstants.mainTextColor),
                                      lessStyle: TextStyle(
                                          fontSize: FontSizes.b2,
                                          fontWeight: TextWeight.bold,
                                          color:
                                              AppColorConstants.mainTextColor)),
                                  Heading5Text(
                                          '${moreFromString.tr} ${widget.tvModel.name}',
                                          weight: TextWeight.bold,
                                          color: AppColorConstants.themeColor)
                                      .setPadding(top: 15)
                                ]).setPadding(left: 15, right: 15, top: 15),
                          ]),
                      GetBuilder<TvStreamingController>(
                          init: _tvStreamingController,
                          builder: (ctx) {
                            return GridView.builder(
                                itemCount:
                                    _tvStreamingController.tvShows.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                // You won't see infinite size error
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10.0,
                                        mainAxisExtent: 180),
                                itemBuilder: (ctx, index) {
                                  MediaModel model = MediaModel(
                                      _tvStreamingController
                                          .tvShows[index].name,
                                      _tvStreamingController
                                          .tvShows[index].imageUrl,
                                      _tvStreamingController
                                          .tvShows[index].showTime);
                                  return MediaCard(model: model).ripple(() {
                                    Get.lazyPut(() => RatingController());

                                    Get.to(() => TVShowDetail(
                                        tvModel: widget.tvModel,
                                        showModel: _tvStreamingController
                                            .tvShows[index]));
                                  });
                                }).setPadding(left: 15, right: 15, bottom: 50);
                          }),
                    ]),
              ),
            ],
          ));
    });
  }
}
