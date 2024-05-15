import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class StickerChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const StickerChatTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 150,
        child:
            // message.media == null
            //     ?
            Align(
          alignment: message.isMineMessage
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: CachedNetworkImage(
            imageUrl: message.mediaContent.gif!,
            httpHeaders: const {'accept': 'image/*'},
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                AppUtil.addProgressIndicator(size:100),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ).setPadding(
              left: message.isMineMessage ? 0 : 20,
              right: message.isMineMessage ? 20 : 0),
        )
        // : Image.file(
        //     message.media!.file!,
        //     fit: BoxFit.cover,
        //   )
        // Image.memory(
        //   message.media!.mediaByte!,
        //   fit: BoxFit.cover,
        // ),
        ).round(10);
  }
}
