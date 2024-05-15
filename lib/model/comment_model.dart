import 'package:foap/helper/date_extension.dart';
import 'package:foap/util/time_convertor.dart';
import 'package:get/get.dart';

import '../helper/enum.dart';
import '../helper/localization_strings.dart';
import '../util/app_config_constants.dart';
import 'user_model.dart';

class CommentModel {
  int id = 0;
  int? parentId;

  String comment = "";

  int userId = 0;
  String userName = '';
  String? userPicture;
  String commentTime = '';
  UserModel? user;
  CommentType type = CommentType.text; // text=1, image=2, video = 3, gif =4
  String filename = '';
  int level = 1;
  bool isFavourite = false;
  List<CommentModel> replies = [];
  int currentPageForReplies = 1;
  int pendingReplies = 0;

  int totalReplies = 0;

  CommentModel();

  factory CommentModel.fromJson(dynamic json) {
    CommentModel model = CommentModel();
    model.id = json['id'];
    model.parentId = json['parent_id'];

    model.comment = json['comment'];
    model.userId = json['user_id'];
    model.level = json['level'] ?? 1;
    model.isFavourite = json['isLike'] == 1;

    // model.replies = json['childCommentDetail'] == null
    //     ? []
    //     : (json['childCommentDetail'] as List)
    //         .map((e) => CommentModel.fromJson(e))
    //         .toList();

    model.totalReplies = json['totalChildComment'] ?? 0;
    model.pendingReplies = json['totalChildComment'] ?? 0;

    model.user = UserModel.fromJson(json['user']);
    dynamic user = json['user'];
    if (user != null) {
      model.userName = user['username'];
      model.userPicture = user['picture'];
    }

    model.type = json['type'] == 4
        ? CommentType.gif
        : json['type'] == 3
        ? CommentType.video
        : json['type'] == 2
        ? CommentType.image
        : CommentType.text;
    model.filename = json['filenameUrl'] ?? '';

    DateTime createDate =
    DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000).toUtc();
    model.commentTime = createDate.getTimeAgo;
    return model;
  }

  factory CommentModel.fromNewMessage(CommentType type, UserModel user,
      {required int id, String? comment, String? filename}) {
    CommentModel model = CommentModel();
    model.id = id;
    model.type = type;
    model.comment = comment ?? '';
    model.filename = type == CommentType.image
        ? '${AppConfigConstants.restApiBaseUrl}/uploads/image/${filename ?? ''}'
        : filename ?? '';

    model.userId = user.id;
    model.userName = user.userName;
    model.userPicture = user.picture;
    model.user = user;
    model.commentTime = justNowString.tr;

    return model;
  }

  bool get canReply {
    return level == 1;
  }
}
