import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:image_picker/image_picker.dart';

class EnterGroupInfo extends StatefulWidget {
  const EnterGroupInfo({Key? key}) : super(key: key);

  @override
  State<EnterGroupInfo> createState() => _EnterGroupInfoState();
}

class _EnterGroupInfoState extends State<EnterGroupInfo> {
  final EnterGroupInfoController enterGroupInfoController =
      EnterGroupInfoController();
  final SelectUserForGroupChatController selectUserForGroupChatController =
      Get.find();
  final TextEditingController groupName = TextEditingController();
  final TextEditingController groupDescription = TextEditingController();
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ThemeIconWidget(
                      ThemeIcon.close,
                      size: 20,
                    ).ripple(() {
                      Navigator.of(context).pop();
                    }),
                    BodyLargeText(createString.tr, weight: TextWeight.medium)
                        .ripple(() {
                      createGroup();
                    }),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Heading5Text(createGroupString.tr,
                        weight: TextWeight.medium),
                  ),
                )
              ],
            ),
          ).hp(DesignConstants.horizontalPadding),
          divider().tP8,
          SizedBox(
            height: 250,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Obx(() => Container(
                          height: 50,
                          width: 50,
                          color: AppColorConstants.cardColor.darken(),
                          child: enterGroupInfoController.groupImagePath.isEmpty
                              ? const ThemeIconWidget(
                                  ThemeIcon.camera,
                                  size: 15,
                                )
                              : Image.file(
                                  File(enterGroupInfoController
                                      .groupImagePath.value),
                                  fit: BoxFit.cover,
                                  height: 50,
                                  width: 50,
                                ),
                        ).circular.ripple(() {
                          openImagePickingPopup();
                        })),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: groupName,
                        hintText: groupNameString.tr,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                AppTextField(
                  maxLines: 5,
                  controller: groupDescription,
                  hintText: describeAboutGroupString.tr,
                )
              ],
            ),
          ).hp(DesignConstants.horizontalPadding),
          const SizedBox(
            height: 20,
          ),
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BodyMediumText(
                    publicGroupString.tr,
                    weight: TextWeight.semiBold,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ThemeIconWidget(
                      enterGroupInfoController.isPublicGroup.value
                          ? ThemeIcon.selectedCheckbox
                          : ThemeIcon.emptyCheckbox)
                      .ripple(() {
                    enterGroupInfoController.togglePublicGroup();
                  }),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if (enterGroupInfoController.isPublicGroup.value)
                BodySmallText(
                  groupGroupInfoString.tr,
                ),
            ],
          ).hp(DesignConstants.horizontalPadding)),
        ],
      ),
    );
  }

  createGroup() {
    if (groupName.text.isEmpty) {
      AppUtil.showToast(
          message: pleaseEnterGroupNameString.tr, isSuccess: false);
      return;
    }
    if (selectUserForGroupChatController.selectedFriends.isEmpty) {
      AppUtil.showToast(message: pleaseSelectUsersString.tr, isSuccess: false);
      return;
    }
    EasyLoading.show(status: loadingString.tr);
    enterGroupInfoController.createGroup(
        name: groupName.text,
        description: groupDescription.text,
        users: selectUserForGroupChatController.selectedFriends,
        image: enterGroupInfoController.groupImagePath.value,
        isPublicGroup: enterGroupInfoController.isPublicGroup.value);
  }

  void openImagePickingPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 25),
                    child: BodyLargeText(
                      addPhotoString.tr,
                    )),
                ListTile(
                    leading: Icon(Icons.camera_alt_outlined,
                        color: AppColorConstants.iconColor),
                    title: BodyLargeText(takePhotoString.tr),
                    onTap: () {
                      Get.back();
                      picker
                          .pickImage(source: ImageSource.camera)
                          .then((pickedFile) {
                        if (pickedFile != null) {
                          enterGroupInfoController
                              .groupImageSelected(pickedFile.path);
                        } else {}
                      });
                    }),
                divider(),
                ListTile(
                    leading: Icon(Icons.wallpaper_outlined,
                        color: AppColorConstants.iconColor),
                    title: BodyLargeText(chooseFromGalleryString.tr),
                    onTap: () async {
                      Get.back();
                      picker
                          .pickImage(source: ImageSource.gallery)
                          .then((pickedFile) {
                        if (pickedFile != null) {
                          enterGroupInfoController
                              .groupImageSelected(pickedFile.path);
                        } else {}
                      });
                    }),
                divider(),
                ListTile(
                    leading:
                        Icon(Icons.close, color: AppColorConstants.iconColor),
                    title: BodyLargeText(cancelString.tr),
                    onTap: () => Get.back()),
              ],
            ));
  }
}
