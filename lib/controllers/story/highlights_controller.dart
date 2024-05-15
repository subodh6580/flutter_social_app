import 'dart:io';
import 'dart:typed_data';
import 'package:foap/apiHandler/apis/highlights_api.dart';
import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:foap/apiHandler/apis/story_api.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/highlights_imports.dart';
import '../../model/story_model.dart';

class HighlightsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<HighlightsModel> highlights = <HighlightsModel>[].obs;
  RxList<StoryMediaModel> selectedStoriesMedia = <StoryMediaModel>[].obs;
  RxList<StoryMediaModel> stories = <StoryMediaModel>[].obs;

  Rx<HighlightMediaModel?> storyMediaModel = Rx<HighlightMediaModel?>(null);
  Rx<HighlightsModel?> currentHighlight = Rx<HighlightsModel?>(null);

  String coverImage = '';
  String coverImageName = '';

  File? pickedImage;
  String? picture;
  UserModel? model;

  bool isLoading = true;

  clear() {
    selectedStoriesMedia.clear();
  }

  setCurrentHighlight(HighlightsModel highlight) {
    currentHighlight.value = highlight;
  }

  setCurrentStoryMedia(HighlightMediaModel storyMedia) {
    storyMediaModel.value = storyMedia;
    update();
  }

  updateCoverImage(File? image) {
    pickedImage = image;
    update();
  }

  updateCoverImagePath() {
    for (StoryMediaModel media in selectedStoriesMedia) {
      if (media.image != null) {
        coverImage = media.image!;
        coverImageName = media.imageName!;
        break;
      }
    }
  }

  void getHighlights({required int userId}) {
    isLoading = true;
    update();

    HighlightsApi.getHighlights(
        userId: userId,
        resultCallback: (result) {
          isLoading = false;
          highlights.value = result;
          update();
        });
  }

  getAllStories() {
    isLoading = true;
    update();
    StoryApi.getMyStories(resultCallback: (result) {
      isLoading = false;
      stories.value = result;
      update();
    });
  }

  createHighlights({required String name}) async {
    if (pickedImage != null) {
      await uploadCoverImage();
    }

    HighlightsApi.createHighlights(
        name: name,
        image: coverImageName,
        stories: selectedStoriesMedia
            .map((element) => element.id.toString())
            .toList()
            .join(','),
        resultCallback: () {
          getHighlights(userId: _userProfileManager.user.value!.id);

          Get.close(2);
        });
  }

  Future uploadCoverImage() async {
    Uint8List compressedData = await pickedImage!.compress();
    File file = File.fromRawPath(compressedData);
    await MiscApi.uploadFile(file.path,          mediaType: GalleryMediaType.photo,
        type: UploadMediaType.storyOrHighlights,
        resultCallback: (fileName, filePath) {
      coverImageName = fileName;
    });
  }

  deleteStoryFromHighlight() async {
    await HighlightsApi.deleteStoryFromHighlights(storyMediaModel.value!.id);
    if (currentHighlight.value!.medias.length == 1) {
      await HighlightsApi.deleteHighlight(currentHighlight.value!.id);
    }
  }
}
