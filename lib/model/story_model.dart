import 'package:foap/model/user_model.dart';
import 'package:foap/util/time_convertor.dart';

class StoryModel {
  int id;

  // int isReported;
  String name;
  String userName;
  String? userImage;
  List<StoryMediaModel> media;
  bool isViewed = false;

  StoryModel({
    required this.id,
    // required this.isReported,
    required this.name,
    required this.userName,
    this.userImage,
    required this.media,
  });

  factory StoryModel.fromJson(dynamic json) {
    StoryModel model = StoryModel(
      id: json['id'],
      // isReported: json['is_reported'],
      name: json['name'],
      userName: json['username'],
      userImage: json['picture'],
      media: (json['userStory'] as List<dynamic>)
          .map((e) => StoryMediaModel.fromJson(e))
          .toList(),
    );

    return model;
  }
}

class StoryMediaModel {
  int id;
  int userId;

  String? description;

  String? bgColor;
  String? video;
  String? image;
  String? imageName;
  int createdAtDate;
  int? videoDuration;
  String createdAt;
  int type;
  UserModel? user;
  int totalView;

  StoryMediaModel(
      {required this.id,
      required this.userId,
      required this.description,
      required this.bgColor,
      required this.video,
      required this.image,
      required this.imageName,
      required this.createdAtDate,
      required this.createdAt,
      required this.type,
      required this.user,
      required this.totalView,
      this.videoDuration});

  factory StoryMediaModel.fromJson(dynamic json) {
    StoryMediaModel model = StoryMediaModel(
        id: json['id'],
        userId: json['user_id'],
        description: json['description'],
        bgColor: json['background_color'],
        video: json['videoUrl'],
        videoDuration: json['video_time'],
        imageName: json['image'],
        image: json['imageUrl'],
        createdAtDate: json['created_at'] * 1000,
        createdAt: TimeAgo.timeAgoSinceDate(
            DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
                .toUtc()),
        type: json['type'],
        totalView: json['totalView'],
        user: json['user'] == null ? null : UserModel.fromJson(json['user']));

    return model;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "description": description,
        "background_color": bgColor,
        "videoUrl": video,
        "video_time": videoDuration,
        "image": imageName,
        "imageUrl": image,
        "created_at": createdAtDate,
        "type": type,
        "totalView": totalView,
      };

  isVideoPost() {
    return type == 3;
  }
}

class StoryViewerModel {
  String viewedAt = '';
  UserModel? user;

  StoryViewerModel();

  factory StoryViewerModel.fromJson(dynamic json) {
    StoryViewerModel model = StoryViewerModel();
    model.user = UserModel.fromJson(json['user']);
    model.viewedAt = TimeAgo.timeAgoSinceDate(
        DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000).toUtc());

    return model;
  }
}
