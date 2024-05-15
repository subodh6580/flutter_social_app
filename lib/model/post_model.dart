import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/post_gallery.dart';
import '../screens/add_on/model/reel_music_model.dart';
import 'club_model.dart';

class PostModel {
  int id = 0;
  String title = '';

  late UserModel user;
  int? competitionId = 0;

  int totalView = 0;
  int totalLike = 0;
  int totalComment = 0;
  int totalShare = 0;
  int isWinning = 0;
  bool isLike = false;
  bool isSaved = false;
  bool commentsEnabled = true;
  int type = 1;

  bool isReported = false;
  bool isSharePost = false;

  List<PostGallery> gallery = [];
  List<String> tags = [];
  List<MentionedUsers> mentionedUsers = [];

  ReelMusicModel? audio;
  ClubModel? club;

  String postTime = '';
  DateTime? createDate;
  PostModel? sharedPost;

  PostModel();

  factory PostModel.fromJson(dynamic json) {
    PostModel model = PostModel();
    model.id = json['id'];
    model.title = json['title'] ?? 'No title';
    model.type = json['type'];

    model.user =
        json['user'] == null ? UserModel() : UserModel.fromJson(json['user']);
    model.competitionId = json['competition_id'];
    model.totalView = json['total_view'] ?? 0;
    model.totalLike = json['total_like'] ?? 0;
    model.totalComment = json['total_comment'] ?? 0;
    model.totalShare = json['total_share'] ?? 0;
    model.isWinning = json['is_winning'] ?? 0;

    model.isLike = json['is_like'] == 1;
    model.isReported = json['is_reported'] == 1;
    model.isSharePost = json['is_share_post'] == 1;
    model.isSaved = json['isFavorite'] == 1;
    model.commentsEnabled = json['is_comment_enable'] == 1;

    model.tags = [];
    if (json['hashtags'] != null && json['hashtags'].length > 0) {
      model.tags = List<String>.from(json['hashtags'].map((x) => '#$x'));
    }

    if (json['postGallary'] != null && json['postGallary'].length > 0) {
      model.gallery = List<PostGallery>.from(
          json['postGallary'].map((x) => PostGallery.fromJson(x)));
    }

    if (json['mentionUsers'] != null && json['mentionUsers'].length > 0) {
      model.mentionedUsers = List<MentionedUsers>.from(
          json['mentionUsers'].map((x) => MentionedUsers.fromJson(x)));
    }

    model.createDate = json['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
            .toUtc();

    model.postTime = model.createDate != null
        ? model.createDate!.getTimeAgo
        : justNowString.tr;
    model.audio =
        json['audio'] == null ? null : ReelMusicModel.fromJson(json['audio']);
    model.club = json['clubDetail'] == null
        ? null
        : ClubModel.fromJson(json['clubDetail']);
    model.sharedPost = json['originPost'] == null
        ? null
        : PostModel.fromJson(json['originPost']);

    return model;
  }

  bool get containVideoPost {
    return gallery.where((element) => element.isVideoPost).isNotEmpty;
  }

  bool get isMyPost {
    final UserProfileManager userProfileManager = Get.find();

    return user.id == userProfileManager.user.value!.id;
  }

  bool get isReel {
    return type == 4;
  }
}

class MentionedUsers {
  int id = 0;
  String userName = '';

  MentionedUsers();

  factory MentionedUsers.fromJson(dynamic json) {
    MentionedUsers model = MentionedUsers();
    model.id = json['user_id'];
    model.userName = json['username'].toString().toLowerCase();
    return model;
  }
}

class PostInsight {
  int totalView;
  int totalImpression;
  int totalShare;

  int viewFromFollowers;
  int viewFromNonFollowers;
  int viewFromMale;
  int viewFromFemale;
  int viewFromOther;
  int viewFromGenderNotDisclosed;
  int viewFromCountryNotDisclosed;
  int viewFromProfileCategoryNotDisclosed;
  int viewFromAgeNotDisclosed;
  int profileViewFromPost;
  int followFromPost;

  PostInsight({
    required this.totalView,
    required this.totalImpression,
    required this.totalShare,
    required this.viewFromFollowers,
    required this.viewFromNonFollowers,
    required this.viewFromMale,
    required this.viewFromFemale,
    required this.viewFromOther,
    required this.viewFromGenderNotDisclosed,
    required this.viewFromCountryNotDisclosed,
    required this.viewFromProfileCategoryNotDisclosed,
    required this.viewFromAgeNotDisclosed,
    required this.profileViewFromPost,
    required this.followFromPost,
  });

  factory PostInsight.fromJson(dynamic json) => PostInsight(
      totalView: json['total_view'],
      totalImpression: json['total_impression'],
      totalShare: json['total_share'] ?? 0,
      viewFromFollowers: json['follower'],
      viewFromNonFollowers: json['nonfollower'],
      viewFromMale: json['male'],
      viewFromFemale: json['female'],
      viewFromOther: json['other'],
      viewFromGenderNotDisclosed: json['gender_not_disclose'],
      viewFromCountryNotDisclosed: json['country_not_disclose'],
      viewFromProfileCategoryNotDisclosed:
          json['profile_category_type_not_disclose'],
      viewFromAgeNotDisclosed: json['age_not_disclose'],
      profileViewFromPost: json['profile_view'],
      followFromPost: json['follow_by_post']);
}
