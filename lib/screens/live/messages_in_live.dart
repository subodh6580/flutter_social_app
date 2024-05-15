import '../../controllers/live/agora_live_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/chat_message_model.dart';

class MessagesInLive extends StatelessWidget {
  final AgoraLiveController _agoraLiveController = Get.find();

  MessagesInLive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: Get.height / 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.7)
          ],
        ),
      ),
      child: GetBuilder<AgoraLiveController>(
          init: _agoraLiveController,
          builder: (ctx) {
            return ListView.separated(
                padding: EdgeInsets.only(
                    top: 10, bottom: 50, left: DesignConstants.horizontalPadding, right: 70),
                itemCount: _agoraLiveController.messages.length,
                itemBuilder: (ctx, index) {
                  ChatMessageModel message =
                      _agoraLiveController.messages[index];
                  if (message.messageContentType == MessageContentType.gift) {
                    return giftMessageTile(message);
                  }
                  return textMessageTile(message);
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 10,
                  );
                });
          }),
    );
  }

  Widget giftMessageTile(ChatMessageModel message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AvatarView(size: 25, url: message.userPicture, name: message.userName),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(
                message.userName,
                weight: TextWeight.semiBold,
                color: AppColorConstants.subHeadingTextColor,
              ),
              Row(
                children: [
                  BodySmallText(
                    sentAGiftString.tr,
                    color: AppColorConstants.subHeadingTextColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  CachedNetworkImage(
                    imageUrl: message.giftContent.image,
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodySmallText(
                    message.giftContent.coins.toString(),
                    color: AppColorConstants.subHeadingTextColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const ThemeIconWidget(
                    ThemeIcon.diamond,
                    color: Colors.yellow,
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget textMessageTile(ChatMessageModel message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AvatarView(size: 25, url: message.userPicture, name: message.userName),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(
                message.userName,
                weight: TextWeight.semiBold,
                color: AppColorConstants.subHeadingTextColor,
              ),
              BodySmallText(
                message.decrypt,
                color: AppColorConstants.subHeadingTextColor,
              ),
            ],
          ),
        )
      ],
    );
  }
}
