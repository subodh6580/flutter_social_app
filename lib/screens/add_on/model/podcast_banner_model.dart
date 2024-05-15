import '../../../helper/enum.dart';

class PodcastBannerModel {
  int? id;
  String? name;
  String? coverImage;
  PodcastBannerType? bannerType;
  int? startTime;
  int? endTime;
  int? referenceId;
  int? createdAt;
  int? updatedAt;
  String? coverImageUrl;

  PodcastBannerModel(
      {this.id,
      this.name,
      this.coverImage,
      this.bannerType,
      this.startTime,
      this.endTime,
      this.referenceId,
      this.createdAt,
      this.updatedAt,
      this.coverImageUrl});

  PodcastBannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    coverImage = json['cover_image'];
    bannerType = json['banner_type'] == '1'
        ? PodcastBannerType.host
        : PodcastBannerType.show;
    startTime = json['start_time'];
    endTime = json['end_time'];
    referenceId = json['reference_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    coverImageUrl = json['coverImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['cover_image'] = coverImage;
    data['banner_type'] = bannerType;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['reference_id'] = referenceId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['coverImageUrl'] = coverImageUrl;
    return data;
  }
}
