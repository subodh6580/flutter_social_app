class PostGiftModel {
  int? id;
  String? name;
  int? isPaid;
  int? coin;

  PostGiftModel({this.id, this.name, this.isPaid, this.coin});

  PostGiftModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isPaid = json['is_paid'];
    coin = json['coin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['is_paid'] = isPaid;
    data['coin'] = coin;
    return data;
  }
}