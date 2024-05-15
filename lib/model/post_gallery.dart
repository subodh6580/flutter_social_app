class PostGallery {
  int id;
  int postId;
  String fileName;
  String filePath;
  String? videoThumbnail;
  int mediaType; //  image=1, video=2, audio=3
  // int type;
  int currentIndexOfMediaToShow = 0;
  double height;
  double width;

  PostGallery(
      {required this.id,
        required this.fileName,
        required this.filePath,
        required this.postId,
        required this.mediaType,
        required this.height,
        required this.width,
        this.videoThumbnail});

  factory PostGallery.fromJson(dynamic json) {
    PostGallery galleryPost = PostGallery(
        id: json['id'],
        fileName: json['filename'] ?? "",
        filePath: json['filenameUrl'] ?? "",
        postId: json['post_id'],
        mediaType: json['media_type'],
        height: json['height'] == null
            ? 0.0
            : double.parse(json['height'].toString()),
        width: json['width'] == null
            ? 0.0
            : double.parse(json['width'].toString()),

        // type: json['type'],
        videoThumbnail: json['videoThumbUrl']);

    return galleryPost;
  }

  String get thumbnail {
    return isVideoPost == true ? videoThumbnail! : filePath;
  }

  bool get isVideoPost {
    return mediaType == 2 || videoThumbnail != null;
  }

  bool get isAudioPost {
    return mediaType == 3;
  }
}
