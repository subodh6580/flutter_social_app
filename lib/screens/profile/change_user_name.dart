import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';

class ChangeUserName extends StatefulWidget {
  const ChangeUserName({Key? key}) : super(key: key);

  @override
  State<ChangeUserName> createState() => _ChangeUserNameState();
}

class _ChangeUserNameState extends State<ChangeUserName> {
  TextEditingController userName = TextEditingController();
  final ProfileController profileController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    userName.text = _userProfileManager.user.value!.userName;
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
          profileScreensNavigationBar(
              title: changeUserNameString.tr,
              rightBtnTitle: doneString.tr,
              completion: () {
                profileController.updateUserName(
                  userName: userName.text,
                  isSigningUp: false,
                );
              }),
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading6Text(userNameString.tr, weight: TextWeight.medium),
              Stack(
                children: [
                  AppTextField(
                    controller: userName,
                    onChanged: (value) {
                      if (value.length > 3) {
                        profileController.verifyUsername(userName: value);
                      }
                    },
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: Center(
                      child: Obx(
                          () => profileController.userNameCheckStatus.value == 1
                              ? ThemeIconWidget(
                                  ThemeIcon.checkMark,
                                  color: AppColorConstants.themeColor,
                                )
                              : ThemeIconWidget(
                                  ThemeIcon.close,
                                  color: AppColorConstants.red,
                                )),
                    ),
                  ),
                ],
              ).vP8,
              const SizedBox(
                height: 20,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ],
      ),
    );
  }
}
