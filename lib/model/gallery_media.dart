// class GalleryMedia {
//   Uint8List bytes;
//   Uint8List? thumbnailBytes;
//
//   String id;
//   int dateCreated;
//   int mediaType;
//   String path;
//
//   GalleryMedia(
//       {required this.bytes,
//       this.thumbnailBytes,
//       required this.id,
//       required this.dateCreated,
//       required this.mediaType,
//       required this.path});
// }

class UploadedGalleryMedia {
  int mediaType;
  String? thumbnail;
  String? video;
  String? audio;
  String? file;

  UploadedGalleryMedia(
      {required this.thumbnail,
      required this.mediaType,
      required this.video,
      required this.audio,
      required this.file});
}
