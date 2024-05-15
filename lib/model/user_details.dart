// class Userdetails {
//   int? id;
//   String? name;
//   String? username;
//   String? image;
//   String? coverImage;
//   int? isReported;
//   String? picture;
//   String? coverImageUrl;
//   Null? userStory;
//   String? profileCategoryName;
//   int? isLike;
//
//   Userdetails(
//       {this.id,
//         this.name,
//         this.username,
//         this.image,
//         this.coverImage,
//         this.isReported,
//         this.picture,
//         this.coverImageUrl,
//         this.userStory,
//         this.profileCategoryName,
//         this.isLike});
//
//   Userdetails.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     username = json['username'];
//     image = json['image'];
//     coverImage = json['cover_image'];
//     isReported = json['is_reported'];
//     picture = json['picture'];
//     coverImageUrl = json['coverImageUrl'];
//     userStory = json['userStory'];
//     profileCategoryName = json['profileCategoryName'];
//     isLike = json['is_like'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['username'] = this.username;
//     data['image'] = this.image;
//     data['cover_image'] = this.coverImage;
//     data['is_reported'] = this.isReported;
//     data['picture'] = this.picture;
//     data['coverImageUrl'] = this.coverImageUrl;
//     data['userStory'] = this.userStory;
//     data['profileCategoryName'] = this.profileCategoryName;
//     data['is_like'] = this.isLike;
//     return data;
//   }
// }