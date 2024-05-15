import 'package:flutter_contacts/contact.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foap/helper/imports/common_import.dart';

import 'package:foap/helper/imports/chat_imports.dart';
import 'package:map_launcher/map_launcher.dart';
import '../competitions/video_player_screen.dart';
import '../post/single_post_detail.dart';
import '../profile/other_user_profile.dart';

class StarredMessages extends StatefulWidget {
  final ChatRoomModel? chatRoom;

  const StarredMessages({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<StarredMessages> createState() => _StarredMessagesState();
}

class _StarredMessagesState extends State<StarredMessages> {
  final ChatRoomDetailController _chatRoomDetailController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            appBar(),
            const SizedBox(height: 8,),
            Expanded(child: messagesListView()),
            Obx(() {
              return _chatDetailController.actionMode.value ==
                      ChatMessageActionMode.edit
                  ? selectedMessageView()
                  : Container();
            })
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
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
            const Spacer(),
            BodyLargeText(
              editString.tr,
                weight: TextWeight.medium
            ).p8.ripple(() {
              _chatDetailController.setToActionMode(
                  mode: ChatMessageActionMode.edit);
            }),
          ],
        ).hp(DesignConstants.horizontalPadding),
        Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: BodyLargeText(
                starredMessagesString.tr,
              ),
            ))
      ],
    );
  }

  Widget selectedMessageView() {
    return Container(
      color: AppColorConstants.backgroundColor.darken(0.02),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BodyLargeText(
            deleteString.tr,
              weight: TextWeight.bold
          ).ripple(() {
            deleteMessageActionPopup();
          }),
          BodyLargeText(
            forwardString.tr,
              weight: TextWeight.bold
          ).ripple(() {
            selectUserForMessageForward();
          }),
          BodyLargeText(
            unStarString.tr,
              weight: TextWeight.bold
          ).ripple(() {
            _chatRoomDetailController.unStarMessages();
            _chatDetailController.setToActionMode(
                mode: ChatMessageActionMode.none);
          }),
          BodyLargeText(
            cancelString.tr,
              weight: TextWeight.bold
          ).ripple(() {
            _chatDetailController.setToActionMode(
                mode: ChatMessageActionMode.none);
          })
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  Widget messagesListView() {
    return Container(
      decoration: _chatDetailController.wallpaper.value.isEmpty
          ? null
          : BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_chatDetailController.wallpaper.value),
                fit: BoxFit.cover,
              ),
            ),
      child: Obx(() => ListView.builder(
            padding:
                 EdgeInsets.only(top: 10, bottom: 50, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
            itemCount: _chatRoomDetailController.starredMessages.length,
            itemBuilder: (ctx, index) {
              return messageTile(index);
            },
          )),
    );
  }

  Widget messageTile(int index) {
    return Obx(() {
      ChatMessageModel chatMessage =
          _chatRoomDetailController.starredMessages[index];
      return Column(
        children: [
          ChatMessageTile(
            message: chatMessage,
            showName: true,
            actionMode: _chatDetailController.actionMode.value ==
                ChatMessageActionMode.edit,
            replyMessageTapHandler: (message) {
              // replyMessageTapped(chatMessage);
            },
            messageTapHandler: (message) {
              messageTapped(chatMessage);
            },
          ),
          const SizedBox(
            height: 20,
          )
        ],
      );
    });
  }

  void messageTapped(ChatMessageModel model) async {
    if (model.messageContentType == MessageContentType.forward) {
      messageTapped(model.originalMessage);
    }
    if (model.messageContentType == MessageContentType.photo) {
      int index = _chatDetailController.mediaMessages
          .indexWhere((element) => element == model);

      Get.to(() => MediaListViewer(
            chatRoom: _chatDetailController.chatRoom.value!,
            medias: _chatDetailController.mediaMessages,
            startFrom: index,
          ));
    } else if (model.messageContentType == MessageContentType.video) {
      Get.to(() => PlayVideoController(
            chatMessage: model,
          ));
    } else if (model.messageContentType == MessageContentType.post) {
      Get.to(() => SinglePostDetail(
            postId: model.postContent.postId,
          ));
    } else if (model.messageContentType == MessageContentType.contact) {
      openActionPopupForContact(model.mediaContent.contact!);
    } else if (model.messageContentType == MessageContentType.profile) {
      Get.to(() => OtherUserProfile(
            userId: model.profileContent.userId,
          ));
    } else if (model.messageContentType == MessageContentType.location) {
      try {
        final coords = Coords(model.mediaContent.location!.latitude,
            model.mediaContent.location!.longitude);
        final title = model.mediaContent.location!.name;
        final availableMaps = await MapLauncher.installedMaps;

        showModalBottomSheet(
          context: Get.context!,
          builder: (BuildContext context) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                        ),
                        title: Heading5Text(
                          '${openInString.tr} ${map.mapName}',
                        ),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      } catch (e) {
        // print(e);
      }
    }
  }

  void openActionPopupForContact(Contact contact) {
    showModalBottomSheet(
        context: context,

        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: Heading5Text(
                      contact.displayName,
                            weight: TextWeight.bold
                    )),
                    onTap: () async {}),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(saveContactString.tr)),
                    onTap: () async {
                      Get.back();
                      _chatDetailController.addNewContact(contact);
                      AppUtil.showToast(
                          message: contactSavedString.tr,
                          isSuccess: false);
                    }),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(cancelString.tr)),
                    onTap: () => Get.back()),
              ],
            ));
  }

  selectUserForMessageForward() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,

        builder: (context) =>
            SelectFollowingUserForMessageSending(sendToUserCallback: (user) {
              _chatDetailController.getChatRoomWithUser(
                  userId:user.id,
                  callback: (room) {
                        _chatDetailController.forwardSelectedMessages(
                            room: room);
                        Get.back();
                      });
            })).then((value) {
      _chatDetailController.setToActionMode(mode: ChatMessageActionMode.none);
    });
  }

  void deleteMessageActionPopup() {
    bool ifAnyMessageByOpponent = _chatDetailController.selectedMessages
        .where((e) => e.isMineMessage == false)
        .isNotEmpty;

    showModalBottomSheet(
        context: context,

        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: BodyLargeText(deleteMessageForMeString.tr)),
                    onTap: () async {
                      Get.back();
                      _chatDetailController.deleteMessage(deleteScope: 1);
                      // postCardController.reportPost(widget.model);
                    }),
                divider(),
                ifAnyMessageByOpponent == false
                    ? ListTile(
                        title: Center(
                            child:
                            BodyLargeText(deleteMessageForAllString.tr)),
                        onTap: () async {
                          Get.back();
                          _chatDetailController.deleteMessage(deleteScope: 2);
                          // postCardController.blockUser(widget.model.user.id);
                        })
                    : Container(),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(cancelString.tr)),
                    onTap: () => Get.back()),
              ],
            ));
  }
}
