import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class ReplyOriginalMessageTile extends StatelessWidget {
  final ChatMessageModel message;
  final Function(ChatMessageModel) replyMessageTapHandler;

  const ReplyOriginalMessageTile(
      {Key? key, required this.message, required this.replyMessageTapHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BodyLargeText(
                message.isMineMessage
                    ? youString.tr
                    : message.userName,
                weight: TextWeight.bold,
                color: AppColorConstants.themeColor.darken(0.5),
              ),
              const SizedBox(height: 15),
              messageTypeShortInfo(
                message: message,
              )
            ],
          ).p8,
        ),
        messageMainContent(message),
      ],
    ).ripple(() {
      replyMessageTapHandler(message);
    });
  }
}
