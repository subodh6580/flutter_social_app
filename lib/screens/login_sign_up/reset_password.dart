import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import '../../universal_components/rounded_input_field.dart';
import '../profile/password_changed_popup.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({Key? key, required this.token}) : super(key: key);

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  late String token;

  final LoginController controller = Get.find();

  @override
  void initState() {
    super.initState();
    token = widget.token;
  }

  @override
  void dispose() {
    controller.passwordReset = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 120,
              ),
              // Center(
              //     child: Image.asset(
              //   'assets/logo.png',
              //   width: 80,
              //   height: 25,
              // )),

              Heading2Text(
                resetPwdString.tr,
                weight: TextWeight.bold,
                color: AppColorConstants.themeColor,
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 40,
              ),
              addTextField(newPassword, newPasswordString.tr),
              addTextField(confirmPassword, confirmPasswordString.tr).tP25,
              const Spacer(),
              addSubmitBtn(),
              const SizedBox(
                height: 55,
              )
            ]).setPadding(left: 25, right: 25),
            GetBuilder<LoginController>(
                init: controller,
                builder: (ctx) {
                  return controller.passwordReset == true
                      ? Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: PasswordChangedPopup(dismissHandler: () {
                            controller.passwordReset = false;
                            _userProfileManager.logout();
                          }))
                      : Container();
                })
          ],
        ),
      ),
    );
  }

  Widget addTextField(TextEditingController controller, String hint) {
    return SizedBox(
      height: 48,
      child: PasswordField(
        onChanged: (value) {},
        controller: controller,
        showRevealPasswordIcon: true,
        hintText: hint,
      ),
    ).vP8.borderWithRadius(
          value: 1,
          radius: 5,
          color: AppColorConstants.dividerColor,
        );
  }

  addSubmitBtn() {
    return AppThemeButton(
      onPress: () {
        controller.resetPassword(
          newPassword: newPassword.text.trim(),
          confirmPassword: confirmPassword.text.trim(),
          token: token,
        );
      },
      text: changePwdString.tr,
    );
  }
}
