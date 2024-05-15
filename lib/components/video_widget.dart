import 'dart:io';
import 'dart:math';
import 'package:chewie/chewie.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:video_player/video_player.dart';

import '../model/post_gallery.dart';

bool isMute = false;

class VideoPostTile extends StatefulWidget {
  final PostGallery? media;
  final double width;

  final String url;
  final bool isLocalFile;
  final bool play;
  final VoidCallback onTapActionHandler;

  const VideoPostTile(
      {Key? key,
        this.media,
        required this.width,
        required this.url,
        required this.isLocalFile,
        required this.play,
        required this.onTapActionHandler})
      : super(key: key);

  @override
  State<VideoPostTile> createState() => _VideoPostTileState();
}

class _VideoPostTileState extends State<VideoPostTile> {
  late Future<void> initializeVideoPlayerFuture;
  VideoPlayerController? videoPlayerController;

  // bool isPlayed = false;
  late bool playVideo;

  @override
  void initState() {
    super.initState();
    playVideo = widget.play;
    prepareVideo(url: widget.url, isLocalFile: widget.isLocalFile);
  }

  @override
  void didUpdateWidget(covariant VideoPostTile oldWidget) {
    prepareVideo(url: widget.url, isLocalFile: widget.isLocalFile);
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

  clear() {
    videoPlayerController?.pause();
    videoPlayerController?.dispose();
    videoPlayerController?.removeListener(checkVideoProgress);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isMute == true) {
          unMuteAudio();
        } else {
          muteAudio();
        }
        widget.onTapActionHandler();
      },
      child: Stack(
        children: [
          FutureBuilder(
            future: initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  height:
                  widget.width / videoPlayerController!.value.aspectRatio,
                  key: PageStorageKey(widget.url),
                  child: Chewie(
                    key: PageStorageKey(widget.url),
                    controller: ChewieController(
                      videoPlayerController: videoPlayerController!,
                      aspectRatio: videoPlayerController!.value.aspectRatio,
                      showControls: false,
                      autoInitialize: true,
                      looping: false,
                      autoPlay: false,
                      allowMuting: true,
                      placeholder: widget.media != null
                          ? CachedNetworkImage(
                        imageUrl: widget.media!.thumbnail,
                        fit: BoxFit.cover,
                        width: Get.width,
                        height: double.infinity,
                      )
                          : Container(),
                      errorBuilder: (context, errorMessage) {
                        return Center(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return widget.media == null
                    ? Container()
                    : CachedNetworkImage(
                  imageUrl: widget.media!.thumbnail,
                  fit: BoxFit.cover,
                  width: Get.width,
                );
              }
            },
          ),
          Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                height: 25,
                width: 25,
                color: Colors.black38,
                child: ThemeIconWidget(
                  isMute ? ThemeIcon.micOff : ThemeIcon.mic,
                  size: 15,
                  color: Colors.white,
                ),
              ).circular),
        ],
      ),
    );
  }

  prepareVideo({required String url, required bool isLocalFile}) {
    clear();
    if (videoPlayerController != null) {
      videoPlayerController!.pause();
    }

    if (isLocalFile) {
      videoPlayerController = VideoPlayerController.file(File(url));
    } else {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    }
    initializeVideoPlayerFuture = videoPlayerController!.initialize().then((_) {
      setState(() {});
    });

    videoPlayerController!.addListener(checkVideoProgress);
  }

  openFullScreen() {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return FullScreenVideoPostTile(
              videoPlayerController: videoPlayerController!);
        },
        fullscreenDialog: true));
  }

  unMuteAudio() {
    videoPlayerController!.setVolume(1);
    setState(() {
      isMute = false;
    });
  }

  muteAudio() {
    videoPlayerController!.setVolume(0);
    setState(() {
      isMute = true;
    });
  }

  play() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // isPlayed = false;
        playVideo = true;
      });
    });
    videoPlayerController!.play().then(
            (value) => {videoPlayerController!.addListener(checkVideoProgress)});

    if (isMute) {
      videoPlayerController!.setVolume(0);
    }
  }

  pause() {
    videoPlayerController!.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // isPlayed = true;
      });
    });
  }

  void checkVideoProgress() {
    if (videoPlayerController!.value.position ==
        const Duration(seconds: 0, minutes: 0, hours: 0)) {}

    if (videoPlayerController!.value.position ==
        videoPlayerController!.value.duration &&
        videoPlayerController!.value.duration >
            const Duration(milliseconds: 1)) {
      if (!mounted) return;

      setState(() {
        videoPlayerController!.removeListener(checkVideoProgress);

        // isPlayed = true;
      });
    }
  }
}

class FullScreenVideoPostTile extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const FullScreenVideoPostTile({
    Key? key,
    required this.videoPlayerController,
  }) : super(key: key);

  @override
  State<FullScreenVideoPostTile> createState() =>
      _FullScreenVideoPostTileState();
}

class _FullScreenVideoPostTileState extends State<FullScreenVideoPostTile> {
  // final VideoPostTileController videoPostTileController = Get.find();
  late Future<void> initializeVideoPlayerFuture;
  bool isPlayed = false;

  @override
  void initState() {
    super.initState();
  } // This closing tag was missing

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: double.infinity,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: const ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
            ).ripple(() {
              Navigator.of(context).pop();
            }),
          ),
        ).hp(DesignConstants.horizontalPadding),
        Expanded(
          key: UniqueKey(),
          child: Chewie(
            key: UniqueKey(),
            controller: ChewieController(
              videoPlayerController: widget.videoPlayerController,
              aspectRatio: widget.videoPlayerController.value.aspectRatio,
              showControls: false,
              // Prepare the video to be played and display the first frame
              autoInitialize: true,
              looping: false,
              autoPlay: false,

              // Errors can occur for example when trying to play a video
              // from a non-existent URL
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
}
