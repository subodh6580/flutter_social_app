import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';

import '../apiHandler/apis/misc_api.dart';
import '../controllers/misc/users_controller.dart';
import '../helper/imports/common_import.dart';
import '../model/hash_tag.dart';

class SmartTextFieldController extends GetxController {
  RxInt isEditing = 0.obs;
  RxString currentHashtag = ''.obs;
  RxString currentUserTag = ''.obs;
  int currentUpdateAbleStartOffset = 0;
  int currentUpdateAbleEndOffset = 0;
  RxString searchText = ''.obs;
  RxInt position = 0.obs;
  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  DataWrapper hashtagDataWrapper = DataWrapper();
  final UsersController _usersController = Get.find();

  clear() {
    isEditing.value = 0;
    currentHashtag.value = '';
    currentUserTag.value = '';
    hashTags.clear();

    currentUpdateAbleStartOffset = 0;
    currentUpdateAbleEndOffset = 0;

    searchText.value = '';
    position.value = 0;

    hashtagDataWrapper = DataWrapper();
    _usersController.clear();
    update();
  }

  startedEditing() {
    isEditing.value = 1;
    update();
  }

  stoppedEditing() {
    isEditing.value = 0;
    update();
  }

  textChanged(String text, int position) {
    clear();
    isEditing.value = 1;
    searchText.value = text;
    String substring = text.substring(0, position).replaceAll("\n", " ");
    List<String> parts = substring.split(' ');
    String lastPart = parts.last;

    if (lastPart.startsWith('#') == true && lastPart.contains('@') == false) {
      if (currentHashtag.value.startsWith('#') == false ||
          currentUpdateAbleStartOffset == 0) {
        currentHashtag.value = lastPart;
        currentUpdateAbleStartOffset = substring.indexOf('#') + 1;
      }

      if (lastPart.length > 1) {
        hashTags.clear();
        searchHashTags(text: lastPart);
        currentUpdateAbleEndOffset = position;
      } else {
        hashTags.clear();
      }
    } else if (lastPart.startsWith('@') == true &&
        lastPart.contains('#') == false) {
      if (currentUserTag.value.startsWith('@') == false ||
          currentUpdateAbleStartOffset == 0) {
        currentUserTag.value = lastPart;
        currentUpdateAbleStartOffset = substring.indexOf('@') + 1;
      }
      if (lastPart.length > 1) {
        _usersController.setSearchTextFilter(
            lastPart.replaceAll('@', ''), () {});
        currentUpdateAbleEndOffset = position;
      }
    } else {
      if (currentHashtag.value.startsWith('#') == true) {
        currentHashtag.value = lastPart;
      }
      currentHashtag.value = '';
      hashTags.value = [];

      if (currentUserTag.value.startsWith('!') == true) {
        currentUserTag.value = lastPart;
      }
      currentUserTag.value = '';

      currentUpdateAbleStartOffset = 0;
      currentUpdateAbleEndOffset = 0;
    }
    this.position.value = position;
  }

  searchHashTags({required String text, VoidCallback? callBackHandler}) {
    if (hashtagDataWrapper.haveMoreData.value) {
      hashtagDataWrapper.isLoading.value = true;

      MiscApi.searchHashtag(
          page: hashtagDataWrapper.page,
          hashtag: text.replaceAll('#', ''),
          resultCallback: (result, metadata) {
            hashTags.addAll(result);
            hashTags.unique((e) => e.name);

            hashtagDataWrapper.processCompletedWithData(metadata);

            update();
            if (callBackHandler != null) {
              callBackHandler();
            }
          });
    } else {
      if (callBackHandler != null) {
        callBackHandler();
      }
    }
  }

  addUserTag(String user) {
    String updatedText = searchText.value.replaceRange(
        currentUpdateAbleStartOffset, currentUpdateAbleEndOffset, '$user ');
    searchText.value = updatedText;
    position.value = updatedText.indexOf(user, currentUpdateAbleStartOffset) +
        user.length +
        1;

    currentUserTag.value = '';
    _usersController.clear();
    update();
  }

  addHashTag(String hashtag) {
    String updatedText = searchText.value.replaceRange(
        currentUpdateAbleStartOffset, currentUpdateAbleEndOffset, '$hashtag ');
    position.value =
        updatedText.indexOf(hashtag, currentUpdateAbleStartOffset) +
            hashtag.length +
            1;

    searchText.value = updatedText;
    currentHashtag.value = '';

    update();
  }
}

class SmartTextField extends StatelessWidget {
  final int? maxLine;
  final TextEditingController controller;
  final Function(String, int) onTextChangeActionHandler;
  final Function(bool) onFocusChangeActionHandler;

  const SmartTextField(
      {Key? key,
      required this.controller,
      this.maxLine,
      required this.onTextChangeActionHandler,
      required this.onFocusChangeActionHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: TextField(
        controller: controller,
        textAlign: TextAlign.left,
        style: TextStyle(
            fontSize: FontSizes.b3, color: AppColorConstants.mainTextColor),
        maxLines: maxLine ?? 1,
        onChanged: (text) {
          onTextChangeActionHandler(text, controller.selection.baseOffset);
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            counterText: "",
            hintStyle: TextStyle(
                fontSize: FontSizes.b3,
                color: AppColorConstants.mainTextColor),
            hintText: typeHereString.tr),
      ).round(10),
      onFocusChange: (hasFocus) {
        onFocusChangeActionHandler(hasFocus);
      },
    );
  }
}
