import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../competitions/video_player_screen.dart';
import '../post/single_post_detail.dart';
import '../profile/other_user_profile.dart';
import '../settings_menu/settings_controller.dart';

class ChatDetail extends StatefulWidget {
  final ChatRoomModel chatRoom;

  const ChatDetail({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final ChatDetailController _chatDetailController = Get.find();
  final ScrollController _controller = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    loadChat();
    super.initState();
  }

  loadChat() {
    _chatDetailController.loadChat(widget.chatRoom, () {});
    _chatDetailController.loadWallpaper(widget.chatRoom.id);
    scrollToBottom();
  }

  refreshData() {
    _chatDetailController.loadChat(widget.chatRoom, () {
      _refreshController.refreshCompleted();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _chatDetailController.clear();
  }

  scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(milliseconds: 100), () {
        if (_chatDetailController.messages.isNotEmpty) {
          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    });
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
              return Column(
                children: [
                  SizedBox(
                    height:
                        _chatDetailController.smartReplySuggestions.isNotEmpty
                            ? 50
                            : 0,
                    child: ListView.separated(
                        padding:  EdgeInsets.only(
                            left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 5, bottom: 10),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, index) {
                          return SizedBox(
                            height: 0,
                            child: Center(
                              child: Heading5Text(
                                      _chatDetailController
                                          .smartReplySuggestions[index],
                                      weight: TextWeight.medium)
                                  .hP8,
                            ),
                          ).borderWithRadius(value: 1, radius: 10).ripple(() {
                            _chatDetailController.sendTextMessage(
                                messageText: _chatDetailController
                                    .smartReplySuggestions[index],
                                mode: _chatDetailController.actionMode.value,
                                room: _chatDetailController.chatRoom.value!);
                          });
                        },
                        separatorBuilder: (ctx, index) {
                          return const SizedBox(
                            width: 10,
                          );
                        },
                        itemCount:
                            _chatDetailController.smartReplySuggestions.length),
                  ),
                ],
              );
            }),
            Obx(() {
              return _chatDetailController.chatRoom.value?.amIMember == true
                  ? _chatDetailController.actionMode.value ==
                              ChatMessageActionMode.none ||
                          _chatDetailController.actionMode.value ==
                              ChatMessageActionMode.reply
                      ? _chatDetailController.chatRoom.value!.canIChat
                          ? messageComposerView()
                          : cantChatView()
                      : selectedMessageView()
                  : cantChatView();
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
              Timer(const Duration(milliseconds: 500), () {
                _chatDetailController.clear();
              });
              Get.back();
            }),
            Obx(() => _chatDetailController.chatRoom.value?.isGroupChat == false
                ? Row(
                    children: [
                      if (_settingsController.setting.value!.enableAudioCalling)
                        ThemeIconWidget(
                          ThemeIcon.mobile,
                          color: AppColorConstants.iconColor,
                          size: 25,
                        ).p4.ripple(() {
                          audioCall();
                        }).rp(20),
                      if (_settingsController.setting.value!.enableVideoCalling)
                        ThemeIconWidget(
                          ThemeIcon.videoCamera,
                          color: AppColorConstants.iconColor,
                          size: 25,
                        ).p4.ripple(() {
                          videoCall();
                        })
                    ],
                  )
                : Container()),
          ],
        ).hp(DesignConstants.horizontalPadding),
        Positioned(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Obx(() {
                    return _chatDetailController.chatRoom.value == null ||
                            _chatDetailController
                                .chatRoom.value!.roomMembers.isEmpty
                        ? Container()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  BodyLargeText(
                                      _chatDetailController.chatRoom.value!
                                                  .isGroupChat ==
                                              true
                                          ? _chatDetailController
                                              .chatRoom.value!.name!
                                          : _chatDetailController
                                              .chatRoom
                                              .value!
                                              .opponent
                                              .userDetail
                                              .userName,
                                      weight: TextWeight.bold),
                                  const SizedBox(width: 5),
                                  _chatDetailController
                                              .chatRoom.value!.isGroupChat ==
                                          false
                                      ? Container(
                                          height: 8,
                                          width: 8,
                                          color: _chatDetailController
                                                      .chatRoom
                                                      .value!
                                                      .opponent
                                                      .userDetail
                                                      .isOnline ==
                                                  true
                                              ? AppColorConstants.themeColor
                                              : AppColorConstants.disabledColor,
                                        ).circular
                                      : Container(),
                                ],
                              ),
                              _chatDetailController
                                          .chatRoom.value!.isGroupChat ==
                                      false
                                  ? _chatDetailController.isTypingMapping[
                                              _chatDetailController
                                                  .chatRoom
                                                  .value!
                                                  .opponent
                                                  .userDetail
                                                  .userName] ==
                                          true
                                      ? BodyMediumText(
                                          typingString.tr,
                                        )
                                      : BodyMediumText(
                                          _chatDetailController
                                                      .chatRoom
                                                      .value!
                                                      .opponent
                                                      .userDetail
                                                      .isOnline ==
                                                  true
                                              ? onlineString.tr
                                              : _chatDetailController.opponent
                                                      .value?.lastSeenAtTime ??
                                                  '',
                                          weight: TextWeight.medium)
                                  : SizedBox(
                                      width: Get.width -
                                          120,
                                      child: BodyMediumText(
                                        _chatDetailController
                                                .whoIsTyping.isNotEmpty
                                            ? '${_chatDetailController.whoIsTyping.join(',')} ${typingString.tr}'
                                            : _chatDetailController
                                                .chatRoom.value!.roomMembers
                                                .map((e) {
                                                  if (e.userDetail.isMe) {
                                                    return youString.tr;
                                                  }
                                                  return e.userDetail.userName;
                                                })
                                                .toList()
                                                .join(','),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                            ],
                          );
                  }).ripple(() {
                    Get.to(() => ChatRoomDetail(
                            chatRoom: _chatDetailController.chatRoom.value!))!
                        .then((value) {
                      loadChat();
                    });
                  }),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget selectedMessageView() {
    return Obx(() => Container(
          color: AppColorConstants.backgroundColor.darken(0.02),
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ThemeIconWidget(
                _chatDetailController.actionMode.value ==
                        ChatMessageActionMode.forward
                    ? ThemeIcon.fwd
                    : _chatDetailController.actionMode.value ==
                            ChatMessageActionMode.delete
                        ? ThemeIcon.delete
                        : ThemeIcon.send,
                color: AppColorConstants.themeColor,
              ).ripple(() {
                if (_chatDetailController.actionMode.value ==
                    ChatMessageActionMode.forward) {
                  selectUserForMessageForward();
                } else {
                  deleteMessageActionPopup();
                }
              }),
              BodyLargeText(
                '${_chatDetailController.selectedMessages.length} ${selectedString.tr.toLowerCase()}',
              ),
              BodyLargeText(cancelString.tr, weight: TextWeight.bold)
                  .ripple(() {
                _chatDetailController.setToActionMode(
                    mode: ChatMessageActionMode.none);
              })
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  Widget replyMessageView() {
    return Obx(() => _chatDetailController
                .selectedMessage.value!.messageContentType ==
            MessageContentType.text
        ? replyTextMessageView(_chatDetailController.selectedMessage.value!)
        : replyMediaMessageView(_chatDetailController.selectedMessage.value!));
  }

  Widget replyTextMessageView(ChatMessageModel message) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(
                  message.isMineMessage
                      ? youString.tr
                      : message.sender!.userName,
                  weight: TextWeight.medium,
                  color: AppColorConstants.themeColor,
                ).bP4,
                BodyLargeText(
                  message.textMessage,
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          ThemeIconWidget(
            ThemeIcon.closeCircle,
            size: 28,
            color: AppColorConstants.iconColor,
          ).ripple(() {
            _chatDetailController.setReplyMessage(message: null);
          })
        ],
      ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 8, bottom: 8),
    );
  }

  Widget replyMediaMessageView(ChatMessageModel message) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(
                  message.isMineMessage
                      ? youString.tr
                      : message.sender!.userName,
                  weight: TextWeight.medium,
                  color: AppColorConstants.themeColor,
                ).bP4,
                messageTypeShortInfo(
                  message: message,
                ),
              ],
            ),
          ),
          messageMainContent(message),
          const SizedBox(width: 10),
          ThemeIconWidget(
            ThemeIcon.closeCircle,
            size: 28,
            color: AppColorConstants.iconColor,
          ).ripple(() {
            _chatDetailController.setToActionMode(
                mode: ChatMessageActionMode.none);
          })
        ],
      ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, top: 8, bottom: 8),
    );
  }

  Widget messageComposerView() {
    return Column(
      children: [
        _chatDetailController.actionMode.value == ChatMessageActionMode.reply
            ? replyMessageView()
            : Container(),
        Container(
          color: AppColorConstants.backgroundColor.darken(0.02),
          height: 70,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: Obx(() => TextField(
                                  controller:
                                      _chatDetailController.messageTf.value,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: FontSizes.h5,
                                      fontWeight: TextWeight.regular,
                                      color: AppColorConstants.mainTextColor),
                                  maxLines: 50,
                                  onChanged: (text) {
                                    _chatDetailController.messageChanges();
                                  },
                                  decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 5),
                                      labelStyle: TextStyle(
                                          fontSize: FontSizes.b2,
                                          fontWeight: TextWeight.medium,
                                          color: AppColorConstants.themeColor),
                                      hintStyle: TextStyle(
                                          fontSize: FontSizes.h6,
                                          fontWeight: TextWeight.regular,
                                          color: AppColorConstants.themeColor),
                                      hintText: pleaseEnterMessageString.tr),
                                )),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Obx(() {
                          return _chatDetailController
                                  .messageTf.value.text.isNotEmpty
                              ? Heading5Text(
                                  sendString.tr,
                                  weight: TextWeight.bold,
                                  color: AppColorConstants.themeColor,
                                ).ripple(() {
                                  sendMessage();
                                })
                              : Container(
                                  height: 30,
                                  width: 30,
                                  color: AppColorConstants.themeColor,
                                  child: ThemeIconWidget(
                                    ThemeIcon.plus,
                                    color: AppColorConstants.iconColor,
                                  ),
                                ).circular.ripple(() {
                                  openMediaSharingOptionView();
                                  // chatDetailController
                                  //     .expandCollapseActions();
                                });
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        )
      ],
    );
  }

  Widget cantChatView() {
    return Container(
      color: AppColorConstants.backgroundColor.darken(0.02),
      height: 70,
      child: Center(
        child: BodyLargeText(
          onlyAdminCanSendMessageString.tr,
        ),
      ),
    );
  }

  Widget messagesListView() {
    return GetBuilder<ChatDetailController>(
        init: _chatDetailController,
        builder: (ctx) {
          return Container(
            decoration: _chatDetailController.wallpaper.value.isEmpty
                ? null
                : BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_chatDetailController.wallpaper.value),
                      fit: BoxFit.cover,
                    ),
                  ),
            child: _chatDetailController.messages.isEmpty
                ? Container()
                : Container(
                    child: ListView.separated(
                            controller: _controller,
                            // itemScrollController: _itemScrollController,
                            // itemPositionsListener: _itemPositionsListener,
                            padding:  EdgeInsets.only(
                                top: 10, bottom: 50, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding),
                            itemCount: _chatDetailController.messages.length,
                            itemBuilder: (ctx, index) {
                              ChatMessageModel message =
                                  _chatDetailController.messages[index];

                              ChatMessageModel? lastMessage;

                              if (index > 0) {
                                lastMessage =
                                    _chatDetailController.messages[index - 1];
                              }

                              String dateTimeStr = message.date;
                              bool addDateSeparator = false;
                              if (dateTimeStr != lastMessage?.date &&
                                  message.isDateSeparator == false) {
                                addDateSeparator = true;
                              }

                              return Column(
                                children: [
                                  if (addDateSeparator)
                                    dateSeparatorWidget(message),
                                  message.isDeleted == true ||
                                          message.isDateSeparator ||
                                          message.messageContentType ==
                                              MessageContentType.groupAction
                                      ? messageTile(message)
                                      : chatMessageFocusMenu(message),
                                ],
                              );
                            },
                            separatorBuilder: (ctx, index) {
                              return const SizedBox(
                                height: 20,
                              );
                            })
                        .addPullToRefresh(
                            refreshController: _refreshController,
                            enablePullUp: false,
                            enablePullDown: true,
                            onRefresh: refreshData,
                            onLoading: () {})),
          );
        });
  }

  Widget chatMessageFocusMenu(ChatMessageModel message) {
    final dataKey = GlobalKey();
    message.globalKey = dataKey;
    return FocusedMenuHolder(
      key: dataKey,

      menuWidth: Get.width * 0.50,
      blurSize: 5.0,
      menuItemExtent: 45,
      menuBoxDecoration: BoxDecoration(
          color: AppColorConstants.backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(15.0))),
      duration: const Duration(milliseconds: 100),
      animateMenuItems: false,
      blurBackgroundColor: Colors.black54,
      openWithTap: false,
      // Open Focused-Menu on Tap rather than Long Press
      menuOffset: 10.0,
      // Offset value to show menuItem from the selected item
      bottomOffsetHeight: 80.0,
      // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
      menuItems: [
        if (message.copyContent != null)
          FocusedMenuItem(
              backgroundColor: AppColorConstants.backgroundColor,
              title: BodyLargeText(
                copyString.tr,
              ),
              trailingIcon: const Icon(Icons.file_copy, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message.decrypt));
              }),
        if (_chatDetailController.chatRoom.value?.canIChat == true &&
            _settingsController.setting.value!.enableReplyInChat)
          FocusedMenuItem(
              backgroundColor: AppColorConstants.backgroundColor,
              title: BodyLargeText(
                replyString.tr,
              ),
              trailingIcon: const Icon(Icons.reply, size: 18),
              onPressed: () {
                _chatDetailController.setReplyMessage(message: message);
              }),
        if (_settingsController.setting.value!.enableForwardingInChat)
          FocusedMenuItem(
              backgroundColor: AppColorConstants.backgroundColor,
              title: BodyLargeText(
                fwdString.tr,
              ),
              trailingIcon: const Icon(
                Icons.send,
                size: 18,
              ),
              onPressed: () {
                _chatDetailController.selectMessage(message);
                _chatDetailController.setToActionMode(
                    mode: ChatMessageActionMode.forward);
              }),
        FocusedMenuItem(
            backgroundColor: AppColorConstants.backgroundColor,
            title: BodyLargeText(
              deleteString.tr,
            ),
            trailingIcon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () {
              _chatDetailController.selectMessage(message);

              _chatDetailController.setToActionMode(
                  mode: ChatMessageActionMode.delete);
            }),
        if (_settingsController.setting.value!.enableStarMessage)
          FocusedMenuItem(
              backgroundColor: AppColorConstants.backgroundColor,
              title: BodyLargeText(
                message.isStar == 1 ? unStarString.tr : starString.tr,
              ),
              trailingIcon: Icon(
                Icons.star,
                size: 18,
                color: message.isStar == 1
                    ? AppColorConstants.themeColor
                    : AppColorConstants.iconColor,
              ),
              onPressed: () {
                if (message.isStar == 1) {
                  _chatDetailController.unStarMessage(message);
                } else {
                  _chatDetailController.starMessage(message);
                }
              })
      ],
      onPressed: () {},
      child: messageTile(message),
    );
  }

  Widget messageTile(ChatMessageModel chatMessage) {
    return ChatMessageTile(
      message: chatMessage,
      showName: _chatDetailController.chatRoom.value?.isGroupChat == true,
      actionMode: _chatDetailController.actionMode.value ==
              ChatMessageActionMode.forward ||
          _chatDetailController.actionMode.value ==
              ChatMessageActionMode.delete,
      replyMessageTapHandler: (message) {
        replyMessageTapped(chatMessage);
      },
      messageTapHandler: (message) {
        messageTapped(chatMessage);
      },
    );
  }

  Widget dateSeparatorWidget(ChatMessageModel chatMessage) {
    return Container(
      color: AppColorConstants.themeColor.lighten(0.2).withOpacity(0.5),
      width: 120,
      child: Center(
        child: BodySmallText(chatMessage.date)
            .setPadding(left: 8, right: 8, top: 4, bottom: 4),
      ),
    ).round(15).bP25;
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
              ))!
          .then((value) => loadChat());
    } else if (model.messageContentType == MessageContentType.video) {
      if (model.messageContent.isNotEmpty) {
        Get.to(() => PlayVideoController(
                  chatMessage: model,
                ))!
            .then((value) => loadChat());
      }
    } else if (model.messageContentType == MessageContentType.post) {
      Get.to(() => SinglePostDetail(
                postId: model.postContent.postId,
              ))!
          .then((value) => loadChat());
    } else if (model.messageContentType == MessageContentType.contact) {
      openActionPopupForContact(model.mediaContent.contact!);
    } else if (model.messageContentType == MessageContentType.profile) {
      Get.to(() => OtherUserProfile(
                userId: model.profileContent.userId,
              ))!
          .then((value) => loadChat());
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
    } else if (model.messageContentType == MessageContentType.file) {
      String? path = await getIt<FileManager>().localFilePathForMessage(model);

      if (path != null) {
        OpenFilex.open(path);
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
                        child: Heading5Text(contact.displayName,
                            weight: TextWeight.bold)),
                    onTap: () async {}),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(saveContactString.tr)),
                    onTap: () async {
                      Get.back();
                      _chatDetailController.addNewContact(contact);
                      AppUtil.showToast(
                          message: contactSavedString.tr, isSuccess: false);
                    }),
                divider(),
                ListTile(
                    title: Center(child: BodyLargeText(cancelString.tr)),
                    onTap: () => Get.back()),
              ],
            ));
  }

  sendMessage() {
    _chatDetailController.sendTextMessage(
        messageText: _chatDetailController.messageTf.value.text,
        mode: _chatDetailController.actionMode.value,
        room: _chatDetailController.chatRoom.value!);
    scrollToBottom();
  }

  void replyMessageTapped(ChatMessageModel model) {
    int index = _chatDetailController.messages.indexWhere((element) =>
        element.localMessageId == model.originalMessage.localMessageId);
    if (index != -1) {
      Scrollable.ensureVisible(model.globalKey!.currentContext!);
      // _controller.jumpTo(
      //   _controller.position.maxScrollExtent,
      //   duration: const Duration(milliseconds: 250),
      //   curve: Curves.fastOutSlowIn,
      // );

      // Timer(const Duration(milliseconds: 1), () {
      //
      //   _itemScrollController.jumpTo(
      //     index: index,
      //   );
      // });
    }
  }

  void videoCall() {
    _chatDetailController.initiateVideoCall();
  }

  void audioCall() {
    _chatDetailController.initiateAudioCall();
  }

  selectUserForMessageForward() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) =>
            SelectFollowingUserForMessageSending(sendToUserCallback: (user) {
              _chatDetailController.getChatRoomWithUser(
                  userId: user.id,
                  callback: (room) {
                    _chatDetailController.forwardSelectedMessages(room: room);
                    Get.back();
                  });
            })).then((value) {
      _chatDetailController.setToActionMode(mode: ChatMessageActionMode.none);
    });
  }

  openMediaSharingOptionView() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) => const FractionallySizedBox(
            heightFactor: 0.42, child: ChatMediaSharingOptionPopup()));
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
                ifAnyMessageByOpponent == false &&
                        _chatDetailController.chatRoom.value?.canIChat == true
                    ? ListTile(
                        title: Center(
                            child: BodyLargeText(deleteMessageForAllString.tr)),
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
