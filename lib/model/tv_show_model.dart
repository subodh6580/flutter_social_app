import 'package:intl/intl.dart';

class TVShowModel {
  int? id;
  String? name;
  int? tvChannelId;
  int? categoryId;
  String? language;
  String? ageGroup;
  String? description;
  String? image;
  int? createdAt;
  int? createdBy;
  String? showTime;
  String? imageUrl;
  double? ratingScore;
  int? totalRatings;

  TVShowModel(
      {this.id,
      this.name,
      this.tvChannelId,
      this.categoryId,
      this.language,
      this.ageGroup,
      this.description,
      this.image,
      this.createdAt,
      this.createdBy,
      this.showTime,
      this.imageUrl,
      this.totalRatings,
      this.ratingScore});

  TVShowModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tvChannelId = json['tv_channel_id'];
    categoryId = json['category_id'];
    language = json['language'];
    ageGroup = json['age_group'];
    description = json['description'];
    image = json['image'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    showTime = DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(json['show_time'] * 1000));
    imageUrl = json['imageUrl'];
    totalRatings = json['rating']['totalCount'] ?? 0;
    ratingScore = json['rating']['ratingScore'] ?? 0;
  }
}

class TVShowEpisodeModel {
  int? id;
  String? name;
  int? tvShowId;
  String? createdAt;
  String? episodePeriod;
  String? imageUrl;
  String? videoUrl;

  TVShowEpisodeModel({
    this.id,
    this.name,
    this.tvShowId,
    this.createdAt,
    this.episodePeriod,
    this.imageUrl,
    this.videoUrl,
  });

  TVShowEpisodeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tvShowId = json['tv_show_id'];
    episodePeriod = json['episode_period'];
    createdAt = DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000));
    imageUrl = json['imageUrl'];
    videoUrl = json['videoUrl'];
  }
}
