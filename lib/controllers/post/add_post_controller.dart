import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:video_compress_ds/video_compress_ds.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../helper/enum_linking.dart';
import '../../screens/chat/media.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../home/home_controller.dart';
import 'package:path_provider/path_provider.dart';

class AddPostController extends GetxController {
  final HomeController _homeController = Get.find();

  RxInt currentIndex = 0.obs;

  Rx<PostingStatus> postingStatus = PostingStatus.none.obs;
  RxBool isErrorInPosting = false.obs;

  RxBool enableComments = true.obs;

  List<Media> postingMedia = [];
  late String postingTitle;

  RxBool isPreviewMode = false.obs;

  int hashtagsPage = 1;
  bool canLoadMoreHashtags = true;
  bool hashtagsIsLoading = false;

  PostType? currentPostType;

  clear() {
    currentIndex.value = 0;

    postingStatus.value = PostingStatus.none;
    isErrorInPosting.value = false;

    isPreviewMode.value = false;

    hashtagsPage = 1;
    canLoadMoreHashtags = true;
    hashtagsIsLoading = false;

    enableComments.value = true;

    update();
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
    update();
  }

  togglePreviewMode() {
    isPreviewMode.value = !isPreviewMode.value;
    update();
  }

  toggleEnableComments() {
    enableComments.value = !enableComments.value;
    update();
  }

  discardFailedPost() {
    postingMedia = [];
    postingTitle = '';
    postingStatus.value = PostingStatus.none;
    isErrorInPosting.value = false;
    clear();
  }

  retryPublish() {
    startUploadingPost(
        items: postingMedia,
        title: postingTitle,
        postType: currentPostType!,
        allowComments: true);
  }

  void startUploadingPost(
      {required PostType postType,
      required List<Media> items,
      required String title,
      required bool allowComments,
      int? competitionId,
      int? clubId,
      bool isReel = false,
      int? audioId,
      double? audioStartTime,
      double? audioEndTime}) async {
    currentPostType = postType;
    postingMedia = items;
    postingTitle = title;
    postingStatus.value = PostingStatus.posting;

    if (competitionId == null && clubId == null) {
      Get.offAll(() => const DashboardScreen());
    } else {
      EasyLoading.show(status: loadingString.tr);
    }

    var responses = await Future.wait([
      for (Media media in items)
        uploadMedia(
          media,
          competitionId,
        )
    ]).whenComplete(() {});

    publishAction(
      postType: postType,
      galleryItems: responses,
      title: title,
      tags: title.getHashtags(),
      mentions: title.getMentions(),
      allowComments: allowComments,
      competitionId: competitionId,
      clubId: clubId,
      isReel: isReel,
      audioId: audioId,
      audioStartTime: audioStartTime,
      audioEndTime: audioEndTime,
    );
  }

  Future<Map<String, String>> uploadMedia(
      Media media, int? competitionId) async {
    Map<String, String> gallery = {};
    final completer = Completer<Map<String, String>>();

    final tempDir = await getTemporaryDirectory();
    File file;
    String? videoThumbnailPath;

    if (media.mediaType == GalleryMediaType.photo) {
      Uint8List mainFileData = await media.file!.compress();

      file = await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
          .create();
      file.writeAsBytesSync(mainFileData);
      uploadMainFile(file, media, videoThumbnailPath, competitionId, completer);
    } else if (media.mediaType == GalleryMediaType.gif) {
      gallery = {
        'filename': media.filePath!,
        'video_thumb': videoThumbnailPath ?? '',
        'type': competitionId == null ? '1' : '2',
        'media_type': mediaTypeIdFromMediaType(media.mediaType!).toString(),
        'is_default': '1',
      };
      completer.complete(gallery);
    } else if (media.mediaType == GalleryMediaType.video) {
      EasyLoading.show(status: loadingString.tr);
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        media.file!.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );

      // code after compressing
      file = mediaInfo!.file!;

      File videoThumbnail = await File(
              '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.png')
          .create();

      videoThumbnail.writeAsBytesSync(media.thumbnail!);

      await PostApi.uploadFile(
        videoThumbnail.path,
        mediaType: media.mediaType!,
        resultCallback: (fileName, filePath) async {
          videoThumbnailPath = fileName;
          await videoThumbnail.delete();
        },
      );

      uploadMainFile(file, media, videoThumbnailPath, competitionId, completer);
    } else {
      // for audio files
      uploadMainFile(
          media.file!, media, videoThumbnailPath, competitionId, completer);
    }

    return completer.future;
  }

  Future uploadMainFile(File file, Media media, String? videoThumbnailPath,
      int? competitionId, Completer completer) async {
    Map<String, String> gallery = {};

    await PostApi.uploadFile(file.path, mediaType: media.mediaType!,
        resultCallback: (fileName, filePath) async {
      String imagePath = fileName;

      await file.delete();

      gallery = {
        'filename': imagePath,
        'video_thumb': videoThumbnailPath ?? '',
        'type': competitionId == null ? '1' : '2',
        'media_type': mediaTypeIdFromMediaType(media.mediaType!).toString(),
        'is_default': '1',
        'height': (media.size?.height ?? 0).toString(),
        'width': (media.size?.width ?? 0).toString(),
      };
      completer.complete(gallery);
    });
  }

  void publishAction({
    required PostType postType,
    required List<Map<String, String>> galleryItems,
    required String title,
    required List<String> tags,
    required List<String> mentions,
    required bool allowComments,
    int? competitionId,
    int? clubId,
    bool isReel = false,
    int? audioId,
    double? audioStartTime,
    double? audioEndTime,
  }) {
    PostApi.addPost(
        postType: postType,
        title: title,
        gallery: galleryItems,
        allowComments: allowComments,
        hashTag: tags.join(','),
        mentions: mentions.join(','),
        competitionId: competitionId,
        clubId: clubId,
        audioId: audioId,
        audioStartTime: audioStartTime,
        audioEndTime: audioEndTime,
        resultCallback: (postId) {
          if (postId != null) {
            if (competitionId != null || clubId != null) {
              Get.offAll(() => const DashboardScreen());
            }
            EasyLoading.dismiss();

            postingMedia = [];
            postingTitle = '';

            PostApi.getPostDetail(postId, resultCallback: (result) {
              if (result != null) {
                _homeController.addNewPost(result);
                // if (result.isReel) {
                //   ReelsController reelsController = Get.find();
                //   reelsController.addNewReel(result);
                // }
              }
              postingStatus.value = PostingStatus.posted;

              Future.delayed(const Duration(seconds: 2), () {
                postingStatus.value = PostingStatus.none;
              });
            });

            clear();
          } else {
            isErrorInPosting.value = true;
          }
        });
  }

  void updatePost({
    required int postId,
    required String title,
    required bool allowComments,
  }) {
    HomeController homeController = Get.find();

    PostApi.updatePost(
        postId: postId,
        title: title,
        allowComments: allowComments,
        successHandler: () {
          PostApi.getPostDetail(postId, resultCallback: (post) {
            if (post != null) {
              homeController.postEdited(post);
            }
          });
          Get.back();
        });
  }
}
