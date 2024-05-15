import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../helper/enum.dart';
import '../../helper/enum_linking.dart';
import '../../helper/localization_strings.dart';
import '../../model/api_meta_data.dart';
import '../../model/comment_model.dart';
import '../../model/post_model.dart';
import '../../model/user_model.dart';
import '../api_wrapper.dart';

class PostApi {
  static addPost(
      {required PostType postType,
      required String title,
      required List<Map<String, String>> gallery,
      required bool allowComments,
      String? hashTag,
      String? mentions,
      int? competitionId,
      int? clubId,
      int? audioId,
      double? audioStartTime,
      double? audioEndTime,
      bool? addToPost,
      required Function(int?) resultCallback}) async {
    var url = competitionId == null
        ? NetworkConstantsUtil.addPost
        : NetworkConstantsUtil.addCompetitionPost;

    var parameters = {
      "type": postTypeValueFrom(postType).toString(),
      "title": title,
      "hashtag": hashTag,
      "mentionUser": mentions,
      "gallary": gallery,
      'competition_id': competitionId,
      'club_id': clubId,
      'post_content_type': gallery.isEmpty ? 1 : 2,
      'audio_id': audioId,
      'audio_start_time': audioStartTime,
      'audio_end_time': audioEndTime,
      'is_add_to_post': addToPost == true ? 1 : 0,
      'is_comment_enable': allowComments == true ? 1 : 0
    };

    ApiWrapper().postApi(url: url, param: parameters).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['post_id']);
      } else {
        resultCallback(null);
      }
    });
  }

  static updatePost(
      {required int postId,
      required String title,
      required bool allowComments,
      required VoidCallback successHandler}) async {
    var url = '${NetworkConstantsUtil.editPost}$postId';

    var parameters = {
      "title": title,
      'is_comment_enable': allowComments == true ? 1 : 0
    };

    await ApiWrapper().putApi(url: url, param: parameters).then((result) {
      if (result?.success == true) {
        successHandler();
      }
    });
  }

  static getPosts(
      {int? userId,
      int? isPopular,
      int? isFollowing,
      int? clubId,
      int? isSold,
      int? isReel,
      int? audioId,
      int? isMine,
      int? isSaved,
      int? isVideo,
      int? isRecent,
      String? title,
      String? hashtag,
      int page = 0,
      required Function(List<PostModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.searchPost;

    if (userId != null) {
      url = '$url&user_id=$userId';
    }
    if (isPopular != null) {
      url = '$url&is_popular_post=$isPopular';
    }
    if (title != null) {
      url = '$url&title=$title';
    }
    if (isRecent != null) {
      url = '$url&is_recent=$isRecent';
    }
    if (isFollowing != null) {
      url = '$url&is_following_user_post=$isFollowing';
    }
    if (isMine != null) {
      url = '$url&is_my_post=$isMine';
    }
    if (isSold != null) {
      url = '$url&is_winning_post=$isSold';
    }
    if (hashtag != null) {
      url = '$url&hashtag=$hashtag';
    }
    if (clubId != null) {
      url = '$url&club_id=$clubId';
    }
    if (isReel != null) {
      url = '$url&is_reel=$isReel';
    }
    if (audioId != null) {
      url = '$url&audio_id=$audioId';
    }
    if (isSaved != null) {
      url = '$url&is_favorite=1';
    }
    if (isVideo != null) {
      url = '$url&is_video_post=1';
    }
    url = '$url&page=$page';
    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper().getApi(url: url).then((response) {
      EasyLoading.dismiss();

      if (response?.data != null) {
        List<PostModel> posts = [];
        var items = response!.data['post']['items'];
        posts = List<PostModel>.from(items.map((x) => PostModel.fromJson(x)))
            .where((element) => element.gallery.isNotEmpty)
            .toList();

        APIMetaData metaData =
            APIMetaData.fromJson(response.data['post']['_meta']);

        resultCallback(posts, metaData);
      }
    });
  }

  static getMentionedPosts(
      {int? userId,
      int page = 0,
      required Function(List<PostModel>, APIMetaData) resultCallback}) async {
    var url = '${NetworkConstantsUtil.mentionedPosts}$userId&page=$page';

    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper().getApi(url: url).then((response) {
      EasyLoading.dismiss();

      if (response?.data != null) {
        List<PostModel> posts = [];
        var items = response!.data['post']['items'];
        posts = List<PostModel>.from(items.map((x) => PostModel.fromJson(x)))
            .where((element) => element.gallery.isNotEmpty)
            .toList();

        APIMetaData metaData =
            APIMetaData.fromJson(response.data['post']['_meta']);

        resultCallback(posts, metaData);
      }
    });
  }

  static Future<void> getPostDetail(int id,
      {required Function(PostModel?) resultCallback}) async {
    var url = NetworkConstantsUtil.postDetail;
    url = url.replaceAll('{id}', id.toString());
    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var post = response!.data['post'];
        resultCallback(PostModel.fromJson(post));
      } else {
        resultCallback(null);
      }
    });
  }

  static Future<void> getComments(
      {required int postId,
      int? parentId,
      required int page,
      required Function(List<CommentModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.getComments;
    if (parentId != null) {
      url = '$url?expand=user&post_id=$postId&parent_id=$parentId&page=$page';
    } else {
      url =
          '$url?expand=user,isLike,totalChildComment,childCommentDetail.isLike,childCommentDetail.user&post_id=$postId&page=$page';
    }

    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var items = response!.data['comment']['items'];
        resultCallback(
            List<CommentModel>.from(items.map((x) => CommentModel.fromJson(x))),
            APIMetaData.fromJson(response.data['comment']['_meta']));
      }
    });
  }

  static postComment(
      {required int postId,
      int? parentCommentId,
      required CommentType? type,
      required Function(int) resultCallback,
      String? comment,
      String? filename}) async {
    var url = NetworkConstantsUtil.addComment;

    await ApiWrapper().postApi(url: url, param: {
      "post_id": postId.toString(),
      "parent_id": parentCommentId ?? 0,
      'comment': comment ?? '',
      "type": type == CommentType.gif
          ? '4'
          : type == CommentType.video
              ? '3'
              : type == CommentType.image
                  ? '2'
                  : '1',
      "filename": filename ?? ''
    }).then((response) {
      if (response?.success == true) {
        var id = response!.data['id'];

        resultCallback(id);
      }
    });
  }

  static deleteComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.deleteComment + commentId.toString();

    await ApiWrapper().deleteApi(url: url).then((value) {
      resultCallback();
    });
  }

  static reportComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.reportComment;

    await ApiWrapper().postApi(
        url: url,
        param: {"post_comment_id": commentId.toString()}).then((value) {
      resultCallback();
    });
  }

  static favComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.likeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "1"
    }).then((value) {
      resultCallback();
    });
  }

  static unfavComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.unLikeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "1"
    }).then((value) {
      resultCallback();
    });
  }

  static reportPost(
      {required int postId, required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.reportPost;

    ApiWrapper()
        .postApi(url: url, param: {"post_id": postId.toString()}).then((value) {
      resultCallback();
    });
  }

  static deletePost(
      {required int postId, required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.deletePost;
    url = url.replaceAll('{{id}}', postId.toString());

    ApiWrapper().deleteApi(url: url).then((value) {
      resultCallback();
    });
  }

  static Future<void> getPostInsight(int id,
      {required Function(PostInsight) resultCallback}) async {
    var url = '${NetworkConstantsUtil.postInsight}$id';
    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        resultCallback(PostInsight.fromJson(response!.data['insight']));
      }
    });
  }

  static likeUnlikePost({required bool like, required int postId}) {
    var url = (like
        ? NetworkConstantsUtil.likePost
        : NetworkConstantsUtil.unlikePost);

    ApiWrapper().postApi(
        url: url, param: {"post_id": postId.toString()}).then((value) {});
  }

  static Future<void> postLikedByUsers(
      {required int postId,
      required int page,
      required Function(List<UserModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.postLikedByUsers
        .replaceAll('{{post_id}}', postId.toString());

    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var items = response!.data['results']['items'];
        resultCallback(
            List<UserModel>.from(
                items.map((x) => UserModel.fromJson(x['user']))),
            APIMetaData.fromJson(response.data['results']['_meta']));
      }
    });
  }

  static saveUnSavePost({required bool save, required int postId}) async {
    var url = (save
        ? NetworkConstantsUtil.savePost
        : NetworkConstantsUtil.removeSavedPost);

    await ApiWrapper().postApi(url: url, param: {
      "reference_id": postId.toString(),
      'type': '3'
    }).then((value) {});
  }

  static Future uploadFile(String filePath,
      {required GalleryMediaType mediaType,
      required Function(String, String) resultCallback}) async {
    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper()
        .uploadPostFile(
      url: NetworkConstantsUtil.uploadPostImage,
      file: filePath,
      mediaType: mediaType,
    )
        .then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        resultCallback(result!.data['filename'], result.data['fileUrl']);
      }
    });
  }
}
