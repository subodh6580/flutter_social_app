class TvModel {
  int id = 0;
  int categoryId = 0;
  String name = '';
  String tvUrl = '';
  String image = '';
  String categoryName = '';
  String description = '';
  int isFav = 0;
  int isPaid = 0;
  int isLive = 0;

  int coinsNeededToUnlock = 0;
  int isSubscribed = 0;
  int totalViewer = 0;

  TvModel();

  factory TvModel.fromJson(dynamic json) {
    TvModel model = TvModel();
    model.id = json['id'];
    model.name = json['name'];
    model.categoryId = json['category_id'];
    model.tvUrl = json['tv_url'];
    model.image = json['imageUrl'];
    model.categoryName = json['categoryName'];
    model.description = json['description'];
    model.isFav = json['is_favorite'];
    model.isPaid = json['is_paid'] ?? 0;
    model.isLive = json['is_live'] ?? 0;

    model.coinsNeededToUnlock = json['paid_coin'] ?? 0;
    model.isSubscribed = json['is_subscribed'] ?? 0;
    model.totalViewer = json['currentViewer'] ?? 0;

    return model;
  }

  bool get isLocked {
    return isPaid == 1 && isSubscribed == 0;
  }

  bool get isLiveBroadcasting{
    return isLive == 1;
  }
}

// class MediaModel {
//   String? name;
//   String? image;
//   String? showTime;
//
//   MediaModel(this.name, this.image, this.showTime);
// }
