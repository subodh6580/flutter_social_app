import 'package:chewie/chewie.dart';
import 'package:foap/helper/imports/common_import.dart';

import 'package:video_player/video_player.dart';
import '../controllers/tv/live_tv_streaming_controller.dart';
import '../model/live_tv_model.dart';
import '../screens/settings_menu/settings_controller.dart';

class SocialifiedVideoPlayer extends StatefulWidget {
  final String url;
  final bool play;
  final TvModel? tvModel;
  final Orientation orientation;
  final bool? isPlayingTv;

  const SocialifiedVideoPlayer({
    Key? key,
    required this.url,
    required this.play,
    required this.orientation,
    this.isPlayingTv,
    this.tvModel,
  }) : super(key: key);

  @override
  State<SocialifiedVideoPlayer> createState() => _SocialifiedVideoPlayerState();
}

class _SocialifiedVideoPlayerState extends State<SocialifiedVideoPlayer> {
  final TvStreamingController _liveTvStreamingController = Get.find();
  TextEditingController messageTextField = TextEditingController();
  final SettingsController _settingsController = Get.find();

  late Future<void> initializeVideoPlayerFuture;
  VideoPlayerController? videoPlayerController;
  bool isPlayed = false;
  late bool playVideo;
  bool isFreeTimePlayed = false;

  @override
  void initState() {
    super.initState();

    playVideo = widget.play;
    prepareVideo(url: widget.url);
  } // This closing tag was missing

  @override
  void didUpdateWidget(covariant SocialifiedVideoPlayer oldWidget) {
    playVideo = widget.play;

    if (playVideo == true) {
      play();
    } else {
      pause();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _liveTvStreamingController.toggleTopBar();
      },
      child: Stack(
        children: [
          SizedBox(
            height: widget.orientation == Orientation.portrait
                ? Get.width / videoPlayerController!.value.aspectRatio
                : Get.height,
            width: double.infinity,
            child: FutureBuilder(
              future: initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      Container(
                        key: PageStorageKey(widget.url),
                        child: Chewie(
                          key: PageStorageKey(widget.url),
                          controller: ChewieController(
                            allowFullScreen: false,
                            // fullScreenByDefault: true,
                            isLive:
                                widget.tvModel?.isLiveBroadcasting == true &&
                                    widget.isPlayingTv == true,
                            videoPlayerController: videoPlayerController!,
                            aspectRatio:
                                videoPlayerController!.value.aspectRatio,
                            showControls: true,
                            showOptions: false,
                            // Prepare the video to be played and display the first frame
                            autoInitialize: true,
                            looping: false,
                            autoPlay: false,

                            allowMuting: true,
                            // Errors can occur for example when trying to play a video
                            // from a non-existent URL
                            errorBuilder: (context, errorMessage) {
                              return Center(
                                child: BodyLargeText(
                                  errorMessage,
                                  color: AppColorConstants.subHeadingTextColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          if (isFreeTimePlayed &&
              widget.tvModel?.isLocked == true &&
              widget.orientation == Orientation.landscape)
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black38,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Heading4Text(
                        subscribeChannelToViewString.tr,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        width: 250,
                        child: AppThemeButton(
                          text:
                              '${subscribeUsingString.tr} (${widget.tvModel!.coinsNeededToUnlock} ${coinsString.tr})',
                          onPress: () {
                            _liveTvStreamingController
                                .subscribeTv(widget.tvModel!, (status) {
                              if (status == true) {
                                setState(() {
                                  widget.tvModel!.isSubscribed = 1;
                                  isFreeTimePlayed = false;

                                  AppUtil.showToast(
                                      message: youAreSubscribedNowString.tr,
                                      isSuccess: true);

                                  play();
                                });
                              }
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )),
          if (widget.orientation == Orientation.landscape)
            Obx(() => _liveTvStreamingController.showTopBar.value
                ? Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 80,
                      color: AppColorConstants.themeColor.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ThemeIconWidget(
                            ThemeIcon.backArrow,
                            size: 18,
                            color: AppColorConstants.iconColor,
                          ).ripple(() {
                            Get.back();
                          }),
                        ],
                      ).setPadding(left: DesignConstants.horizontalPadding, top: 28),
                    ),
                  )
                : Container())
        ],
      ),
    );
  }

  prepareVideo({required String url}) {
    if (videoPlayerController != null) {
      videoPlayerController!.pause();
    }

    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    initializeVideoPlayerFuture = videoPlayerController!.initialize().then((_) {
      setState(() {});

      if (playVideo == true) {
        play();
      } else {
        pause();
      }
    });

    // videoPlayerController!.addListener(checkVideoProgress);
  }

  play() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isPlayed = false;
        playVideo = true;
      });
    });
    isFreeTimePlayed = false;
    videoPlayerController!.play().then(
        (value) => {videoPlayerController!.addListener(checkVideoProgress)});

    _liveTvStreamingController.joinTv(widget.tvModel!.id);
  }

  void checkVideoProgress() {
    if (videoPlayerController!.value.position ==
        const Duration(seconds: 0, minutes: 0, hours: 0)) {}

    if (widget.tvModel!.isLocked == true &&
        videoPlayerController!.value.position >=
            Duration(
                seconds: int.parse(_settingsController
                    .setting.value!.freeLiveTvDurationToView!))) {
      if (!mounted) return;
      pause();
      isFreeTimePlayed = true;
      videoPlayerController!.removeListener(checkVideoProgress);
    }
  }

  pause() {
    videoPlayerController!.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isPlayed = true;
      });
    });
  }

  clear() {
    videoPlayerController!.pause();
    videoPlayerController!.dispose();
    // videoPlayerController!.removeListener(checkVideoProgress);
  }
}
