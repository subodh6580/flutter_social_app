import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foap/components/sm_tab_bar.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/live_tv_model.dart';
import '../../components/live_tv_player.dart';
import '../../controllers/misc/rating_controller.dart';
import '../../model/tv_show_model.dart';
import 'package:foap/helper/imports/tv_imports.dart';

import '../misc/reviews.dart';

class TVShowDetail extends StatefulWidget {
  final TvModel tvModel;
  final TVShowModel showModel;

  const TVShowDetail({Key? key, required this.tvModel, required this.showModel})
      : super(key: key);

  @override
  State<TVShowDetail> createState() => _TVShowDetailState();
}

class _TVShowDetailState extends State<TVShowDetail> {
  final TvStreamingController _liveTvStreamingController = Get.find();
  final RatingController _ratingController = Get.find();

  TextEditingController messageTextField = TextEditingController();
  TextEditingController reviewTE = TextEditingController();
  double rating = 5;

  final List<String> tabs = [aboutString, ratingsString];

  @override
  void initState() {
    super.initState();
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

      _ratingController.getRatings(type: 1, refId: widget.showModel.id!);
      _liveTvStreamingController.getTvShowEpisodes(showId: widget.showModel.id);
    });
  }

  @override
  void dispose() {
    AutoOrientation.portraitAutoMode();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _ratingController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        AutoOrientation.portraitAutoMode();
      } else {
        AutoOrientation.landscapeAutoMode();
      }
      return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            children: [
              if (orientation == Orientation.portrait)
                Column(
                  children: [
                    backNavigationBar(
                      title: widget.showModel.name!,
                    ),
                    const SizedBox(height: 8,),
                  ],
                ),
              Obx(() {
                return _liveTvStreamingController.selectedEpisode.value != null
                    ? SocialifiedVideoPlayer(
                        tvModel: widget.tvModel,
                        url: _liveTvStreamingController
                            .selectedEpisode.value!.videoUrl!,
                        play: false,
                        orientation: orientation,

                        // showMinimumHeight: isKeyboardVisible,
                      )
                    : Container();
              }),
              if (orientation == Orientation.portrait)
                DefaultTabController(
                    length: tabs.length,
                    initialIndex: 0,
                    child: Column(
                      children: [
                        SMTabBar(tabs: tabs,canScroll: false),
                        divider(),
                        SizedBox(
                          height: Get.height * 0.5,
                          child: TabBarView(children: [
                            Expanded(child: detailView()),
                            ReviewsList()
                          ]),
                        ),
                      ],
                    )),
            ],
          ),
        );
      });
    });
  }

  Widget detailView() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      itemCount: _liveTvStreamingController.tvEpisodes.length + 1,
      itemBuilder: (BuildContext context, int index) {
        return index == 0
            ? episodeInfo()
            : episodeTile(_liveTvStreamingController.tvEpisodes[index - 1]);
      },
    );
  }

  episodeTile(TVShowEpisodeModel episode) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(6),
        leading: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: episode.imageUrl ?? '',
              fit: BoxFit.cover,
              height: 50,
              width: Get.width / 4.5,
            ),
            const Positioned.fill(child: Icon(Icons.play_circle))
          ],
        ),
        title: BodyLargeText(episode.name ?? ''),
        dense: true,
      ).ripple(() {
        _liveTvStreamingController.playEpisode(episode);
      }),
    ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, bottom: 5).round(10);
  }

  Widget episodeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                    color: AppColorConstants.themeColor,
                    child: BodyLargeText(widget.showModel.ageGroup ?? "")
                        .setPadding(left: 10, right: 10, top: 5, bottom: 5))
                .round(10),
            const SizedBox(width: 10),
            Container(
                    color: AppColorConstants.themeColor,
                    child: BodyLargeText(widget.showModel.language ?? "")
                        .setPadding(left: 10, right: 10, top: 5, bottom: 5))
                .round(10),
          ],
        ).bP25,
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    height: 25,
                    child:
                        Heading4Text(widget.showModel.ratingScore.toString())),
                const SizedBox(
                  height: 10,
                ),
                BodyLargeText(
                    '${widget.showModel.totalRatings.toString()} $ratingsString',
                    color: AppColorConstants.themeColor,
                    weight: TextWeight.bold),
              ],
            ),
            const SizedBox(
              width: 2,
              height: 50,
              // color: AppColorConstants.dividerColor,
            ).hP25,
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ThemeIconWidget(
                  ThemeIcon.thumbsUp,
                  size: 25,
                ),
                const SizedBox(
                  height: 10,
                ),
                BodyLargeText(
                  rateString,
                  color: AppColorConstants.themeColor,
                  weight: TextWeight.bold,
                ),
              ],
            ).ripple(() {
              showRatingView();
            })
          ],
        ).bP25,
        Row(
          children: [
            CachedNetworkImage(
              imageUrl: widget.showModel.imageUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ).round(10),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                BodyLargeText(
                  widget.showModel.name ?? '',
                  weight: TextWeight.semiBold,
                  // maxLines: 3,
                ),
              ],
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        BodyMediumText(
          widget.showModel.description ?? '',
          // maxLines: 3,
        ),
      ],
    ).p16;
  }

  showRatingView() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          color: AppColorConstants.backgroundColor,
          child: Container(
            height: 430,
            color: AppColorConstants.themeColor.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Heading5Text(
                  '$rateString ${widget.showModel.name}',
                ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, bottom: 16),
                ratingView(),
                reviewView(),
                AppThemeButton(
                  text: submitString,
                  onPress: () {
                    Navigator.of(context).pop();
                    _ratingController.postRating(
                        refId: widget.showModel.id!,
                        rating: rating,
                        review: reviewTE.text,
                        type: 1);
                  },
                ).hp(DesignConstants.horizontalPadding)
              ],
            ),
          ),
        ).topRounded(20);
      },
    );
  }

  Widget ratingView() {
    return RatingBar.builder(
      initialRating: 5,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      unratedColor: AppColorConstants.shadowColor,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (value) {
        rating = value;
      },
    );
  }

  Widget reviewView() {
    return AppTextField(
      controller: reviewTE,
      maxLines: 5,
      hintText: pleaseEnterMessageString,
    ).p(DesignConstants.horizontalPadding);
  }
}
