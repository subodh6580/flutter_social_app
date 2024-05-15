import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'gift_model.dart';
import 'live_tv_model.dart';

class CategoryModel {
  int id;
  String name;

  // String logo;
  String coverImage;

  // List<CategoryModel> subCategories = [];

  CategoryModel({
    required this.name,
    required this.id,
    // required this.logo,
    required this.coverImage,
    // required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        name: json["name"],
        id: json["id"],
        // logo: json["logoUrl"] ?? 'https://images.unsplash.com/photo-1662286844552-81c31af1416c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=800&q=60',
        coverImage: json["imageUrl"] ?? '',
        // subCategories: json["subCategory"] == null
        //     ? []
        //     : (json["subCategory"] as List<dynamic>)
        //     .map((e) => CategoryModel.fromJson(e))
        //     .toList(),
      );
}

class TvCategoryModel extends CategoryModel {
  // int id;
  // String name;

  // String logo;
  // String coverImage;
  List<TvModel> tvs = [];

  // List<CategoryModel> subCategories = [];

  TvCategoryModel({
    required String name,
    required int id,
    // required this.logo,
    required String coverImage,
    required this.tvs,

    // required this.subCategories,
  }) : super(name: name, id: id, coverImage: coverImage);

  factory TvCategoryModel.fromJson(Map<String, dynamic> json) =>
      TvCategoryModel(
        name: json["name"],
        id: json["id"],
        // logo: json["logoUrl"] ?? 'https://images.unsplash.com/photo-1662286844552-81c31af1416c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=800&q=60',
        coverImage: json["imageUrl"],
        tvs: json["liveTv"] == null
            ? []
            : (json["liveTv"] as List<dynamic>)
                .map((e) => TvModel.fromJson(e))
                .toList(),
      );
}

class GiftCategoryModel extends CategoryModel {
  List<GiftModel> gifts = [];

  GiftCategoryModel({
    required String name,
    required int id,
    required this.gifts,
    required String coverImage,

    // required this.subCategories,
  }) : super(name: name, id: id, coverImage: coverImage);

  factory GiftCategoryModel.fromJson(Map<String, dynamic> json) =>
      GiftCategoryModel(
        name: json["name"],
        id: json["id"],
        coverImage: json["imageUrl"],
        gifts: json["gift"] == null
            ? []
            : (json["gift"] as List<dynamic>)
                .map((e) => GiftModel.fromJson(e))
                .toList(),
      );
}

class PodcastCategoryModel extends CategoryModel {
  List<HostModel> podcasts = [];

  PodcastCategoryModel({
    required String name,
    required int id,
    required this.podcasts,
    required String coverImage,

    // required this.subCategories,
  }) : super(name: name, id: id, coverImage: coverImage);

  factory PodcastCategoryModel.fromJson(Map<String, dynamic> json) =>
      PodcastCategoryModel(
        name: json["name"],
        id: json["id"],
        coverImage: json["imageUrl"],
        podcasts: json["podcastList"] == null
            ? []
            : (json["podcastList"] as List<dynamic>)
            .map((e) => HostModel.fromJson(e))
            .toList(),
      );
}
