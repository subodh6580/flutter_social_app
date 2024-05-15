import 'package:foap/model/story_model.dart';
import 'package:foap/util/time_convertor.dart';

class HighlightsModel {
  int id;
  int userId;

  String name;
  String coverImage;
  List<HighlightMediaModel> medias;

  HighlightsModel(
      {required this.id,
      required this.userId,
      required this.name,
      required this.coverImage,
      required this.medias});

  factory HighlightsModel.fromJson(Map<String, dynamic> json) =>
      HighlightsModel(
          id: json["id"],
          userId: json["user_id"],
          name: json["name"],
          coverImage: json["imageUrl"],
          medias: List<HighlightMediaModel>.from(json['highlightStory']
              .map((x) => HighlightMediaModel.fromJson(x))));
}

class HighlightMediaModel {
  int id;
  int highlightId;
  int storyId;

  String createdAt;
  StoryMediaModel story;

  HighlightMediaModel({
    required this.id,
    required this.highlightId,
    required this.storyId,
    required this.createdAt,
    required this.story,
  });

  factory HighlightMediaModel.fromJson(dynamic json) {
    HighlightMediaModel model = HighlightMediaModel(
        id: json['id'],
        highlightId: json['highlight_id'],
        storyId: json['story_id'],
        createdAt: TimeAgo.timeAgoSinceDate(
            DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
                .toUtc()),
        story: StoryMediaModel.fromJson(json['story']));

    return model;
  }
}
