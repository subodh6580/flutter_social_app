class ReelMusicModel {
  int id;
  int categoryId;
  String name;
  String artists;
  int duration;
  String url;
  String thumbnail;
  int numberOfReelsMade;

  ReelMusicModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.artists,
    required this.url,
    required this.thumbnail,
    required this.numberOfReelsMade,
    required this.duration,
  });

  factory ReelMusicModel.fromJson(dynamic json) {
    ReelMusicModel model = ReelMusicModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      artists: json['artist'],
      url: json['audio_url'],
      thumbnail: json['image_url'],
      numberOfReelsMade: json['numberOfReelsMade'] ?? 0,
      duration: json['duration'] ?? 0,
    );

    return model;
  }
}
