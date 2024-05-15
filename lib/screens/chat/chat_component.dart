import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';

Widget messageTypeShortInfo({
  required ChatMessageModel message,
}) {
  return message.messageContentType == MessageContentType.reply
      ? messageTypeShortInfoFromType(
          type: message.messageReplyContentType,
          message: message,
        )
      : messageTypeShortInfoFromType(
          message: message, type: message.messageContentType);
}

Widget messageTypeShortInfoFromType({
  required ChatMessageModel message,
  required MessageContentType type,
}) {
  return type == MessageContentType.text
      ? BodyMediumText(
          message.textMessage,
          maxLines: 1,
        )
      : type == MessageContentType.photo
          ? Row(
              children: [
                const ThemeIconWidget(
                  ThemeIcon.camera,
                  size: 12,
                ).rP4,
                BodyMediumText(photoString.tr,
                    maxLines: 1, weight: TextWeight.regular),
              ],
            )
          : type == MessageContentType.video
              ? Row(
                  children: [
                    const ThemeIconWidget(ThemeIcon.videoPost, size: 15).rP4,
                    BodyMediumText(videoString.tr,
                        maxLines: 1, weight: TextWeight.regular),
                  ],
                )
              : type == MessageContentType.gif ||
                      type == MessageContentType.sticker
                  ? Row(
                      children: [
                        const ThemeIconWidget(ThemeIcon.gif, size: 15).rP4,
                        BodyMediumText(gifString.tr,
                            maxLines: 1, weight: TextWeight.regular),
                      ],
                    )
                  : type == MessageContentType.post
                      ? Row(
                          children: [
                            const ThemeIconWidget(
                              ThemeIcon.camera,
                              size: 15,
                            ).rP4,
                            BodyMediumText(postString.tr,
                                maxLines: 1, weight: TextWeight.regular),
                          ],
                        )
                      : type == MessageContentType.audio
                          ? Row(
                              children: [
                                const ThemeIconWidget(ThemeIcon.mic, size: 15)
                                    .rP4,
                                BodyMediumText(audioString.tr,
                                    maxLines: 1, weight: TextWeight.regular),
                              ],
                            )
                          : type == MessageContentType.contact
                              ? Row(
                                  children: [
                                    const ThemeIconWidget(ThemeIcon.contacts,
                                            size: 15)
                                        .rP4,
                                    BodyMediumText(
                                      contactString.tr,
                                      maxLines: 1,
                                      weight: TextWeight.regular,
                                    ),
                                  ],
                                )
                              : type == MessageContentType.location
                                  ? Row(
                                      children: [
                                        const ThemeIconWidget(
                                                ThemeIcon.location,
                                                size: 15)
                                            .rP4,
                                        BodyMediumText(
                                            locationString.tr,
                                            maxLines: 1,
                                            weight: TextWeight.regular),
                                      ],
                                    )
                                  : type == MessageContentType.file
                                      ? Row(
                                          children: [
                                            const ThemeIconWidget(
                                                    ThemeIcon.files,
                                                    size: 15)
                                                .rP4,
                                            BodyMediumText(
                                                fileString.tr,
                                                maxLines: 1,
                                                weight: TextWeight.regular),
                                          ],
                                        )
                                      : type == MessageContentType.profile
                                          ? Row(
                                              children: [
                                                const ThemeIconWidget(
                                                        ThemeIcon.account,
                                                        size: 15)
                                                    .rP4,
                                                BodyMediumText(
                                                    profileString.tr,
                                                    maxLines: 1,
                                                    weight: TextWeight.regular),
                                              ],
                                            )
                                          : Container();
}

Widget messageMainContent(ChatMessageModel message) {
  if (message.messageContentType == MessageContentType.forward) {
    return messageMainContent(message.originalMessage);
  }

  return message.messageContentType == MessageContentType.text
      ? Container()
      : message.messageContentType == MessageContentType.photo
          ? SizedBox(
              height: 60, width: 60, child: ImageChatTile(message: message).p8)
          : message.messageContentType == MessageContentType.video
              ? SizedBox(
                  height: 60,
                  width: 60,
                  child: VideoChatTile(
                    message: message,
                    showSmall: true,
                  ).p8)
              : message.messageContentType == MessageContentType.gif ||
                      message.messageContentType == MessageContentType.sticker
                  ? SizedBox(
                      height: 60,
                      width: 60,
                      child: StickerChatTile(message: message).p8)
                  : message.messageContentType == MessageContentType.post
                      ? SizedBox(
                          height: 60,
                          width: 60,
                          child: MinimalInfoPostChatTile(message: message).p8)
                      : message.messageContentType ==
                              MessageContentType.location
                          ? SizedBox(
                              height: 60,
                              width: 60,
                              child: LocationChatTile(message: message).p8)
                          : Container();
}
