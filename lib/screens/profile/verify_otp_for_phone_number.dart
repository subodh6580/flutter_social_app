import 'package:foap/helper/imports/common_import.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import '../../controllers/auth/login_controller.dart';

class VerifyOTPPhoneNumberChange extends StatefulWidget {
  final String token;

  const VerifyOTPPhoneNumberChange({Key? key, required this.token})
      : super(key: key);

  @override
  VerifyOTPPhoneNumberChangeState createState() =>
      VerifyOTPPhoneNumberChangeState();
}

class VerifyOTPPhoneNumberChangeState
    extends State<VerifyOTPPhoneNumberChange> {
  TextEditingController controller = TextEditingController(text: "");
  final LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ThemeIconWidget(
                ThemeIcon.backArrow,
                size: 20,
              ).ripple(() {
                Get.back();
              }),
              // Image.asset(
              //   'assets/logo.png',
              //   width: 80,
              //   height: 25,
              // ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          const SizedBox(
            height: 105,
          ),
          Heading5Text(
            helpToChangePhoneNumberString.tr,
            weight: TextWeight.bold,
            color: AppColorConstants.themeColor,
            textAlign: TextAlign.center,
          ),
          BodyLargeText(pleaseEnterOtpSentToYourPhoneString.tr,
                  color: AppColorConstants.themeColor)
              .setPadding(top: 43, bottom: 35),
          Obx(() => PinCodeTextField(
                autofocus: true,
                controller: controller,
                // hideCharacter: true,
                // highlight: true,
                highlightColor: Colors.blue,
                defaultBorderColor: Colors.transparent,
                hasTextBorderColor: Colors.transparent,
                pinBoxColor: AppColorConstants.red.withOpacity(0.2),
                highlightPinBoxColor:
                    AppColorConstants.themeColor.withOpacity(0.2),
                // highlightPinBoxColor: Colors.orange,
                maxLength: loginController.pinLength,
                hasError: loginController.hasError.value,
                // maskCharacter: "😎",
                onTextChanged: (text) {
                  loginController.otpTextFilled(text);
                },
                onDone: (text) {
                  loginController.otpCompleted();
                },
                pinBoxWidth: 50,
                pinBoxHeight: 50,
                // hasUnderline: true,
                wrapAlignment: WrapAlignment.spaceAround,
                pinBoxDecoration:
                    ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                pinTextStyle: TextStyle(
                    fontSize: FontSizes.h6,
                    color: AppColorConstants.themeColor),
                pinTextAnimatedSwitcherTransition:
                    ProvidedPinBoxTextAnimation.scalingTransition,
                pinTextAnimatedSwitcherDuration:
                    const Duration(milliseconds: 300),
                highlightAnimationBeginColor: Colors.black,
                highlightAnimationEndColor: Colors.white12,
                keyboardType: TextInputType.number,
              )),
          Obx(() => Row(
                children: [
                  BodyLargeText(didntReceivedCodeString.tr,
                      color: AppColorConstants.themeColor),
                  BodyLargeText(resendOTPString.tr,
                          color: loginController.canResendOTP.value == false
                              ? AppColorConstants.disabledColor
                              : AppColorConstants.themeColor,
                          weight: TextWeight.medium)
                      .ripple(() {
                    if (loginController.canResendOTP.value == true) {
                      loginController.resendOTP(
                          token: widget.token);
                    }
                  }),

                  loginController.canResendOTP.value == false
                      ? TweenAnimationBuilder<Duration>(
                          duration: const Duration(minutes: 2),
                          tween: Tween(
                              begin: const Duration(minutes: 2),
                              end: Duration.zero),
                          onEnd: () {
                            loginController.canResendOTP.value = true;
                          },
                          builder: (BuildContext context, Duration value,
                              Widget? child) {
                            final minutes = value.inMinutes;
                            final seconds = value.inSeconds % 60;
                            return BodyLargeText(' ($minutes:$seconds)',
                                textAlign: TextAlign.center,
                                color: AppColorConstants.themeColor);
                          })
                      : Container()
                ],
              )).setPadding(top: 20, bottom: 25),
          const Spacer(),
          Obx(() => loginController.otpFilled.value == true
              ? addSubmitBtn()
              : Container()),
          const SizedBox(
            height: 55,
          )
        ]),
      ).setPadding(left: 25, right: 25),
    );
  }

  addSubmitBtn() {
    return AppThemeButton(
      onPress: () {
        loginController.callVerifyOTPForChangePhone(
             otp: controller.text, token: widget.token);
      },
      text: verifyString.tr,

    );
  }
}
