import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:image_picker/image_picker.dart';

class UpdateGroupInfo extends StatefulWidget {
  final ChatRoomModel group;

  const UpdateGroupInfo({Key? key, required this.group}) : super(key: key);

  @override
  State<UpdateGroupInfo> createState() => _UpdateGroupInfoState();
}

class _UpdateGroupInfoState extends State<UpdateGroupInfo> {
  final EnterGroupInfoController enterGroupInfoController =
      EnterGroupInfoController();

  final TextEditingController groupName = TextEditingController();
  final TextEditingController groupDescription = TextEditingController();
  final picker = ImagePicker();

  @override
  void initState() {
    groupName.text = widget.group.name!;
    groupDescription.text = widget.group.description ?? '';

    super.initState();
  }

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
                    Heading5Text(updateString.tr,
                            weight: TextWeight.medium)
                        .ripple(() {
                      updateGroup();
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
          const SizedBox(height: 8,),
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
                          child:
                              enterGroupInfoController.groupImagePath.isNotEmpty
                                  ? Image.file(
                                      File(enterGroupInfoController
                                          .groupImagePath.value),
                                      fit: BoxFit.cover,
                                      height: 50,
                                      width: 50,
                                    )
                                  : widget.group.image != null &&
                                          widget.group.image?.isNotEmpty == true
                                      ? CachedNetworkImage(
                                          imageUrl: widget.group.image!,
                                          fit: BoxFit.cover,
                                          height: 50,
                                          width: 50,
                                        )
                                      : const ThemeIconWidget(
                                          ThemeIcon.camera,
                                          size: 15,
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
        ],
      ),
    );
  }

  updateGroup() {
    if (groupName.text.isEmpty) {
      AppUtil.showToast(
          message: pleaseEnterGroupNameString.tr, isSuccess: false);
      return;
    }

    enterGroupInfoController.updateGroup(
        group: widget.group,
        name: groupName.text,
        description: groupDescription.text,
        image: enterGroupInfoController.groupImagePath.value,
        );
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
                    leading: Icon(Icons.close, color: AppColorConstants.iconColor),
                    title: BodyLargeText(cancelString.tr),
                    onTap: () => Get.back()),
              ],
            ));
  }
}
