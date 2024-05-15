import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../manager/player_manager.dart';
import '../audio_progress_bar.dart';

class AudioChatTile extends StatefulWidget {
  final ChatMessageModel message;

  const AudioChatTile({Key? key, required this.message}) : super(key: key);

  @override
  State<AudioChatTile> createState() => _AudioChatTileState();
}

class _AudioChatTileState extends State<AudioChatTile> {
  final PlayerManager _playerManager = Get.find();

  @override
  void initState() {
    super.initState();
  }

  playAudio() {
    Audio audio = Audio(
        id: widget.message.localMessageId,
        url: widget.message.mediaContent.audio!);
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
                  widget.message.localMessageId.toString() &&
                  _playerManager.isPlaying.value
                  ? const ThemeIconWidget(
                ThemeIcon.pause,
                // color: Colors.white,
                size: 30,
              ).ripple(() {
                pauseAudio();
              })
                  : const ThemeIconWidget(
                ThemeIcon.play,
                // color: Colors.white,
                size: 30,
              ).ripple(() {
                playAudio();
              }),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: 200,
                height: 20,
                child: AudioProgressBar(
                  id: widget.message.localMessageId.toString(),
                ),
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
