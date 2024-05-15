import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../../components/user_card.dart';

class GroupChatRoomDetail extends StatefulWidget {
  final ChatRoomModel chatRoom;

  const GroupChatRoomDetail({Key? key, required this.chatRoom})
      : super(key: key);

  @override
  State<GroupChatRoomDetail> createState() => _GroupChatRoomDetailState();
}

class _GroupChatRoomDetailState extends State<GroupChatRoomDetail> {
  final ChatRoomDetailController chatRoomDetailController = Get.find();
  final ChatDetailController chatDetailController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThemeIconWidget(
                  ThemeIcon.backArrow,
                  color: AppColorConstants.iconColor,
                  size: 20,
                ).p8.ripple(() {
                  Get.back();
                }),
                Heading5Text(
                  contactInfoString.tr,
                  weight: TextWeight.bold,
                  color: AppColorConstants.themeColor,
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ).hp(DesignConstants.horizontalPadding),
            divider().vP8,
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  roomInfo(),
                  const SizedBox(
                    height: 25,
                  ),
                  callWidgets(),
                  const SizedBox(
                    height: 50,
                  ),
                  mediaWidget(),
                  const SizedBox(
                    height: 50,
                  ),
                  participantsWidget(),
                  const SizedBox(
                    height: 50,
                  ),
                  extraOptionsWidget()
                ],
              ),
            )
          ],
        ));
  }

  Widget mediaWidget() {
    return Column(
      children: [
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    color: AppColorConstants.themeColor,
                    child: const ThemeIconWidget(
                      ThemeIcon.gallery,
                      color: Colors.white,
                    ).p4,
                  ).round(5),
                  const SizedBox(
                    width: 10,
                  ),
                  Heading5Text(mediaString.tr,
                      weight: TextWeight.medium),
                ],
              ),
              ThemeIconWidget(
                ThemeIcon.nextArrow,
                color: AppColorConstants.iconColor,
                size: 15,
              )
            ],
          ).hP8,
        ).ripple(() {
          Get.to(() => ChatMediaList(
                chatRoom: widget.chatRoom,
              ));
        }),
        divider(),
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    color: AppColorConstants.themeColor,
                    child: const ThemeIconWidget(
                      ThemeIcon.wallpaper,
                      color: Colors.white,
                    ).p4,
                  ).round(5),
                  const SizedBox(
                    width: 10,
                  ),
                  Heading5Text(wallpaperString.tr,
                      weight: TextWeight.medium),
                ],
              ),
              ThemeIconWidget(
                ThemeIcon.nextArrow,
                color: AppColorConstants.iconColor,
                size: 15,
              )
            ],
          ).hP8,
        ).ripple(() {
          Get.to(() => WallpaperForChatBackground(
                roomId: widget.chatRoom.id,
              ));
        }),
      ],
    ).round(10).backgroundCard( shadowOpacity: 0.1).hp(DesignConstants.horizontalPadding);
  }

  Widget extraOptionsWidget() {
    return Column(
      children: [
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Heading5Text(exportChatString.tr,
                  weight: TextWeight.medium)
            ],
          ).hP8,
        ).ripple(() {
          exportChatActionPopup();
        }),
        divider(),
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Heading5Text(
              deleteChatString.tr,
              weight: TextWeight.medium,
              color: AppColorConstants.red,
            ).hP8,
          ),
        ).ripple(() {
          chatRoomDetailController.deleteRoomChat(widget.chatRoom);
          AppUtil.showToast(
              message: chatDeletedString.tr,
              isSuccess: true);
        })
      ],
    ).round(10).backgroundCard( shadowOpacity: 0.1).hp(DesignConstants.horizontalPadding);
  }

  Widget callWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Column(
            children: [
              const ThemeIconWidget(
                ThemeIcon.mobile,
                size: 20,
              ),
              const SizedBox(
                height: 5,
              ),
              BodyMediumText(audioString.tr,
                  weight: TextWeight.medium),
            ],
          ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 8, bottom: 8),
        ).round(10).backgroundCard(shadowOpacity: 0.1).ripple(() {
          audioCall();
        }),
        const SizedBox(
          width: 20,
        ),
        Container(
          child: Column(
            children: [
              const ThemeIconWidget(
                ThemeIcon.videoCamera,
                size: 20,
              ),
              const SizedBox(
                height: 5,
              ),
              BodyMediumText(
                videoString.tr,
                  weight: TextWeight.medium

              ),
            ],
          ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 8, bottom: 8),
        ).round(10).backgroundCard(shadowOpacity: 0.1).ripple(() {
          videoCall();
        }),
      ],
    );
  }

  Widget roomInfo() {
    return Column(
      children: [
        UserAvatarView(
          user: widget.chatRoom.opponent.userDetail,
          size: 100,
          onTapHandler: () {
            //open live
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Heading6Text(widget.chatRoom.opponent.userDetail.userName,
            weight: TextWeight.bold)
      ],
    );
  }

  void exportChatActionPopup() {
    showModalBottomSheet(
        context: context,

        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: BodyLargeText(exportChatWithMediaString.tr)),
                    onTap: () async {
                      Get.back();
                      exportChatWithMedia();
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: BodyLargeText(exportChatWithoutMediaString.tr)),
                    onTap: () async {
                      Get.back();
                      exportChatWithoutMedia();
                    }),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(cancelString.tr)),
                    onTap: () => Get.back()),
              ],
            ));
  }

  Widget participantsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading5Text(
          '${widget.chatRoom.roomMembers.length} ${participantsString.tr}',

        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          height: widget.chatRoom.roomMembers.length * 50,
          color: AppColorConstants.cardColor,
          child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: widget.chatRoom.roomMembers.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) {
                return UserTile(
                        profile: widget.chatRoom.roomMembers[index].userDetail)
                    .hP8;
              },
              separatorBuilder: (ctx, index) {
                return divider().vP4;
              }).vP8,
        ).round(10).backgroundCard(shadowOpacity: 0.1),
      ],
    ).hp(DesignConstants.horizontalPadding);
  }

  void exportChatWithMedia() {
    chatRoomDetailController.exportChat(
        roomId: widget.chatRoom.id, includeMedia: true);
  }

  void exportChatWithoutMedia() {
    chatRoomDetailController.exportChat(
        roomId: widget.chatRoom.id, includeMedia: false);
  }

  void videoCall() {
    chatDetailController.initiateVideoCall();
  }

  void audioCall() {
    chatDetailController.initiateAudioCall();
  }
}
