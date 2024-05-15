import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../manager/player_manager.dart';
import '../audio_progress_bar.dart';

class ReplyAudioChatTile extends StatefulWidget {
  final ChatMessageModel message;
  final Function(ChatMessageModel) replyMessageTapHandler;

  const ReplyAudioChatTile(
      {Key? key, required this.message, required this.replyMessageTapHandler})
      : super(key: key);

  @override
  State<ReplyAudioChatTile> createState() => _ReplyAudioChatTileState();
}

class _ReplyAudioChatTileState extends State<ReplyAudioChatTile> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 70,
            color: widget.message.isMineMessage
                ? AppColorConstants.disabledColor
                : AppColorConstants.themeColor.withOpacity(0.2),
            child: ReplyOriginalMessageTile(
                message: widget.message.repliedOnMessage,
                replyMessageTapHandler: widget.replyMessageTapHandler))
            .round(8),
        const SizedBox(
          height: 10,
        ),
        Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _playerManager.currentlyPlayingAudio.value?.id ==
                widget.message.id.toString()
                ? const ThemeIconWidget(
              ThemeIcon.stop,
              color: Colors.white,
              size: 30,
            ).ripple(() {
              stopAudio();
            })
                : const ThemeIconWidget(
              ThemeIcon.play,
              color: Colors.white,
              size: 30,
            ).ripple(() {
              playAudio();
            }),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: SizedBox(
                height: 20,
                child: AudioProgressBar(id: widget.message.id.toString()),
              ),
            ),
            const SizedBox(
              width: 15,
            )
          ],
        )),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
