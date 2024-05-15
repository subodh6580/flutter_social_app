import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class ReplyTextChatTile extends StatelessWidget {
  final ChatMessageModel message;
  final Function(ChatMessageModel) replyMessageTapHandler;
  final Function(ChatMessageModel) messageTapHandler;

  const ReplyTextChatTile(
      {Key? key,
        required this.message,
        required this.replyMessageTapHandler,
        required this.messageTapHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            height: 70,
            color: message.isMineMessage
                ? AppColorConstants.disabledColor
                : AppColorConstants.themeColor,
            child: ReplyOriginalMessageTile(
              message: message.repliedOnMessage,
              replyMessageTapHandler: replyMessageTapHandler,
            )).round(8),
        const SizedBox(
          height: 10,
        ),
        BodyLargeText(
          message.textMessage,
          maxLines: 1,
        ).round(8),
      ],
    );
  }
}
