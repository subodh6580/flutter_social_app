import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../apiHandler/apis/misc_api.dart';
import '../../manager/socket_manager.dart';

class EnterGroupInfoController extends GetxController {
  final ChatHistoryController _chatHistoryController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  RxString groupImagePath = ''.obs;
  RxBool isPublicGroup = false.obs;

  groupImageSelected(String imagePath) {
    groupImagePath.value = imagePath;
    groupImagePath.refresh();
  }

  togglePublicGroup() {
    isPublicGroup.value = !isPublicGroup.value;
    update();
  }

  createGroup(
      {required String name,
      required String? description,
      required String image,
        required bool isPublicGroup,

        required List<UserModel> users}) {
    EasyLoading.show(
        status: loadingString.tr, maskType: EasyLoadingMaskType.black);

    if (image.isEmpty) {
      publishGroup(name: name,isPublicGroup:isPublicGroup, description: description, users: users);
    } else {
      // EasyLoading.show(status: loadingString.tr);
      MiscApi.uploadFile(image,
          mediaType: GalleryMediaType.photo,
          type: UploadMediaType.chat, resultCallback: (filename, filepath) {
        publishGroup(
            name: name,
            image: filename,
            isPublicGroup:isPublicGroup,
            description: description,
            users: users);
      });
    }
  }

  updateGroup({
    required ChatRoomModel group,
    required String name,
    required String? description,
    required String image,
  }) {
    EasyLoading.show(
        status: loadingString.tr, maskType: EasyLoadingMaskType.black);

    if (image.isEmpty) {
      publishUpdatedGroup(group: group, name: name, description: description);
    } else {
      MiscApi.uploadFile(image,
          mediaType: GalleryMediaType.photo,
          type: UploadMediaType.chat, resultCallback: (filename, filepath) {
        publishUpdatedGroup(
          group: group,
          name: name,
          image: filename,
          description: description,
        );
      });
    }
  }

  publishUpdatedGroup({
    required ChatRoomModel group,
    required String name,
    required String? description,
    String? image,
  }) async {
    await ChatApi.updateGroupChatRoom(group.id, name, image, description, null);
    Get.close(2);
  }

  publishGroup(
      {required String name,
      required String? description,
        required bool isPublicGroup,

        String? image,
      required List<UserModel> users}) {
    ChatApi.createGroupChatRoom(
        image: image,
        description: description,
        isPublicGroup:isPublicGroup,
        title: name,
        resultCallback: (roomId) {
          String allUsersIds = users.map((e) => e.id.toString()).join(',');
          allUsersIds =
              '${_userProfileManager.user.value!.id.toString()},$allUsersIds';

          getIt<SocketManager>().emit(SocketConstants.addUserInChatRoom,
              {'userId': allUsersIds, 'room': roomId});

          ChatApi.getChatRoomDetail(roomId, resultCallback: (result) async {
            Get.close(2);
            Get.to(() => ChatDetail(chatRoom: result));

            // save group in local storage
            await getIt<DBManager>().saveRooms([result]);

            _chatHistoryController.getChatRooms();
            _chatHistoryController.getPublicChatRooms(() {});
          });
        });
  }
}
