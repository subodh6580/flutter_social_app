import 'package:flutter/cupertino.dart';
import 'package:foap/helper/imports/common_import.dart';

import 'package:foap/helper/imports/chat_imports.dart';

class ChatMediaList extends StatefulWidget {
  final ChatRoomModel chatRoom;

  const ChatMediaList({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatMediaList> createState() => _ChatMediaListState();
}

class _ChatMediaListState extends State<ChatMediaList> {
  final ChatRoomDetailController chatRoomDetailController = Get.find();

  @override
  void initState() {
    chatRoomDetailController.segmentChanged(0, widget.chatRoom.id);
    super.initState();
  }

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
              Obx(() => CupertinoSlidingSegmentedControl<int>(
                    backgroundColor: AppColorConstants.cardColor,
                    thumbColor: AppColorConstants.themeColor,
                    padding: const EdgeInsets.all(8),
                    groupValue: chatRoomDetailController.selectedSegment.value,
                    children: {
                      0: BodyMediumText(
                        photoString.tr,
                      ).hP25,
                      1: BodyMediumText(
                        videoString.tr,
                      ).hP25,
                    },
                    onValueChanged: (value) {
                      chatRoomDetailController.segmentChanged(
                          value!, widget.chatRoom.id);
                    },
                  )),
              const SizedBox(
                width: 20,
              )
            ],
          ).hp(DesignConstants.horizontalPadding),
          divider().tP8,
          mediaList()
        ],
      ),
    );
  }

  Widget mediaList() {
    return GetBuilder<ChatRoomDetailController>(
        init: chatRoomDetailController,
        builder: (ctx) {
          ScrollController scrollController = ScrollController();
          scrollController.addListener(() {
            if (scrollController.position.maxScrollExtent ==
                scrollController.position.pixels) {}
          });

          List<ChatMessageModel> messages =
              chatRoomDetailController.selectedSegment.value == 0
                  ? chatRoomDetailController.photos
                  : chatRoomDetailController.videos;

          return Expanded(
            child: GridView.builder(
              controller: scrollController,
              itemCount: messages.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              // You won't see infinite size error
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  mainAxisExtent: 100),
              itemBuilder: (BuildContext context, int index) => Stack(children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: MessageImage(
                          message: messages[index], fitMode: BoxFit.cover)
                      .round(10),
                ).ripple(() {
                  Get.to(() => MediaListViewer(
                            chatRoom: widget.chatRoom,
                            medias: messages,
                            startFrom: index,
                          ))!
                      .then((value) {
                    chatRoomDetailController.segmentChanged(
                        0, widget.chatRoom.id);
                  });
                }),
                messages[index].messageContentType == MessageContentType.video
                    ? const Positioned(
                        right: 0,
                        top: 0,
                        left: 0,
                        bottom: 0,
                        child: ThemeIconWidget(
                          ThemeIcon.play,
                          size: 70,
                          color: Colors.white,
                        ),
                      )
                    : Container()
              ]),

            ).hp(DesignConstants.horizontalPadding),
          );
        });
  }
}
