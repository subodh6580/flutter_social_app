import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import 'package:image_picker/image_picker.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../components/giphy/giphy_get.dart';
import '../../helper/imports/chat_imports.dart';
import '../../model/comment_model.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/constant_util.dart';

class CommentsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();
  final SettingsController _settingsController = Get.find();

  RxList<CommentModel> comments = <CommentModel>[].obs;

  DataWrapper commentsDataWrapper = DataWrapper();

  Rx<Media?> selectedMedia = Rx<Media?>(null);
  final ImagePicker _picker = ImagePicker();

  Rx<CommentModel?> replyingComment = Rx<CommentModel?>(null);

  clear() {
    commentsDataWrapper = DataWrapper();

    comments.clear();
    selectedMedia = Rx<Media?>(null);
  }

  setReplyComment(CommentModel? comment) {
    replyingComment.value = comment;
  }

  void getComments(int postId, VoidCallback callback) {
    if (commentsDataWrapper.haveMoreData.value) {
      PostApi.getComments(
          postId: postId,
          page: commentsDataWrapper.page,
          resultCallback: (result, metadata) {
            comments.addAll(result);
            comments.unique((e) => e.id);
            commentsDataWrapper.processCompletedWithData(metadata);

            update();
            callback();
          });
    } else {
      callback();
    }
  }

  void getChildComments({
    required int page,
    required int postId,
    required int parentId,
  }) {
    PostApi.getComments(
        postId: postId,
        parentId: parentId,
        page: page,
        resultCallback: (result, metadata) {
          CommentModel mainComment =
              comments.where((e) => e.id == parentId).first;
          mainComment.currentPageForReplies = metadata.currentPage + 1;
          mainComment.pendingReplies =
              metadata.totalCount - (metadata.currentPage * metadata.perPage);
          mainComment.replies.addAll(result);
          update();
        });
  }

  void postCommentsApiCall(
      {required String comment,
        required int postId,
        required VoidCallback commentPosted}) {
    PostApi.postComment(
        type: CommentType.text,
        postId: postId,
        parentCommentId: replyingComment.value?.id,
        comment: comment,
        resultCallback: (id) {
          CommentModel newComment = CommentModel.fromNewMessage(
              CommentType.text, _userProfileManager.user.value!,
              comment: comment, id: id);
          if (replyingComment.value == null) {
            comments.add(newComment);
          } else {
            newComment.level = 2;
            CommentModel mainComment =
                comments.where((e) => e.id == replyingComment.value!.id).first;
            mainComment.replies.add(newComment);
          }

          replyingComment.value = null;
          update();
        });
  }

  void deleteComment({required CommentModel comment}) {
    if (comment.level == 1) {
      comments.removeWhere((element) => element.id == comment.id);
    } else {
      CommentModel mainComment =
          comments.where((e) => e.id == comment.parentId).first;
      mainComment.replies.removeWhere((element) => element.id == comment.id);
    }

    update();
    PostApi.deleteComment(
        resultCallback: () {
          AppUtil.showToast(message: commentIsDeletedString, isSuccess: true);
        },
        commentId: comment.id);
  }

  void reportComment({required int commentId}) {
    PostApi.reportComment(
        resultCallback: () {
          AppUtil.showToast(message: commentIsReportedString, isSuccess: true);
        },
        commentId: commentId);
  }

  void favUnfavComment({required CommentModel comment}) {
    if (comment.isFavourite) {
      PostApi.favComment(resultCallback: () {}, commentId: comment.id);
    } else {
      PostApi.unfavComment(resultCallback: () {}, commentId: comment.id);
    }
  }

  void postMediaCommentsApiCall(
      {required int postId,
        required VoidCallback commentPosted,
        required CommentType type}) async {
    String filename = type == CommentType.image
        ? await uploadMedia(selectedMedia.value!)
        : selectedMedia.value!.filePath!;

    PostApi.postComment(
        type: type,
        postId: postId,
        filename: filename,
        resultCallback: (id) {
          comments.add(CommentModel.fromNewMessage(
              type, _userProfileManager.user.value!,
              filename: filename, id: id));
          update();
        });
  }

  Future<String> uploadMedia(Media media) async {
    String imagePath = '';

    await AppUtil.checkInternet().then((value) async {
      if (value) {
        final tempDir = await getTemporaryDirectory();
        Uint8List mainFileData = await media.file!.compress();

        //media
        File file =
        await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
            .create();
        file.writeAsBytesSync(mainFileData);

        await PostApi.uploadFile(file.path, mediaType: media.mediaType!,
            resultCallback: (fileName, filePath) async {
              imagePath = fileName;
              await file.delete();
            });
      } else {
        AppUtil.showToast(message: noInternetString.tr, isSuccess: false);
      }
    });
    return imagePath;
  }

  selectPhoto(
      {ImageSource source = ImageSource.gallery,
        required VoidCallback handler}) async {
    XFile? image = source == ImageSource.camera
        ? await _picker.pickImage(source: ImageSource.camera)
        : await _picker.pickImage(source: source);
    if (image != null) {
      Media media = Media();
      media.mediaType = GalleryMediaType.photo;
      media.file = File(image.path);
      media.id = randomId();
      selectedMedia.value = media;
      handler();
    }
  }

  void openGify(VoidCallback handler) async {
    String randomId = 'hsvcewd78djhbejkd';

    GiphyGif? gif = await GiphyGet.getGif(
      context: Get.context!,
      //Required
      apiKey: _settingsController.setting.value!.giphyApiKey!,
      //Required.
      lang: GiphyLanguage.english,
      //Optional - Language for query.
      randomID: randomId,
      // Optional - An ID/proxy for a specific user.
      tabColor: Colors.teal, // Optional- default accent color.
    );

    if (gif != null) {
      selectedMedia.value = Media(
          filePath: 'https://i.giphy.com/media/${gif.id}/200.gif',
          mediaType: GalleryMediaType.gif);
      handler();
    }
  }
}
