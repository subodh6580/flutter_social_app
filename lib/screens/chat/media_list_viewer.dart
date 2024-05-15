import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';

class MediaListViewer extends StatefulWidget {
  final ChatRoomModel chatRoom;
  final List<ChatMessageModel> medias;
  final int startFrom;

  const MediaListViewer({Key? key,
    required this.medias,
    required this.chatRoom,
    required this.startFrom})
      : super(key: key);

  @override
  State<MediaListViewer> createState() => _MediaListViewerState();
}

class _MediaListViewerState extends State<MediaListViewer> {
  final MediaListViewerController mediaListViewerController = MediaListViewerController();

  @override
  void initState() {
    mediaListViewerController.setCurrentMediaIndex(widget.startFrom);
    mediaListViewerController.setMessages(widget.medias);
    super.initState();
  }

  @override
  void dispose() {
    mediaListViewerController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SizedBox(
          child: Column(
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
                    mediaString.tr,
                    weight: TextWeight.bold,
                    color: AppColorConstants.themeColor,
                  ),
                  ThemeIconWidget(
                    ThemeIcon.delete,
                    size: 25,
                    color: AppColorConstants.iconColor,
                  ).ripple(() {
                    mediaListViewerController.deleteMessage(
                        inChatRoom: widget.chatRoom);
                  })
                ],
              ).hp(DesignConstants.horizontalPadding),
              const SizedBox(height: 8,),
              GetBuilder<MediaListViewerController>(
                  init: mediaListViewerController,
                  builder: (ctx) {
                    return CarouselSlider(
                      items: addImages(),
                      options: CarouselOptions(
                          enlargeCenterPage: false,
                          enableInfiniteScroll: false,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.8,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            mediaListViewerController.setCurrentMediaIndex(
                                index);
                          },
                          initialPage: widget.startFrom),
                    );
                  }),
            ],
          )),
    );
  }

  List<Widget> addImages() {
    return widget.medias
        .map((item) =>
        MessageImage(
          message: item,
          fitMode: BoxFit.contain,
          disableRoundCorner: true,
        ))
        .toList();
  }
}
