import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class VideoChatTile extends StatelessWidget {
  final ChatMessageModel message;
  final bool? showSmall;

  const VideoChatTile({Key? key, required this.message, this.showSmall})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      // width: 280,
      child: Stack(
        children: [
          MessageImage(
            message: message,
            fitMode: BoxFit.cover,
          ).round(10),
          Container(
            color: Colors.black26,
            height: 280,
            width: double.infinity,
          ).round(10),
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: ThemeIconWidget(
                ThemeIcon.play,
                size: showSmall == true ? 20 : 80,
                color: Colors.white,
              )),
          message.messageStatusType == MessageStatus.sending
              ? Positioned(
                  child:
                      Center(child: AppUtil.addProgressIndicator(size:100)))
              : Container()
        ],
      ),
    );
  }
}
