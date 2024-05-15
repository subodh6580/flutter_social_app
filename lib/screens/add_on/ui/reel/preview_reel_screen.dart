import 'package:chewie/chewie.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:foap/screens/post/add_post_screen.dart';
import 'package:foap/util/constant_util.dart';
import 'package:video_compress_ds/video_compress_ds.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';

class PreviewReelsScreen extends StatefulWidget {
  final File reel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const PreviewReelsScreen(
      {Key? key,
      required this.reel,
      this.audioId,
      this.audioStartTime,
      this.audioEndTime})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PreviewReelsState();
  }
}

class _PreviewReelsState extends State<PreviewReelsScreen> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.file(widget.reel);
    videoPlayerController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      chewieController = ChewieController(
        aspectRatio: videoPlayerController!.value.aspectRatio,
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        showOptions: false,
      );
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    chewieController!.dispose();
    videoPlayerController!.dispose();
    chewieController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
            // alignment: Alignment.topCenter,
            // fit: StackFit.loose,
            children: [
              const SizedBox(
                height: 50,
              ),
              chewieController == null
                  ? Container()
                  : SizedBox(
                      height: (Get.width - 32) /
                          videoPlayerController!.value.aspectRatio,
                      child: Chewie(
                        controller: chewieController!,
                      ),
                    ).round(20),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ThemeIconWidget(
                    ThemeIcon.backArrow,
                    size: 25,
                  ).circular.ripple(() {
                    Get.back();
                  }),
                  Container(
                          color: AppColorConstants.themeColor,
                          child: Text(
                            nextString.tr,
                            style: TextStyle(fontSize: FontSizes.b2),
                          ).setPadding(
                              left: DesignConstants.horizontalPadding,
                              right: DesignConstants.horizontalPadding,
                              bottom: 8,
                              top: 8))
                      .circular
                      .ripple(() {
                    submitReel();
                  }),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ]).hp(DesignConstants.horizontalPadding),
      ),
    );
  }

  submitReel() async {
    EasyLoading.show(status: loadingString.tr);
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: widget.reel.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      widget.reel.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false, // It's false by default
    );

    EasyLoading.dismiss();
    Media media = Media();
    media.id = randomId();
    media.file = File(mediaInfo!.path!);
    media.thumbnail = thumbnail;
    media.size = null;
    media.creationTime = DateTime.now();
    media.title = null;
    media.mediaType = GalleryMediaType.video;

    chewieController?.pause();

    Get.to(() => AddPostScreen(
          items: [media],
          isReel: true,
          audioId: widget.audioId,
          audioStartTime: widget.audioStartTime,
          audioEndTime: widget.audioEndTime,
          postType: PostType.reel,
        ));
  }
}
