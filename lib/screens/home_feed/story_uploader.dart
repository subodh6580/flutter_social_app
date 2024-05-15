import 'package:foap/helper/file_extension.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/story/story_controller.dart';
import '../../helper/imports/common_import.dart';
import '../chat/media.dart';

final ImagePicker _picker = ImagePicker();

void openStoryUploader() {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      builder: (context) => Container(
            color: AppColorConstants.cardColor.darken(0.15),
            width: Get.width,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                Heading4Text(
                  cameraString.tr,
                  weight: TextWeight.regular,
                ).makeChip().ripple(() {
                  Get.back();
                  selectPhoto(source: ImageSource.camera);
                }),
                Heading4Text(
                  photoString.tr,
                  weight: TextWeight.regular,
                ).makeChip().ripple(() {
                  Get.back();
                  selectPhoto(source: ImageSource.gallery);
                }),
                Heading4Text(
                  videoString.tr,
                  weight: TextWeight.regular,
                ).makeChip().ripple(() {
                  Get.back();
                  selectVideo(source: ImageSource.gallery);
                }),
              ],
            ).p(DesignConstants.horizontalPadding),
          ).topRounded(40));
}

selectPhoto({
  required ImageSource source,
}) async {
  if (source == ImageSource.camera) {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      Media media = await image.toMedia(GalleryMediaType.photo);
      postStoryMedia([media]);
    }
  } else {
    List<Media> mediaList = [];
    List<XFile> images = await _picker.pickMultiImage();

    for (XFile file in images) {
      Media media = await file.toMedia(GalleryMediaType.photo);
      mediaList.add(media);
    }
    postStoryMedia(mediaList);
  }
}

selectVideo({
  required ImageSource source,
}) async {
  XFile? file = await _picker.pickVideo(source: source);

  if (file != null) {
    Media media = await file.toMedia(GalleryMediaType.video);
    postStoryMedia([media]);
  }
}

postStoryMedia(List<Media> medias) {
  final AppStoryController storyController = Get.find();
  storyController.uploadAllMedia(items: medias);
}
