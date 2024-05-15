// import 'package:foap/helper/common_import.dart';
//
// class GalleryLoader {
//   List<GalleryMedia> mediaList = <GalleryMedia>[];
//
//   loadGalleryData({
//     required PostMediaType mediaType,
//     required BuildContext context,
//     required Function(List<GalleryMedia>) completion,
//   }) async {
//     final PermissionState ps = await PhotoManager.requestPermissionExtend();
//
//     if (ps.isAuth) {
//       // Granted.
//       final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
//           type: mediaType == PostMediaType.photo
//               ? RequestType.image
//               : mediaType == PostMediaType.video
//                   ? RequestType.video
//                   : RequestType.all);
//       for (AssetPathEntity path in paths) {
//         final List<AssetEntity> entities =
//             await path.getAssetListPaged(page: 0, size: 80);
//
//         for (AssetEntity entity in entities) {
//           Uint8List? originalBytes = await entity.originBytes;
//           Uint8List? thumbnailBytes;
//
//           File? videoFile;
//           if (entity.type == AssetType.video) {
//             thumbnailBytes = await entity.thumbnailData;
//             //videoFile = await entity.originFile;
//
//             final tempDir = await getTemporaryDirectory();
//             File videoThumbnail = await File(
//                     '${tempDir.path}/${entity.id.replaceAll('/', '')}_video.mov')
//                 .create();
//             videoThumbnail.writeAsBytesSync(originalBytes!);
//             videoFile = videoThumbnail;
//           }
//
//           if (originalBytes != null) {
//             var galleryImage = GalleryMedia(
//               bytes: originalBytes,
//               thumbnailBytes: thumbnailBytes,
//               id: entity.id,
//               dateCreated: entity.createDateTime.millisecondsSinceEpoch,
//               mediaType: entity.type == AssetType.video ? 2 : 1,
//               path: videoFile?.path ?? '',
//             );
//             if (mediaList.where((element) => element.id == entity.id).isEmpty) {
//               mediaList.add(galleryImage);
//             }
//           }
//         }
//       }
//
//       completion(mediaList);
//     } else {
//       AppUtil.showToast(
//           
//           message: noPhotosFound,
//           isSuccess: false);
//       // Limited(iOS) or Rejected, use `==` for more precise judgements.
//       // You can call `PhotoManager.openSetting()` to open settings for further steps.
//     }
//   }
// }
