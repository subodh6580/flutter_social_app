import 'package:foap/helper/imports/common_import.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apiHandler/apis/auth_api.dart';
import '../../screens/login_sign_up/set_user_name.dart';
import '../../screens/login_sign_up/verify_phone_login_otp.dart';
import '../../util/shared_prefs.dart';
import 'dart:async';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/util/form_validator.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/screens/login_sign_up/reset_password.dart';

bool isLoginFirstTime = false;

class LoginController extends GetxController {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  bool passwordReset = false;
  int userNameCheckStatus = -1;
  RxBool canResendOTP = true.obs;

  RxString passwordStrengthText = ''.obs;
  RxDouble passwordStrength = 0.toDouble().obs;
  RxString phoneCountryCode = '+1'.obs;

  int pinLength = 4;
  RxBool hasError = false.obs;
  RxBool otpFilled = false.obs;

  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");

  void login(String email, String password) {
    if (FormValidator().isTextEmpty(email)) {
      showErrorMessage(
        pleaseEnterValidEmailString.tr,
      );
    } else if (FormValidator().isTextEmpty(password)) {
      showErrorMessage(
        pleaseEnterPasswordString.tr,
      );
    } else {
      AuthApi.login(
          email: email,
          password: password,
          successCallback: (authKey) async {
            await SharedPrefs().setAuthorizationKey(authKey);
            await _userProfileManager.refreshProfile();
            await _settingsController.getSettings();
            getIt<SocketManager>().connect();

            if (_userProfileManager.user.value!.userName.isEmpty) {
              Get.to(() => const SetUserName())!.then((value) {});
            } else {
              Get.offAll(() => const DashboardScreen());
              getIt<SocketManager>().connect();
            }
          });
      // AppUtil.checkInternet().then((value) {
      //   if (value) {
      //     ApiController().login(email, password).then((response) async {
      //       if (response.success) {
      //       } else {
      //         EasyLoading.dismiss();
      //         if (response.token != null) {
      //           Get.to(() => VerifyOTPScreen(
      //                 isVerifyingEmail: true,
      //                 isVerifyingPhone: false,
      //                 token: response.token!,
      //               ));
      //         } else {
      //           EasyLoading.dismiss();
      //           showErrorMessage(
      //             response.message,
      //           );
      //         }
      //       }
      //     });
      //   } else {
      //     showErrorMessage(
      //       noInternet,
      //     );
      //   }
      // });
    }
  }

  void phoneLogin({required String countryCode, required String phone}) {
    if (FormValidator().isTextEmpty(phone)) {
      showErrorMessage(pleaseEnterValidPhoneString.tr);
    } else {
      AuthApi.loginWithPhone(
          code: countryCode,
          phone: phone,
          successCallback: (token) {
            Get.to(() => VerifyRegistrationOTP(
                  token: token,
                ));
          });
    }
  }

  checkPassword(String password) {
    password = password.trim();

    if (password.isEmpty) {
      passwordStrength.value = 0;
      passwordStrengthText.value = pleaseEnterYourPassword.tr;
    } else if (password.length < 6) {
      passwordStrength.value = 1 / 4;
      passwordStrengthText.value = passwordIsToShort.tr;
    } else if (password.length < 8) {
      passwordStrength.value = 2 / 4;
      passwordStrengthText.value = passwordIsShortButAcceptable.tr;
    } else {
      if (!letterReg.hasMatch(password) || !numReg.hasMatch(password)) {
        // Password length >= 8
        // But doesn't contain both letter and digit characters
        passwordStrength.value = 3 / 4;
        passwordStrengthText.value = passwordMustByAlphanumeric.tr;
      } else {
        // Password length >= 8
        // Password contains both letter and digit characters
        passwordStrength.value = 1;
        passwordStrengthText.value = passwordIsGreat.tr;
      }
    }

    update();
  }

  void register({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
  }) {
    if (FormValidator().isTextEmpty(name) || userNameCheckStatus != 1) {
      showErrorMessage(
        pleaseEnterValidUserNameString.tr,
      );
    }
    if (name.contains(' ')) {
      showErrorMessage(
        userNameCanNotHaveSpaceString.tr,
      );
    } else if (FormValidator().isTextEmpty(email)) {
      showErrorMessage(
        pleaseEnterValidEmailString.tr,
      );
    } else if (FormValidator().isNotValidEmail(email)) {
      showErrorMessage(
        pleaseEnterValidEmailString.tr,
      );
    } else if (FormValidator().isTextEmpty(password)) {
      showErrorMessage(
        pleaseEnterPasswordString.tr,
      );
    } else if (FormValidator().isTextEmpty(confirmPassword)) {
      showErrorMessage(
        pleaseEnterConfirmPasswordString.tr,
      );
    } else if (password != confirmPassword) {
      showErrorMessage(
        passwordsDoesNotMatchedString.tr,
      );
    } else {
      AuthApi.register(
          email: email,
          name: name,
          password: password,
          successCallback: (token) {
            Get.to(() => VerifyRegistrationOTP(
                  // isVerifyingEmail: true,
                  // isVerifyingPhone: false,
                  token: token,
                ));
          });
    }
  }

  void resetPassword({
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) {
    if (FormValidator().isTextEmpty(newPassword)) {
      showErrorMessage(
        pleaseEnterPasswordString.tr,
      );
    } else if (FormValidator().isTextEmpty(confirmPassword)) {
      showErrorMessage(
        pleaseEnterConfirmPasswordString.tr,
      );
    } else if (newPassword != confirmPassword) {
      showErrorMessage(
        passwordsDoesNotMatchedString.tr,
      );
    } else {
      AuthApi.resetPassword(
          token: token,
          newPassword: newPassword,
          successCallback: () {
            passwordReset = true;
            update();
          });
    }
  }

  void verifyUsername(String userName) {
    if (userName.contains(' ')) {
      userNameCheckStatus = 0;
      update();
      return;
    }

    AuthApi.checkUsername(
        username: userName,
        successCallback: () {
          userNameCheckStatus = 1;
          update();
        },
        failureCallback: () {
          userNameCheckStatus = 0;
          update();
        });
  }

  phoneCodeSelected(String code) {
    phoneCountryCode.value = code;
  }

  otpTextFilled(String otp) {
    otpFilled.value = otp.length == pinLength;
    hasError.value = false;

    update();
  }

  otpCompleted() {
    otpFilled.value = true;
    hasError.value = false;

    update();
  }

  void resendOTP({required String token}) {
    EasyLoading.show(status: loadingString.tr);
    AuthApi.resendOTP(
        token: token,
        successCallback: () {
          EasyLoading.dismiss();
          canResendOTP.value = false;
          update();
        });
  }

  void callVerifyOTP({
    required bool isVerifyingEmail,
    required bool isVerifyingPhone,
    required String otp,
    required String token,
  }) {
    EasyLoading.show(status: loadingString.tr);

    if (isVerifyingEmail == true || isVerifyingPhone == true) {
      AuthApi.verifyRegistrationOTP(
          otp: otp,
          token: token,
          successCallback: (authKey) {
            EasyLoading.dismiss();

            Future.delayed(const Duration(milliseconds: 500), () async {
              await SharedPrefs().setAuthorizationKey(authKey);
              await _userProfileManager.refreshProfile();
              await _settingsController.getSettings();
              if (_userProfileManager.user.value != null) {
                if (_userProfileManager.user.value!.userName.isEmpty) {
                  isLoginFirstTime = true;
                  Get.offAll(() => const SetUserName());
                } else {
                  // ask for location
                  // AppUtil.showToast(
                  //     message: registeredSuccessFully,
                  //     isSuccess: true);
                  Get.to(() => const DashboardScreen());
                }
              }
            });
          });
    } else {
      AuthApi.verifyForgotPasswordOTP(
          otp: otp,
          token: token,
          successCallback: (token) {
            EasyLoading.dismiss();

            Future.delayed(const Duration(milliseconds: 500), () async {
              Get.to(() => ResetPasswordScreen(token: token));
            });
          });
    }
  }

  void callVerifyOTPForPhoneLogin({
    required String otp,
    required String token,
  }) {
    EasyLoading.show(status: loadingString.tr);

    AuthApi.verifyRegistrationOTP(
        otp: otp,
        token: token,
        successCallback: (authKey) {
          EasyLoading.dismiss();
          Future.delayed(const Duration(milliseconds: 500), () async {
            await SharedPrefs().setAuthorizationKey(authKey);
            await _userProfileManager.refreshProfile();
            await _settingsController.getSettings();

            if (_userProfileManager.user.value != null) {
              if (_userProfileManager.user.value!.userName.isEmpty) {
                isLoginFirstTime = true;
                Get.offAll(() => const SetUserName());
              } else {
                Get.to(() => const DashboardScreen());
              }
            }
          });
        });
  }

  void callVerifyOTPForChangePhone({
    required String otp,
    required String token,
  }) {
    AuthApi.verifyChangePhoneOTP(
        otp: otp,
        token: token,
        successCallback: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.back();
          });
        });
  }

  void forgotPassword({required String email}) {
    if (FormValidator().isTextEmpty(email)) {
      AppUtil.showToast(message: pleaseEnterEmailString.tr, isSuccess: false);
    } else if (FormValidator().isNotValidEmail(email)) {
      AppUtil.showToast(
          message: pleaseEnterValidEmailString.tr, isSuccess: false);
    } else {
      AuthApi.forgotPassword(
          email: email,
          successCallback: (token) {
            Get.to(() => VerifyRegistrationOTP(
                  // isVerifyingEmail: false,
                  // isVerifyingPhone: false,
                  token: token,
                ));
          });
    }
  }

  Future<void> launchUrlInBrowser(String url) async {
    await launchUrl(Uri.parse(url));
  }

  showSuccessMessage(String message) {
    AppUtil.showToast(message: message, isSuccess: true);
  }

  showErrorMessage(String message) {
    AppUtil.showToast(message: message, isSuccess: false);
  }
}
