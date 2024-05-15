import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/post_option_popup.dart';
import 'package:foap/screens/post/tag_hashtag_view.dart';
import 'package:foap/screens/post/tag_users_view.dart';
import 'package:photo_editor_sdk/photo_editor_sdk.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import '../../components/smart_text_field.dart';
import '../../components/video_widget.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/post/select_post_media_controller.dart';
import '../chat/media.dart';
import '../settings_menu/settings_controller.dart';

class AddPostScreen extends StatefulWidget {
  final PostType postType;
  final List<Media>? items;
  final int? competitionId;
  final int? clubId;
  final bool? isReel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const AddPostScreen(
      {Key? key,
      required this.postType,
      this.items,
      this.competitionId,
      this.clubId,
      this.isReel,
      this.audioId,
      this.audioStartTime,
      this.audioEndTime})
      : super(key: key);

  @override
  AddPostState createState() => AddPostState();
}

class AddPostState extends State<AddPostScreen> {
  TextEditingController descriptionText = TextEditingController();
  final SelectPostMediaController _selectPostMediaController =
      SelectPostMediaController();
  final SmartTextFieldController _smartTextFieldController = Get.find();
  final SettingsController settingController = Get.find();
  final AddPostController addPostController = Get.find();

  @override
  void initState() {
    _smartTextFieldController.clear();
    super.initState();
  }

  @override
  void dispose() {
    descriptionText.text = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<AddPostController>(
          init: addPostController,
          builder: (ctx) {
            return Stack(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 55,
                      ),
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                                addPostController.clear();
                              },
                              child:
                                  const ThemeIconWidget(ThemeIcon.backArrow)),
                          const Spacer(),
                          Container(
                                  color: AppColorConstants.themeColor,
                                  child: BodyLargeText(
                                    widget.competitionId == null
                                        ? postString.tr
                                        : submitString.tr,
                                    weight: TextWeight.medium,
                                    color: Colors.white,
                                  ).setPadding(
                                      left: 8, right: 8, top: 5, bottom: 5))
                              .round(10)
                              .ripple(() {
                            if ((widget.items ??
                                        _selectPostMediaController
                                            .selectedMediaList)
                                    .isNotEmpty ||
                                descriptionText.text.isNotEmpty) {
                              addPostController.startUploadingPost(
                                  allowComments:
                                      addPostController.enableComments.value,
                                  postType: widget.postType,
                                  isReel: widget.isReel ?? false,
                                  audioId: widget.audioId,
                                  audioStartTime: widget.audioStartTime,
                                  audioEndTime: widget.audioEndTime,
                                  items: widget.items ??
                                      _selectPostMediaController
                                          .selectedMediaList,
                                  title: descriptionText.text,
                                  competitionId: widget.competitionId,
                                  clubId: widget.clubId);
                            }
                          }),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      addDescriptionView()
                          .hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          BodyMediumText(
                            allowCommentsString.tr,
                            weight: TextWeight.semiBold,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Obx(() => ThemeIconWidget(
                                      addPostController.enableComments.value
                                          ? ThemeIcon.selectedCheckbox
                                          : ThemeIcon.emptyCheckbox)
                                  .ripple(() {
                                addPostController.toggleEnableComments();
                              })),
                        ],
                      ).hp(DesignConstants.horizontalPadding),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        return _smartTextFieldController.isEditing.value == 1
                            ? Expanded(
                                child: Container(
                                  // height: 500,
                                  width: double.infinity,
                                  color: AppColorConstants.disabledColor
                                      .withOpacity(0.1),
                                  child: _smartTextFieldController
                                          .currentHashtag.isNotEmpty
                                      ? TagHashtagView()
                                      : _smartTextFieldController
                                              .currentUserTag.isNotEmpty
                                          ? TagUsersView()
                                          : Container().ripple(() {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            }),
                                ),
                              )
                            : mediaList();
                      }),
                      Obx(() => _smartTextFieldController.isEditing.value == 0
                          ? const Spacer()
                          : Container()),
                      if (widget.isReel != true)
                        Obx(() => _smartTextFieldController.isEditing.value == 0
                            ? PostOptionsPopup(
                                selectedMediaList: (medias) {
                                  _selectPostMediaController
                                      .mediaSelected(medias);
                                },
                                selectGif: (gifMedia) {
                                  _selectPostMediaController
                                      .mediaSelected([gifMedia]);
                                },
                                recordedAudio: (audioMedia) {
                                  _selectPostMediaController
                                      .mediaSelected([audioMedia]);
                                },
                              )
                            : Container())
                    ]),
              ],
            );
          }),
    );
  }

  Widget mediaList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: Get.height * 0.4,
          child: Stack(
            children: [
              Obx(() {
                return CarouselSlider(
                  items: [
                    for (Media media
                        in _selectPostMediaController.selectedMediaList)
                      media.mediaType == GalleryMediaType.photo
                          ? Image.file(
                              media.file!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ).ripple(() {
                              if (settingController
                                  .setting.value!.canEditPhotoVideo) {
                                openImageEditor(media);
                              }
                            })
                          : VideoPostTile(
                              width: Get.width,
                              url: media.file!.path,
                              isLocalFile: true,
                              play: true,
                              onTapActionHandler: () {
                                if (settingController
                                    .setting.value!.canEditPhotoVideo) {
                                  openVideoEditor(media);
                                }
                              },
                            )
                  ],
                  options: CarouselOptions(
                    aspectRatio: 1,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: false,
                    height: double.infinity,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      _selectPostMediaController.updateGallerySlider(index);
                    },
                  ),
                );
              }),
              Obx(() {
                return _selectPostMediaController.selectedMediaList.length > 1
                    ? Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                    height: 25,
                                    color: AppColorConstants.cardColor,
                                    child: DotsIndicator(
                                      dotsCount: _selectPostMediaController
                                          .selectedMediaList.length,
                                      position: _selectPostMediaController
                                          .currentIndex.value,
                                      decorator: DotsDecorator(
                                          activeColor:
                                              AppColorConstants.themeColor),
                                    ).hP8)
                                .round(20)),
                      )
                    : Container();
              })
            ],
          ).p16,
        ),
        const SizedBox(
          height: 20,
        ),
        if (_selectPostMediaController.selectedMediaList.isNotEmpty &&
            settingController.setting.value!.canEditPhotoVideo)
          Heading2Text(
            tapToEditString.tr,
            weight: TextWeight.bold,
          ),
      ],
    );
  }

  Widget addDescriptionView() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        descriptionText.value = TextEditingValue(
            text: _smartTextFieldController.searchText.value,
            selection: TextSelection.fromPosition(TextPosition(
                offset: _smartTextFieldController.position.value)));

        return Container(
          color: AppColorConstants.cardColor,
          child: SmartTextField(
              maxLine: 5,
              controller: descriptionText,
              onTextChangeActionHandler: (text, offset) {
                _smartTextFieldController.textChanged(text, offset);
              },
              onFocusChangeActionHandler: (status) {
                if (status == true) {
                  _smartTextFieldController.startedEditing();
                } else {
                  _smartTextFieldController.stoppedEditing();
                }
              }),
        ).round(5);
      }),
    );
  }

  openImageEditor(Media media) async {
    // PESDK.unlockWithLicense('');
    final result = await PESDK.openEditor(image: media.file!.path);

    if (result != null) {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      Media editedMedia = media.copy;
      editedMedia.file = File(result.image.replaceAll('file://', ''));
      _selectPostMediaController.replaceMediaWithEditedMedia(
          originalMedia: media, editedMedia: editedMedia);
    } else {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      return;
    }
  }

  openVideoEditor(Media media) async {
    // PESDK.unlockWithLicense('');
    print('openVideoEditor');
    final video = Video(media.file!.path);
    final result = await VESDK.openEditor(video);

    if (result != null) {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      Media editedMedia = media.copy;
      editedMedia.file = File(result.video.replaceAll('file://', ''));
      _selectPostMediaController.replaceMediaWithEditedMedia(
          originalMedia: media, editedMedia: editedMedia);
    } else {
      // The user exported a new photo successfully and the newly generated photo is located at `result.image`.
      return;
    }
  }
}
