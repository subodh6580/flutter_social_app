import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class ImageChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const ImageChatTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: MessageImage(
            message: message,
            fitMode: BoxFit.cover,
          ),
        ).round(10),
        message.messageStatusType == MessageStatus.sending
            ? Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child:
                    Center(child: AppUtil.addProgressIndicator(size:100)))
            : Container()
      ],
    );
  }
}
