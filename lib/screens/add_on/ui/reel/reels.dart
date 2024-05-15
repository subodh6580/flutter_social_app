import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';

import '../../../../controllers/post/add_post_controller.dart';

class Reels extends StatefulWidget {
  final bool needBackBtn;

  const Reels({Key? key, required this.needBackBtn}) : super(key: key);

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final ReelsController _reelsController = Get.find();
  final AddPostController _addPostController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reelsController.getReels();
    });
  }

  @override
  void dispose() {
    _reelsController.clearReels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: AppScaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Stack(
            children: [
              GetBuilder<ReelsController>(
                  init: _reelsController,
                  builder: (ctx) {
                    print('update reels widget');
                    return PageView(
                        controller: _reelsController.pageController,
                        scrollDirection: Axis.vertical,
                        allowImplicitScrolling: true,
                        onPageChanged: (index) {
                          _reelsController.currentPageChanged(
                              index, _reelsController.publicReels[index]);
                        },
                        children: [
                          for (int i = 0;
                              i < _reelsController.publicReels.length;
                              i++)
                            SizedBox(
                              height: Get.height,
                              width: Get.width,
                              // color: Colors.brown,
                              child: ReelVideoPlayer(
                                reel: _reelsController.publicReels[i],
                                // play: false,
                              ),
                            )
                        ]);
                  }),
              Positioned(
                  right: DesignConstants.horizontalPadding,
                  left: DesignConstants.horizontalPadding,
                  top: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.needBackBtn
                          ? Container(
                              height: 40,
                              width: 40,
                              color:
                                  AppColorConstants.themeColor.withOpacity(0.5),
                              child: const ThemeIconWidget(
                                ThemeIcon.backArrow,
                                color: Colors.white,
                              ).lP8.ripple(() {
                                Get.back();
                              }),
                            ).circular
                          : Container(),
                      Container(
                        height: 40,
                        width: 40,
                        color: AppColorConstants.themeColor.withOpacity(0.5),
                        child: const ThemeIconWidget(
                          ThemeIcon.camera,
                          color: Colors.white,
                        ).ripple(() {
                          Get.to(() => const CreateReelScreen());
                        }),
                      ).circular,
                    ],
                  )),
              Positioned(
                  left: DesignConstants.horizontalPadding,
                  right: DesignConstants.horizontalPadding,
                  bottom: DesignConstants.horizontalPadding,
                  child: postingView()),
            ],
          )),
    );
  }

  Widget postingView() {
    return Obx(
        () => _addPostController.postingStatus.value == PostingStatus.posting
            ? Container(
                height: 55,
                color: AppColorConstants.cardColor,
                child: Row(
                  children: [
                    _addPostController.postingMedia.isNotEmpty
                        ? Image.memory(
                            _addPostController.postingMedia.first.thumbnail!,
                            fit: BoxFit.cover,
                            width: 30,
                            height: 30,
                          ).round(5)
                        : BodyMediumText(_addPostController.postingTitle),
                    const SizedBox(
                      width: 5,
                    ),
                    BodyLargeText(
                      _addPostController.isErrorInPosting.value
                          ? postFailedString.tr
                          : postingString.tr,
                    ),
                    const Spacer(),
                    _addPostController.isErrorInPosting.value
                        ? Row(
                            children: [
                              BodyLargeText(
                                discardString.tr,
                                weight: TextWeight.medium,
                              ).ripple(() {
                                _addPostController.discardFailedPost();
                              }),
                              const SizedBox(
                                width: 20,
                              ),
                              BodyLargeText(
                                retryString.tr,
                                weight: TextWeight.medium,
                              ).ripple(() {
                                _addPostController.retryPublish();
                              }),
                            ],
                          )
                        : Container()
                  ],
                ).hP8,
              ).round(15)
            : _addPostController.postingStatus.value == PostingStatus.posted
                ? Container(
                    height: 55,
                    color: AppColorConstants.cardColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BodyMediumText(postedString.tr,
                            weight: TextWeight.bold),
                        ThemeIconWidget(
                          ThemeIcon.checkMarkWithCircle,
                          color: AppColorConstants.themeColor,
                        )
                      ],
                    ).hP8,
                  ).round(15)
                : Container());
  }
}
