import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/model/live_tv_model.dart';
import '../../components/live_tv_player.dart';
import '../../model/chat_message_model.dart';
import 'package:foap/helper/imports/tv_imports.dart';

class LiveTvPlayer extends StatefulWidget {
  final TvModel tvModel;

  const LiveTvPlayer({Key? key, required this.tvModel}) : super(key: key);

  @override
  State<LiveTvPlayer> createState() => _LiveTvPlayerState();
}

class _LiveTvPlayerState extends State<LiveTvPlayer> {
  final TvStreamingController _liveTvStreamingController = Get.find();
  TextEditingController messageTextField = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add Your Code here.
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        AutoOrientation.portraitAutoMode();
      } else {
        AutoOrientation.landscapeAutoMode();
      }
      _liveTvStreamingController.setCurrentViewingTv(widget.tvModel);
    });
  }

  @override
  void dispose() {
    AutoOrientation.portraitAutoMode();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        AutoOrientation.portraitAutoMode();
      } else {
        AutoOrientation.landscapeAutoMode();
      }
      return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            children: [
              if (orientation == Orientation.portrait)
                Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ThemeIconWidget(
                          ThemeIcon.backArrow,
                          size: 18,
                          color: AppColorConstants.iconColor,
                        ).ripple(() {
                          Get.back();
                        }),
                        BodyLargeText(widget.tvModel.name,
                            weight: TextWeight.medium),
                        Obx(() => ThemeIconWidget(
                              _liveTvStreamingController
                                          .currentViewingTv.value?.isFav ==
                                      1
                                  ? ThemeIcon.favFilled
                                  : ThemeIcon.fav,
                              size: 18,
                              color: _liveTvStreamingController
                                          .currentViewingTv.value?.isFav ==
                                      1
                                  ? Colors.red
                                  : AppColorConstants.iconColor,
                            ).ripple(() {
                              _liveTvStreamingController.favUnfavTv(
                                  _liveTvStreamingController
                                      .currentViewingTv.value!);
                            })),
                      ],
                    ).setPadding(
                        left: DesignConstants.horizontalPadding,
                        right: DesignConstants.horizontalPadding,
                        top: 8,
                        bottom: 16),
                    divider().tP8,
                  ],
                ),
              SocialifiedVideoPlayer(
                tvModel: widget.tvModel,
                url: widget.tvModel.tvUrl,
                play: false,
                orientation: orientation,
                isPlayingTv: true,
                // showMinimumHeight: isKeyboardVisible,
              ),
              if (orientation == Orientation.portrait)
                Expanded(child: liveChatView()),
            ],
          ),
        );
      });
    });
  }

  Widget liveChatView() {
    return SizedBox(
      height: Get.height * 0.5,
      child: Column(
        children: [Expanded(child: messagesListView()), messageComposerView()],
      ),
    );
  }

  Widget messagesListView() {
    return Column(
      children: [
        Container(
          height: 80,
          color: AppColorConstants.cardColor,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading4Text(liveChatString.tr, weight: TextWeight.semiBold),
                  BodySmallText(
                    '${widget.tvModel.totalViewer.formatNumber} ${usersString.tr}',
                  )
                ],
              ),
              // const Spacer(),
              // const ThemeIconWidget(
              //   ThemeIcon.close,
              //   size: 25,
              // ).ripple(() {
              //   _liveTvStreamingController.hideMessagesView();
              // }),
            ],
          ).p16,
        ).topRounded(20),
        // const Spacer(),
        Expanded(
          child: GetBuilder<TvStreamingController>(
              init: _liveTvStreamingController,
              builder: (ctx) {
                List<ChatMessageModel> messages = (_liveTvStreamingController
                        .messagesMap[widget.tvModel.id.toString()] ??
                    []);
                return ListView.separated(
                    padding: EdgeInsets.only(
                        top: 10,
                        bottom: 50,
                        left: DesignConstants.horizontalPadding,
                        right: 70),
                    itemCount: messages.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        color: AppColorConstants.cardColor.withOpacity(0.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AvatarView(
                                size: 25,
                                url: messages[index].userPicture,
                                name: messages[index].userName),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BodyLargeText(
                                    messages[index].userName,
                                    weight: TextWeight.bold,
                                    color: AppColorConstants.subHeadingTextColor,
                                  ),
                                  BodyLargeText(
                                    messages[index].messageContent,
                                    color: AppColorConstants.subHeadingTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).p8,
                      ).round(10);
                    },
                    separatorBuilder: (ctx, index) {
                      return const SizedBox(
                        height: 10,
                      );
                    });
              }),
        ),
      ],
    );
  }

  Widget messageComposerView() {
    return SizedBox(
      // color: Colors.black12,
      height: 70,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  color: AppColorConstants.cardColor.withOpacity(0.8),
                  child: TextField(
                    controller: messageTextField,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: FontSizes.b2,
                        color: AppColorConstants.mainTextColor),
                    maxLines: 50,
                    decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.only(left: 10, right: 10, top: 5),
                        labelStyle: TextStyle(
                            fontSize: FontSizes.b2,
                            color: AppColorConstants.themeColor),
                        hintStyle: TextStyle(
                            fontSize: FontSizes.b2,
                            color: AppColorConstants.themeColor),
                        hintText: pleaseEnterMessageString.tr),
                  ),
                ).round(10),
              ),
              const SizedBox(
                width: 10,
              ),
              BodyLargeText(
                sendString.tr,
                weight: TextWeight.medium,
                color: AppColorConstants.themeColor,
              ).ripple(() {
                sendMessage(widget.tvModel.id);
              }),
            ],
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }

  sendMessage(int liveTvId) {
    if (messageTextField.text.removeAllWhitespace.trim().isNotEmpty) {
      _liveTvStreamingController.sendTextMessage(
          messageTextField.text, liveTvId);
      messageTextField.text = '';
      _liveTvStreamingController.showMessagesView();
    }
  }
}
