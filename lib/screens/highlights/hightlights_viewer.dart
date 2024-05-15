import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/highlights_imports.dart';

class HighlightViewer extends StatefulWidget {
  final HighlightsModel highlight;

  const HighlightViewer({Key? key, required this.highlight}) : super(key: key);

  @override
  State<HighlightViewer> createState() => _HighlightViewerState();
}

class _HighlightViewerState extends State<HighlightViewer> {
  final HighlightsController highlightController = Get.find();
  final controller = FlutterStoryViewController();

  @override
  void initState() {
    highlightController.setCurrentHighlight(widget.highlight);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: storyWidget(),
    );
  }

  Widget storyWidget() {
    return Stack(
      children: [
        FlutterStoryView(
          controller: controller,

          // userInfo: UserInfo(
          //     username: highlightController
          //         .storyMediaModel.value!.story.user!.userName,
          //     // give your username
          //     profileUrl: highlightController.storyMediaModel.value!.story.user!
          //         .picture // give your profile url
          //     ),
          storyItems: [
            for (HighlightMediaModel media in widget.highlight.medias.reversed)
              media.story.isVideoPost() == true
                  ? StoryItem(
                      url: media.story.video!,
                      type: StoryItemType.video,
                      viewers: [],
                      duration: media.story.videoDuration != null
                          ? media.story.videoDuration! ~/ 1000
                          : null)
                  : StoryItem(
                      url: media.story.image!,
                      type: StoryItemType.image,
                      viewers: [],
                    )
          ],
          onPageChanged: (s) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              highlightController
                  .setCurrentStoryMedia(widget.highlight.medias[s]);
            });
          },
          onComplete: () {
            Get.back();
          },
        ),
        Positioned(top: 70, left: 20, right: 0, child: userProfileView()),
      ],
    );
  }

  Widget userProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Obx(() => AvatarView(
                  url: highlightController
                      .storyMediaModel.value!.story.user!.picture,
                  size: 30,
                )).rP8,
            SizedBox(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyMediumText(
                        highlightController
                            .storyMediaModel.value!.story.user!.userName,
                        weight: TextWeight.medium,
                        color: Colors.white,
                      ),
                      BodyMediumText(
                        highlightController.storyMediaModel.value!.createdAt,
                        weight: TextWeight.medium,
                        color: Colors.white,
                        // color: AppColorConstants.subHeadingTextColor,
                      )
                    ],
                  )),
            )
          ],
        ),
        // const Spacer(),
        SizedBox(
          height: 25,
          width: 40,
          child: const ThemeIconWidget(
            ThemeIcon.more,
            color: Colors.white,
            size: 20,
          ).ripple(() {
            openActionPopup();
          }),
        )
      ],
    );
  }

  void openActionPopup() {
    controller.pause();

    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(child: Text(deleteFromHighlightString.tr)),
                    onTap: () async {
                      Get.back();
                      controller.resume();

                      highlightController.deleteStoryFromHighlight();
                    }),
                divider(),
                ListTile(
                    title: Center(child: Text(cancelString.tr)),
                    onTap: () {
                      controller.resume();
                      Get.back();
                    }),
              ],
            )).then((value) {
      controller.resume();
    });
  }
}
