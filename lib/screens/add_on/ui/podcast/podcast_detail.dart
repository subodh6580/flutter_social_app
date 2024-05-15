import 'package:cached_network_image/cached_network_image.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/controllers/podcast/podcast_streaming_controller.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart' as read_more;
import 'audio_song_player.dart';
import 'package:flutter/material.dart';

class PodcastDetail extends StatefulWidget {
  final PodcastModel podcastModel;

  const PodcastDetail({Key? key, required this.podcastModel})
      : super(key: key);

  @override
  State<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final PodcastStreamingController _podcastStreamingController = Get.find();
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _podcastStreamingController.getPodcastEpisode(
          podcastId: widget.podcastModel.id,callback: (){});
    });
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
    _podcastStreamingController.clearPodcastEpisodes();
  }

  loadMore(){
    _podcastStreamingController.getPodcastEpisode(
        podcastId: widget.podcastModel.id,callback: (){
      _refreshController.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              backNavigationBar(title: widget.podcastModel.name),
              Expanded(
                child: CustomScrollView(slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    podcastInfo(),
                    const SizedBox(
                      height: 40,
                    ),
                    Heading6Text(
                      episodesString.tr,
                      // color: AppColorConstants.themeColor,
                      weight: TextWeight.bold,
                    ).hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(() => SizedBox(
                          height: _podcastStreamingController
                                  .podcastEpisodes.length *
                              70,
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemCount: _podcastStreamingController
                                .podcastEpisodes.length,
                            itemBuilder: (BuildContext context, int index) {
                              return addRecord(index);
                            },
                            separatorBuilder: (ctx, index) {
                              return const SizedBox(
                                height: 10,
                              );
                            },
                          ).hp(DesignConstants.horizontalPadding),
                        )),
                  ]))
                ]).addPullToRefresh(
                    refreshController: _refreshController,
                    onRefresh: () {},
                    onLoading: () {
                      loadMore();
                    },
                    enablePullUp: true,
                    enablePullDown: false),
              )
            ]));
  }

  Widget podcastInfo() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: Get.width,
          height: 200,
          child: CachedNetworkImage(
            imageUrl: widget.podcastModel.image,
            fit: BoxFit.cover,
            width: Get.width,
            height: 200,
          )),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Container(
                    color: AppColorConstants.themeColor,
                    child: BodyLargeText(widget.podcastModel.ageGroup)
                        .setPadding(left: 10, right: 10, top: 5, bottom: 5))
                .round(10),
            const SizedBox(width: 10),
            Container(
                    color: AppColorConstants.themeColor,
                    child: BodyLargeText(widget.podcastModel.language)
                        .setPadding(left: 10, right: 10, top: 5, bottom: 5))
                .round(10),
          ],
        ),
        BodyLargeText(
          widget.podcastModel.name,
          weight: FontWeight.bold,
        ).vP16,
        read_more.ReadMoreText(
          widget.podcastModel.description,
          trimLines: 2,
          trimMode: read_more.TrimMode.Line,
          colorClickableText: Colors.white,
          trimCollapsedText: showMoreString.tr,
          style: TextStyle(fontSize: 14, color: AppColorConstants.mainTextColor),
          trimExpandedText: '    ${showLessString.tr}',
          moreStyle: TextStyle(
              fontSize: 14,
              color: AppColorConstants.mainTextColor,
              fontWeight: FontWeight.bold),
          lessStyle: TextStyle(
              fontSize: 14,
              color: AppColorConstants.mainTextColor,
              fontWeight: FontWeight.bold),
        ),
      ]).setPadding(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          top: 15),
    ]);
  }

  Widget addRecord(int index) {
    return Container(
      color: AppColorConstants.cardColor,
      height: 60,
      child: ListTile(
        contentPadding: const EdgeInsets.all(6),
        leading: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: _podcastStreamingController
                  .podcastEpisodes[index].imageUrl,
              fit: BoxFit.cover,
              height: 50,
              width: 50,
            ).round(10),
            const Positioned.fill(child: Icon(Icons.play_circle))
          ],
        ),
        title: BodyLargeText(
            _podcastStreamingController.podcastEpisodes[index].name),
        dense: true,
      ),
    ).round(10).ripple(() {
      Get.to(() => AudioSongPlayer(
          songsArray: _podcastStreamingController.podcastEpisodes,
          show: widget.podcastModel));
    });
  }
}
