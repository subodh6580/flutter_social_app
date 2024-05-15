import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 55,
          ),
          profileScreensNavigationBar(

              title: changePwdString.tr,
              rightBtnTitle: doneString.tr,
              completion: () {
                profileController.resetPassword(
                    oldPassword: oldPassword.text,
                    newPassword: newPassword.text,
                    confirmPassword: confirmPassword.text,
                   );
              }),
          divider().vP8,
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading6Text(oldPwdStrString.tr,
                  weight: TextWeight.medium),
              addTextField(oldPassword, 'old_password').tP8,
              Heading6Text(newPwdStrString.tr,
                  weight: TextWeight.medium),
              addTextField(newPassword, 'new_password').tP8,
              Heading6Text(confirmPwdStrString.tr,
                      weight: TextWeight.medium)
                  .vP8,
              addTextField(confirmPassword, 'confirm_password'),
            ],
          ).hp(DesignConstants.horizontalPadding)
        ]),
      ),
    );
  }

  Widget addTextField(TextEditingController controller, String hint) {
    return SizedBox(
      height: 50,
      child: PasswordField(
        onChanged: (value) {},
        controller: controller,
        showRevealPasswordIcon: true,
        showDivider: true,
        hintText: '********',
      ),
    ).vP8;
  }
}
