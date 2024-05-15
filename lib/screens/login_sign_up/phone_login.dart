import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  PhoneLoginScreenState createState() => PhoneLoginScreenState();
}

class PhoneLoginScreenState extends State<PhoneLoginScreen> {
  TextEditingController phone = TextEditingController();

  final LoginController controller = Get.find();

  bool showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SizedBox(
              height: Get.height,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: Get.height * 0.08,
                    ),
                    Heading3Text(welcomeString.tr, weight: TextWeight.bold),
                    SizedBox(
                      height: Get.height * 0.01,
                    ),
                    Heading3Text(signInMessageString.tr,
                        weight: TextWeight.medium),

                    SizedBox(
                      height: Get.height * 0.1,
                    ),
                    AppMobileTextField(
                      controller: phone,
                      // showDivider: true,
                      hintText: phoneNumberString.tr,
                      // cornerRadius: 5,
                      countryCodeText: '+${controller.phoneCountryCode.value}',
                      countryCodeValueChanged: (String value) {
                        controller.phoneCodeSelected(value);
                      },
                    ),

                    SizedBox(
                      height: Get.height * 0.04,
                    ),
                    addLoginBtn(),
                    SizedBox(
                      height: Get.height * 0.03,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const ForgotPasswordScreen());
                      },
                      child: Center(
                        child: BodyMediumText(
                          forgotPwdString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Get.height * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 1,
                          width: Get.width * 0.37,
                          color: AppColorConstants.themeColor,
                        ),
                        Heading6Text(
                          orString.tr,
                        ),
                        Container(
                          height: 1,
                          width: Get.width * 0.37,
                          color: AppColorConstants.themeColor,
                        )
                      ],
                    ),
                    SizedBox(
                      height: Get.height * 0.04,
                    ),
                    const SocialLogin(
                      hidePhoneLogin: true,
                    ).setPadding(left: 65, right: 65),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Heading6Text(
                          dontHaveAccountString.tr,
                        ),
                        Heading6Text(
                          signUpString.tr,
                          weight: TextWeight.medium,
                          color: AppColorConstants.themeColor,
                        ).ripple(() {
                          Get.to(() => const SignUpScreen());
                        }),
                      ],
                    ),
                    SizedBox(
                      height: Get.height * 0.05,
                    ),
                    // bioMetricView(),
                    // const Spacer(),
                  ]),
            )).setPadding(left: 25, right: 25),
      ),
    );
  }

  Widget addLoginBtn() {
    return AppThemeButton(
      onPress: () {
        controller.phoneLogin(
            countryCode: controller.phoneCountryCode.value,
            phone: phone.text.trim());
      },
      text: signInString.tr,
    );
  }
}
