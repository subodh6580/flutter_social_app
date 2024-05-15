import 'dart:io';
import 'dart:typed_data';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../screens/chat/media.dart';
import '../util/constant_util.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

extension FileCompressor on File {
  Future<Uint8List> compress(
      {int? byQuality, int? minWidth, int? minHeight}) async {
    var result = await FlutterImageCompress.compressWithFile(
      absolute.path,
      minWidth: minWidth ?? 1000,
      minHeight: minHeight ?? 1000,
      quality: byQuality ?? 60,
      rotate: 0,
    );

    return result!;
  }
}

extension FileExtension on File {
  GalleryMediaType get mediaType {
    final mimeType = lookupMimeType(path)!.toLowerCase();

    switch (mimeType) {
      case 'image/png':
        return GalleryMediaType.photo;
      case 'image/jpg':
        return GalleryMediaType.photo;
      case 'image/jpeg':
        return GalleryMediaType.photo;

      case 'video/mp4':
        return GalleryMediaType.video;
      case 'video/mpeg':
        return GalleryMediaType.video;

      case 'audio/mpeg':
        return GalleryMediaType.audio;

      case 'application/pdf':
        return GalleryMediaType.pdf;

      case 'application/msword':
        return GalleryMediaType.doc;
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.template':
        return GalleryMediaType.doc;
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return GalleryMediaType.doc;

      case 'application/vnd.ms-excel':
        return GalleryMediaType.xls;

      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return GalleryMediaType.xls;

      case 'application/vnd.ms-powerpoint':
        return GalleryMediaType.ppt;
      case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        return GalleryMediaType.ppt;

      case 'text/plain':
        return GalleryMediaType.txt;
    }
    return GalleryMediaType.photo;
  }
}

extension XFileExtension on XFile {
  Future<Media> toMedia(GalleryMediaType mediaType) async {
    Media media = Media();
    media.mediaType = mediaType;
    media.file = File(path);
    media.mainFileBytes = await readAsBytes();
    media.title = name;
    if (mediaType == GalleryMediaType.video) {
      media.thumbnail = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 500,
        // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 25,
      );
    }

    media.id = randomId();
    return media;
  }
}
