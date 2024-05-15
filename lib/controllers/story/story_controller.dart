import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:foap/apiHandler/apis/story_api.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/model/story_model.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress_ds/video_compress_ds.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import '../../manager/db_manager.dart';
import '../../model/data_wrapper.dart';
import '../chat_and_call/chat_detail_controller.dart';
import '../home/home_controller.dart';

class AppStoryController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();
  RxList<Media> mediaList = <Media>[].obs;
  RxList<StoryViewerModel> storyViewers = <StoryViewerModel>[].obs;
  DataWrapper storyViewerDataWrapper = DataWrapper();

  RxBool allowMultipleSelection = false.obs;
  RxInt numberOfItems = 0.obs;

  Rx<StoryMediaModel?> currentStoryMediaModel = Rx<StoryMediaModel?>(null);
  bool isLoading = false;

  RxBool showEmoticons = false.obs;

  clearStoryViewers() {
    storyViewers.clear();
    storyViewerDataWrapper = DataWrapper();
  }

  showHideEmoticons(bool show) {
    showEmoticons.value = show;
  }

  mediaSelected(List<Media> media) {
    mediaList.value = media;
  }

  toggleMultiSelectionMode() {
    allowMultipleSelection.value = !allowMultipleSelection.value;
    update();
  }

  deleteStory(VoidCallback callback) {
    StoryApi.deleteStory(
        id: currentStoryMediaModel.value!.id, callback: callback);
  }

  setCurrentStoryMedia(StoryMediaModel storyMedia) {
    UserProfileManager userProfileManager = Get.find();

    clearStoryViewers();
    currentStoryMediaModel.value = storyMedia;
    getIt<DBManager>().storyViewed(storyMedia);
    if (storyMedia.userId == userProfileManager.user.value!.id) {
      loadStoryViewer();
    } else {
      StoryApi.viewStory(storyId: storyMedia.id);
    }
    update();
  }

  loadStoryViewer() {
    if (storyViewerDataWrapper.haveMoreData.value) {
      storyViewerDataWrapper.isLoading.value = true;
      StoryApi.getStoryViewers(
          storyId: currentStoryMediaModel.value!.id,
          page: storyViewerDataWrapper.page,
          resultCallback: (result, metadata) {
            storyViewers.addAll(result);

            storyViewerDataWrapper.processCompletedWithData(metadata);
          });
    }
  }

  void uploadAllMedia({required List<Media> items}) async {
    var responses =
        await Future.wait([for (Media media in items) uploadMedia(media)])
            .whenComplete(() {});

    publishAction(galleryItems: responses);
  }

  Future<Map<String, String>> uploadMedia(Media media) async {
    Map<String, String> gallery = {};
    final completer = Completer<Map<String, String>>();

    final tempDir = await getTemporaryDirectory();
    File mainFile;
    String? videoThumbnailPath;
    int videoDuration = 0;

    if (media.mediaType == GalleryMediaType.photo) {
      Uint8List mainFileData = await media.file!.compress();
      //image media
      mainFile =
          await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
              .create();
      mainFile.writeAsBytesSync(mainFileData);
    } else {
      EasyLoading.show(status: loadingString.tr);

      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        media.file!.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );
      mainFile = mediaInfo!.file!;

      final videoInfo = FlutterVideoInfo();
      var info = await videoInfo.getVideoInfo(media.file!.path);
      videoDuration = info!.duration!.toInt();

      File videoThumbnail = await File(
              '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.png')
          .create();

      videoThumbnail.writeAsBytesSync(media.thumbnail!);

      await MiscApi.uploadFile(videoThumbnail.path,
          mediaType: GalleryMediaType.photo,
          type: UploadMediaType.storyOrHighlights,
          resultCallback: (fileName, filePath) async {
        videoThumbnailPath = fileName;
        await videoThumbnail.delete();
      });
    }

    EasyLoading.show(status: loadingString.tr);

    await MiscApi.uploadFile(mainFile.path,
        mediaType: media.mediaType!, type: UploadMediaType.storyOrHighlights,
        resultCallback: (fileName, filePath) async {
      String mainFileUploadedPath = fileName;
      await mainFile.delete();
      gallery = {
        // 'image': media.mediaType == 1 ? mainFileUploadedPath : '',
        'image': media.mediaType == GalleryMediaType.photo
            ? mainFileUploadedPath
            : videoThumbnailPath!,
        'video': media.mediaType == GalleryMediaType.photo
            ? ''
            : mainFileUploadedPath,
        'video_time': videoDuration.toString(),
        'type': media.mediaType == GalleryMediaType.photo ? '2' : '3',
        'description': '',
        'background_color': '',
      };
      completer.complete(gallery);
    });

    return completer.future;
  }

  void publishAction({
    required List<Map<String, String>> galleryItems,
  }) {
    HomeController homeController = Get.find();
    StoryApi.postStory(
        gallery: galleryItems,
        successHandler: () {
          homeController.getStories();

          AppUtil.showToast(
              message: storyPostedSuccessfullyString, isSuccess: true);
        });
  }

  sendTextMessage(String message) {
    _chatDetailController.getChatRoomWithUser(
        userId: currentStoryMediaModel.value!.userId,
        callback: (room) {
          FocusScope.of(Get.context!).requestFocus(FocusNode());
          showHideEmoticons(false);

          _chatDetailController.sendStoryTextReplyMessage(
              messageText: message,
              storyMedia: currentStoryMediaModel.value!,
              room: room);
        });
  }

  sendReactionMessage(String emoji) {
    _chatDetailController.getChatRoomWithUser(
        userId: currentStoryMediaModel.value!.userId,
        callback: (room) {
          FocusScope.of(Get.context!).requestFocus(FocusNode());
          showHideEmoticons(false);
          _chatDetailController.sendStoryReactionReplyMessage(
              emoji: emoji,
              storyMedia: currentStoryMediaModel.value!,
              room: room);
        });
  }
}
