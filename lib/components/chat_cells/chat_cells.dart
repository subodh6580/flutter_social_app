import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChatMessageTile extends StatelessWidget {
  final ChatMessageModel message;
  final bool showName;
  final bool actionMode;
  final ChatDetailController chatDetailController = Get.find();
  final Function(ChatMessageModel) replyMessageTapHandler;
  final Function(ChatMessageModel) messageTapHandler;

  ChatMessageTile(
      {Key? key,
      required this.message,
      required this.showName,
      required this.actionMode,
      required this.replyMessageTapHandler,
      required this.messageTapHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return message.messageContentType == MessageContentType.groupAction
        ? ChatGroupActionCell(message: message)
        : Row(
            children: [
              actionMode
                  ? Obx(() => Row(
                        children: [
                          ThemeIconWidget(
                            chatDetailController.isSelected(message)
                                ? ThemeIcon.checkMarkWithCircle
                                : ThemeIcon.circleOutline,
                            size: 20,
                            color: AppColorConstants.disabledColor,
                          ).ripple(() {
                            chatDetailController.selectMessage(message);
                          }),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      ))
                  : Container(),
              // message.isMineMessage ? const Spacer() : Container(),
              Expanded(
                child: Container(
                  color: message.messageContentType == MessageContentType.gif ||
                          message.messageContentType ==
                              MessageContentType.sticker
                      ? Colors.transparent
                      : message.isMineMessage
                          ? AppColorConstants.backgroundColor
                          : AppColorConstants.themeColor.darken(0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      showName ? nameWidget(context) : Container(),
                      message.messageContentType == MessageContentType.forward
                          ? Row(
                              children: [
                                ThemeIconWidget(
                                  ThemeIcon.fwd,
                                  size: 15,
                                  color: AppColorConstants.iconColor,
                                ).rotate(-40).rP4,
                                BodyLargeText(
                                  forwardString.tr,
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 5,
                      ),
                      message.isDeleted == true
                          ? deletedMessageWidget()
                          : message.isReply
                              ? replyContentWidget()
                              : contentWidget(message).ripple(() {
                                  messageTapHandler(message);
                                }),
                      const SizedBox(
                        height: 5,
                      ),
                      MessageDeliveryStatusView(message: message),
                    ],
                  ).p8,
                ).round(10).setPadding(
                    left: message.isMineMessage ? 50 : 0,
                    right: message.isMineMessage ? 0 : 50),
              ),
              // message.isMineMessage ? Container() : const Spacer(),
            ],
          );
  }

  Widget deletedMessageWidget() {
    return DeletedMessageChatTile(message: message);
  }

  Widget replyContentWidget() {
    if (message.messageReplyContentType == MessageContentType.text) {
      return ReplyTextChatTile(
        message: message,
        messageTapHandler: messageTapHandler,
        replyMessageTapHandler: replyMessageTapHandler,
      );
    } else if (message.messageReplyContentType == MessageContentType.photo) {
      return ReplyImageChatTile(
          message: message,
          messageTapHandler: messageTapHandler,
          replyMessageTapHandler: replyMessageTapHandler);
    } else if (message.messageReplyContentType == MessageContentType.gif) {
      return ReplyStickerChatTile(
          message: message,
          messageTapHandler: messageTapHandler,
          replyMessageTapHandler: replyMessageTapHandler);
    } else if (message.messageReplyContentType == MessageContentType.video) {
      return ReplyVideoChatTile(
          message: message,
          messageTapHandler: messageTapHandler,
          replyMessageTapHandler: replyMessageTapHandler);
    } else if (message.messageReplyContentType == MessageContentType.audio) {
      return ReplyAudioChatTile(
          message: message, replyMessageTapHandler: replyMessageTapHandler);
    } else if (message.messageReplyContentType == MessageContentType.contact) {
      return ReplyContactChatTile(
          message: message,
          messageTapHandler: messageTapHandler,
          replyMessageTapHandler: replyMessageTapHandler);
    } else if (message.messageReplyContentType ==
        MessageContentType.location) {
      return ReplyLocationChatTile(
          message: message,
          messageTapHandler: messageTapHandler,
          replyMessageTapHandler: replyMessageTapHandler);
    } else if (message.messageReplyContentType == MessageContentType.profile) {
      return ReplyUserProfileChatTile(
          message: message,
          messageTapHandler: messageTapHandler,
          replyMessageTapHandler: replyMessageTapHandler);
    } else if (message.messageReplyContentType == MessageContentType.file) {
      return ReplyFileChatTile(
          message: message,
          messageTapHandler: messageTapHandler,
          replyMessageTapHandler: replyMessageTapHandler);
    }
    return TextChatTile(message: message);
  }

  Widget contentWidget(ChatMessageModel messageModel) {
    if (messageModel.messageContentType == MessageContentType.text) {
      return TextChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.photo) {
      return ImageChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.gif) {
      return StickerChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.video) {
      return VideoChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.audio) {
      return AudioChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.post) {
      return PostChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.location) {
      return LocationChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.forward) {
      return contentWidget(messageModel.originalMessage);
    } else if (messageModel.messageContentType == MessageContentType.contact) {
      return ContactChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.profile) {
      return UserProfileChatTile(message: messageModel);
    } else if (messageModel.messageContentType == MessageContentType.file) {
      return FileChatTile(message: messageModel);
    }
    return TextChatTile(message: message);
  }

  Widget nameWidget(BuildContext context) {
    return BodyLargeText(
      message.isMineMessage ? youString.tr : message.sender!.userName,
      weight: TextWeight.bold,

    );
  }
}

class MessageDeliveryStatusView extends StatelessWidget {
  final ChatMessageModel message;

  const MessageDeliveryStatusView({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatDetailController chatDetailController = Get.find();

    return VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;

          if (!message.isMineMessage && visiblePercentage > 90) {
            if (message.messageStatusType != MessageStatus.read &&
                message.messageContentType != MessageContentType.groupAction &&
                !message.isDateSeparator) {
              chatDetailController.sendMessageAsRead(message);
              message.status = 3;
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            message.isStar == 1
                ? ThemeIconWidget(
                    ThemeIcon.filledStar,
                    color: AppColorConstants.themeColor,
                    size: 15,
                  ).rP4
                : Container(),
            BodySmallText(
              message.messageTime,
              weight:TextWeight.medium,
            ),
            const SizedBox(
              width: 5,
            ),
            message.isMineMessage
                ? ThemeIconWidget(
                    message.messageStatusType == MessageStatus.sent
                        ? ThemeIcon.sent
                        : message.messageStatusType == MessageStatus.delivered
                            ? ThemeIcon.delivered
                            : message.messageStatusType == MessageStatus.read
                                ? ThemeIcon.read
                                : ThemeIcon.sending,
                    size: 15,
                    color: message.messageStatusType == MessageStatus.read
                        ? Colors.blue
                        : AppColorConstants.iconColor,
                  )
                : Container(),
          ],
        ));
  }
}
