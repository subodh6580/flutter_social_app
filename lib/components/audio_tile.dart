import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import '../../manager/player_manager.dart';

class AudioPostTile extends StatefulWidget {
  final PostModel post;

  const AudioPostTile({Key? key, required this.post}) : super(key: key);

  @override
  State<AudioPostTile> createState() => _AudioPostTileState();
}

class _AudioPostTileState extends State<AudioPostTile> {
  final PlayerManager _playerManager = Get.find();

  @override
  void initState() {
    super.initState();
  }

  playAudio() {
    Audio audio = Audio(
        id: widget.post.gallery.first.id.toString(),
        url: widget.post.gallery.first.filePath);
    _playerManager.playNetworkAudio(audio);
  }

  stopAudio() {
    _playerManager.stopAudio();
  }

  pauseAudio() {
    _playerManager.pauseAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _playerManager.currentlyPlayingAudio.value?.id ==
                          widget.post.gallery.first.id.toString() &&
                      _playerManager.isPlaying.value
                  ? const ThemeIconWidget(
                      ThemeIcon.pause,
                      color: Colors.white,
                      size: 30,
                    ).ripple(() {
                      pauseAudio();
                    })
                  : const ThemeIconWidget(
                      ThemeIcon.play,
                      color: Colors.white,
                      size: 30,
                    ).ripple(() {
                      playAudio();
                    }),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: 230,
                height: 20,
                child: AudioProgressBar(),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      );
    });
  }
}

class AudioProgressBar extends StatelessWidget {
  final PlayerManager _playerManager = Get.find();

  AudioProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressBar(
        thumbColor: AppColorConstants.themeColor.darken(),
        progressBarColor: AppColorConstants.iconColor,
        baseBarColor: AppColorConstants.backgroundColor.lighten(),
        thumbRadius: 8,
        barHeight: 2,
        progress: _playerManager.progress.value?.current ??
            const Duration(seconds: 0),
        // buffered: value.buffered,
        total:
            _playerManager.progress.value?.total ?? const Duration(seconds: 0),
        timeLabelPadding: 5,
        timeLabelTextStyle:
            TextStyle(fontSize: FontSizes.b4, fontWeight: TextWeight.bold),
        onDragUpdate: (detail) {
          _playerManager.pauseAudio();
          _playerManager
              .updateProgress(Duration(seconds: detail.timeStamp.inSeconds));
        },
        onDragEnd: () {
          // _playerManager.playAudio(audio);
        },
        // onSeek: pageManager.seek,
      );
    });
  }
}
