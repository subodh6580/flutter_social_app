import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/profile_imports.dart';
import 'package:foap/screens/login_sign_up/set_profile_category_type.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);

  @override
  UpdateProfileState createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  bool isLoading = true;
  final picker = ImagePicker();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    reloadData();
  }

  reloadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.setUser(_userProfileManager.user.value!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          addProfileView(),
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyLargeText(
                        userNameString.tr,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.userName,
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeUserName())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(
                        categoryString.tr,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController
                                  .user.value!.profileCategoryTypeName,
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const SetProfileCategoryType(
                                  isFromSignup: false,
                                ))!
                            .then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(
                        passwordString.tr,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      const BodyMediumText(
                        '********',
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangePassword());
                      })
                    ],
                  ),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(
                        phoneNumberString.tr,
                        weight: TextWeight.medium,
                      ),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.phone ?? '',
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangePhoneNumber())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(paymentDetailString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => profileController.user.value != null
                          ? BodyMediumText(
                              profileController.user.value!.paypalId ?? '',
                            )
                          : Container()),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangePaypalId())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider().vP16,
                  Row(
                    children: [
                      BodyLargeText(locationString.tr,
                          weight: TextWeight.medium),
                      const Spacer(),
                      Obx(() => BodyMediumText(
                            '${profileController.user.value?.country ?? ''} ${profileController.user.value?.city ?? ''}',
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 15,
                      ).ripple(() {
                        Get.to(() => const ChangeLocation())!.then((value) {
                          reloadData();
                        });
                      })
                    ],
                  ),
                  divider().vP16,
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
          ),
        ],
      ),
    );
  }

  addProfileView() {
    return GetBuilder<ProfileController>(
        init: profileController,
        builder: (ctx) {
          return SizedBox(
            height: 320,
            child: profileController.user.value != null
                ? Stack(
                    children: [
                      Stack(
                        children: [
                          Container(
                            child:
                                profileController.user.value!.coverImage != null
                                    ? CachedNetworkImage(
                                            width: Get.width,
                                            height: 320,
                                            fit: BoxFit.cover,
                                            imageUrl: profileController
                                                .user.value!.coverImage!)
                                        .overlay(Colors.black26)
                                        .bottomRounded(40)
                                    : Container(
                                        width: Get.width,
                                        height: 320,
                                        color: AppColorConstants.themeColor
                                            .withOpacity(0.2),
                                      ).bottomRounded(40),
                          ),
                          Positioned(
                              bottom: 10,
                              right: DesignConstants.horizontalPadding,
                              child: Container(
                                color: AppColorConstants.cardColor,
                                child: BodyLargeText(editProfileCoverString.tr)
                                    .setPadding(
                                        left: 10, right: 10, top: 8, bottom: 8),
                              ).circular.ripple(() {
                                openImagePickingPopup(isCoverImage: true);
                              })),
                        ],
                      ),
                      SizedBox(
                        width: Get.width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              UserAvatarView(
                                      user: profileController.user.value!,
                                      size: 85,
                                      onTapHandler: () {})
                                  .ripple(() {
                                openImagePickingPopup(isCoverImage: false);
                              }),
                              BodyMediumText(
                                editProfilePictureString.tr,
                                color: Colors.white,
                              ).vP4.ripple(() {
                                openImagePickingPopup(isCoverImage: false);
                              }),
                              Heading5Text(
                                profileController.user.value!.userName,
                                weight: TextWeight.medium,
                                color: Colors.white,
                              ).setPadding(bottom: 4),
                              profileController.user.value?.email != null
                                  ? BodyMediumText(
                                      '${profileController.user.value!.email}',
                                      color: Colors.white70,
                                    )
                                  : Container(),
                              profileController.user.value?.country != null
                                  ? BodyMediumText(
                                      '${profileController.user.value?.country ?? ''},${profileController.user.value?.city ?? ''}',
                                      color: Colors.white70,
                                    ).vP4
                                  : Container(),
                            ]).p8,
                      ),
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: backNavigationBar(title: ''))
                    ],
                  )
                : Container(),
          );
        });
  }

  void openImagePickingPopup({required bool isCoverImage}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
              color: AppColorConstants.backgroundColor,
              child: Wrap(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 25),
                      child: Heading5Text(
                        addPhotoString.tr,
                        weight: TextWeight.bold,
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
                            profileController.editProfileImageAction(
                                pickedFile, isCoverImage);
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
                            profileController.editProfileImageAction(
                                pickedFile, isCoverImage);
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
              ),
            ).topRounded(20));
  }
}
