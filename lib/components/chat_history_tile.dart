import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';

class ChatHistoryTile extends StatelessWidget {
  final ChatRoomModel model;

  const ChatHistoryTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  model.isGroupChat
                      ? Container(
                          color: AppColorConstants.themeColor,
                          height: 45,
                          width: 45,
                          child:
                              model.image == null || (model.image ?? '').isEmpty
                                  ? const ThemeIconWidget(
                                      ThemeIcon.group,
                                      color: Colors.white,
                                      size: 35,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: model.image!,
                                      height: 35,
                                      width: 35,
                                      fit: BoxFit.cover,
                                    ),
                        ).round(15)
                      : UserAvatarView(
                          size: 45,
                          user: model.opponent.userDetail,
                          onTapHandler: () {},
                        ),
                  // AvatarView(size: 50, url: model.opponent.picture),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Spacer(),
                        BodyLargeText(
                          model.isGroupChat
                              ? model.name!
                              : model.opponent.userDetail.userName,
                          maxLines: 1,
                          weight:TextWeight.medium,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        model.whoIsTyping.isNotEmpty
                            ? BodyMediumText(
                                '${model.whoIsTyping.join(',')} ${typingString.tr}',
                              )
                            : model.lastMessage == null
                                ? Container()
                                : messageTypeShortInfo(
                                    message: model.lastMessage!,
                                  ),
                        const Spacer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                model.unreadMessages > 0
                    ? Container(
                        height: 25,
                        width: 25,
                        color: AppColorConstants.themeColor,
                        child: Center(
                          child: BodyLargeText(
                            '${model.unreadMessages}',
                            weight: TextWeight.bold,
                          ),
                        ),
                      ).circular.bP8
                    : Container(),
                model.lastMessage == null
                    ? Container()
                    : BodyMediumText(
                        model.lastMessage!.messageTime,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ),
              ],
            ),
          ],
        ));
  }
}

class PublicChatGroupCard extends StatelessWidget {
  final ChatRoomModel room;
  final VoidCallback joinBtnClicked;
  final VoidCallback previewBtnClicked;
  final VoidCallback leaveBtnClicked;

  const PublicChatGroupCard(
      {Key? key,
        required this.room,
        required this.joinBtnClicked,
        required this.leaveBtnClicked,
        required this.previewBtnClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: room.image!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: room.image!,
                fit: BoxFit.cover,
              )
                  : Center(child: Heading1Text(room.name!.getInitials)),
            ).topRounded(10).ripple(() {
              previewBtnClicked();
            }),
          ),
          const SizedBox(
            height: 10,
          ),
          !room.amIGroupAdmin
              ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  children: [
                    BodyLargeText(
                      room.name!,
                      maxLines: 1,
                      weight: TextWeight.semiBold,
                    ).hP8,
                    const SizedBox(
                      height: 5,
                    ),
                    // BodySmallText(
                    //   '${room.totalMembers!.formatNumber} ${clubMembersString.tr}',
                    // ).hP8,
                  ],
                ),
              ),
              Container(
                  height: 50,
                  width: 50,
                  color: room.amIMember == true
                      ? AppColorConstants.red
                      : AppColorConstants.themeColor,
                  child: ThemeIconWidget(
                    room.amIMember == true
                        ? ThemeIcon.checkMark
                        : ThemeIcon.plus,
                    color: Colors.white,
                  )).topLeftDiognalRounded(20).ripple(() {
                if (room.amIMember == true) {
                  leaveBtnClicked();
                } else {
                  joinBtnClicked();
                }
              }),
            ],
          )
              : SizedBox(
              height: 50,
              width: 100,
              child: Center(
                child: BodyLargeText(
                  youAreAdminString,
                  color: AppColorConstants.themeColor,
                  weight: TextWeight.bold,
                ),
              )).hP4,
        ],
      ),
    ).round(15);
  }
}

