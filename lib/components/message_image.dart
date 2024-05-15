import 'dart:io';

import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class MessageImage extends StatelessWidget {
  final ChatMessageModel message;
  final BoxFit fitMode;
  final bool? disableRoundCorner;

  const MessageImage(
      {Key? key,
      required this.message,
      required this.fitMode,
      this.disableRoundCorner})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: getIt<FileManager>().localImagePathForMessage(message),
        // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return Image.file(
                File(snapshot.data!),
                fit: fitMode,
                width: double.infinity,
                height: double.infinity,
              ).round(disableRoundCorner == false ? 10 : 0);
            } else {
              return imageFromUrl();
            }
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              return imageFromUrl();
            } else {
              return AppUtil.addProgressIndicator(size:100);
            }
          }
        });
  }

  Widget imageFromUrl() {
    return CachedNetworkImage(
      imageUrl: message.messageContentType == MessageContentType.photo ||
              message.messageContentType == MessageContentType.video
          ? message.mediaContent.image!
          : message.mediaContent.gif!,
      httpHeaders: const {'accept': 'image/*'},
      fit: message.messageContentType == MessageContentType.photo ||
              message.messageContentType == MessageContentType.video
          ? BoxFit.cover
          : BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => AppUtil.addProgressIndicator(size:100),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    ).round(disableRoundCorner == false ? 10 : 0);
  }
}
