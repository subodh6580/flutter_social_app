import 'package:foap/helper/imports/chat_imports.dart';
import 'package:get/get.dart';

class SelectMediaController extends GetxController {
  RxList<Media> mediaList = <Media>[].obs;
  final RxList<Media> selectedItems = <Media>[].obs;

  RxBool allowMultipleSelection = false.obs;

  RxInt numberOfItems = 0.obs;
  bool isLoading = false;

  clear() {
    allowMultipleSelection.value = false;
    mediaList.clear();
  }

  mediaSelected(List<Media> media) {
    mediaList.value = media;
  }

  toggleMultiSelectionMode() {
    allowMultipleSelection.value = !allowMultipleSelection.value;
    update();
  }
}
