import 'package:intl/intl.dart';

class HostModel {
  int id = 0;
  int categoryId = 0;
  String name = '';
  String webUrl = '';
  int isPaid = 0;
  int paidCoin = 0;
  String description = '';
  String image = '';
  String copyright = '';
  String categoryName = '';
  int isSubscribed = 0;
  int isFavorite = 0;
  int currentViewer = 0;

  HostModel();

  factory HostModel.fromJson(dynamic json) {
    HostModel model = HostModel();
    model.id = json['id'];
    model.name = json['name'];
    model.categoryId = json['category_id'];
    model.webUrl = json['web_url'];
    model.isPaid = json['is_paid'] ?? 0;
    model.paidCoin = json['paid_coin'] ?? 0;
    model.description = json['description'] ?? '';
    model.image = json['imageUrl'];
    model.copyright = json['copyright'];
    model.categoryName = json['categoryName'];
    model.isSubscribed = json['is_subscribed'] ?? 0;
    model.isFavorite = json['is_favorite'] ?? 0;
    model.currentViewer = json['currentViewer'] ?? 0;

    return model;
  }

  bool get isLocked {
    return isPaid == 1 && isSubscribed == 0;
  }
}

class PodcastModel {
  int id = 0;
  String name = '';
  int podcastChannelId = 0;
  int categoryId = 0;
  String language = '';
  String ageGroup = '';
  String description = '';
  String image = '';
  String showTime = '';

  PodcastModel();

  factory PodcastModel.fromJson(dynamic json) {
    PodcastModel model = PodcastModel();
    model.id = json['id'];
    model.name = json['name'];
    model.podcastChannelId = json['podcast_channel_id'];
    model.categoryId = json['category_id'];
    model.language = json['language'];
    model.ageGroup = json['age_group'];
    model.description = json['description'] ?? '';
    model.image = json['imageUrl'];
    model.showTime = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(json['show_time'] * 1000));
    return model;
  }
}

class PodcastEpisodeModel {
  int id = 0;
  String name = '';
  int podcastShowId = 0;
  String episodePeriod = '';
  String imageUrl = '';
  String audioUrl = '';

  PodcastEpisodeModel();

  factory PodcastEpisodeModel.fromJson(dynamic json) {
    PodcastEpisodeModel model = PodcastEpisodeModel();
    model.id = json['id'];
    model.name = json['name'];
    model.podcastShowId = json['podcast_show_id'];
    model.episodePeriod = json['episode_period'];
    model.imageUrl = json['imageUrl'];
    model.audioUrl = json['audioUrl'];
    return model;
  }
}