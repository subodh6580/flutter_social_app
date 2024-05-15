class PostSearchQuery {
  int? userId;
  int? isPopular;
  int? isFollowing;
  int? isSold;
  int? isMine;
  int? isRecent;
  int? clubId;
  int? isVideo;

  String? title;
  String? hashTag;

  // String uniqueId() {
  //   return '${userId}_${isPopular}_${isFollowing}_${isSold}_${isMine}_${isRecent}_${title}_$hashTag';
  // }

  @override
  bool operator ==(other) {
    return (other is PostSearchQuery) &&
        other.userId == userId &&
        other.isPopular == isPopular &&
        other.isFollowing == isFollowing &&
        other.isSold == isSold &&
        other.isMine == isMine &&
        other.isRecent == isRecent &&
        other.title == title &&
        other.clubId == clubId &&
        other.isVideo == isVideo &&
        other.hashTag == hashTag;
  }

  @override
  int get hashCode => super.hashCode;
}

class MentionedPostSearchQuery {
  int userId;

  MentionedPostSearchQuery({required this.userId});
}
