import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../helper/localization_strings.dart';
import '../../util/app_util.dart';
import '../../util/shared_prefs.dart';
import '../api_wrapper.dart';

class AuthApi {
  static login(
      {required String email,
      required String password,
      required Function(String) successCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();
    dynamic param = {
      "email": email,
      "password": password,
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? ''
    };
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.login, param: param)
        .then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        String authKey = response!.data!['auth_key'];
        successCallback(authKey);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static logout() async {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApi(url: NetworkConstantsUtil.logout, param: {}).then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static loginWithPhone(
      {required String code,
      required String phone,
      required Function(String) successCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();

    dynamic param = {
      "country_code": code,
      "phone": phone,
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? ''
    };
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApiWithoutToken(
            url: NetworkConstantsUtil.loginWithPhone, param: param)
        .then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        String token = response!.data!['verify_token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static socialLogin(
      {required String name,
      required String socialType,
      required String socialId,
      required String email,
      required Function(String) successCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.socialLogin, param: {
      "name": name,
      "username": "",
      "social_type": socialType,
      "social_id": socialId,
      "email": email,
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? ''
    }).then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        String authKey = response!.data!['auth_key'];

        successCallback(authKey);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static register(
      {required String email,
      required String name,
      required String password,
      required Function(String) successCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();
    EasyLoading.show(status: loadingString.tr);
    ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.register, param: {
      "username": name,
      "name": name,
      "email": email,
      "password": password,
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? ''
    }).then((response) {
      EasyLoading.dismiss();
      if (response?.success == true) {
        String token = response!.data!['token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static deleteAccount({required VoidCallback successCallback}) async {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApi(url: NetworkConstantsUtil.deleteAccount, param: null)
        .then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static updateFcmToken() async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();
    // EasyLoading.show(status: loadingString.tr);

    ApiWrapper().postApi(url: NetworkConstantsUtil.updatedDeviceToken, param: {
      "device_type": Platform.isAndroid ? '1' : '2',
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? ''
    }).then((response) {
      // EasyLoading.dismiss();

      if (response?.success == true) {
        // successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static checkUsername(
      {required String username,
      required VoidCallback successCallback,
      required VoidCallback failureCallback}) async {
    // EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.checkUserName, param: {
      "username": username,
    }).then((response) {
      // EasyLoading.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        failureCallback();
      }
    });
  }

  static forgotPassword(
      {required String email,
      required Function(String) successCallback}) async {
    dynamic param = {
      "verification_with": '1',
      "email": email,
      "country_code": '',
      "phone": ''
    };
    EasyLoading.show(status: loadingString.tr);
    ApiWrapper()
        .postApiWithoutToken(
            url: NetworkConstantsUtil.forgotPassword, param: param)
        .then((response) {
      EasyLoading.dismiss();
      if (response?.success == true) {
        String token = response!.data!['token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static resetPassword(
      {required String token,
      required String newPassword,
      required VoidCallback successCallback}) async {
    dynamic param = {
      "token": token,
      "password": newPassword,
    };
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApiWithoutToken(
            url: NetworkConstantsUtil.resetPassword, param: param)
        .then((response) {
      EasyLoading.dismiss();
      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static resendOTP(
      {required String token, required VoidCallback successCallback}) async {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.resendOTP, param: {
      "token": token,
    }).then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static verifyRegistrationOTP(
      {required String otp,
      required String token,
      required Function(String) successCallback}) async {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper().postApiWithoutToken(
        url: NetworkConstantsUtil.verifyRegistrationOTP,
        param: {
          "otp": otp,
          "token": token,
        }).then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        String authKey = response!.data!['auth_key'];

        successCallback(authKey);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static verifyForgotPasswordOTP(
      {required String otp,
      required String token,
      required Function(String) successCallback}) async {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.verifyFwdPWDOTP, param: {
      "otp": otp,
      "token": token,
    }).then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        String token = response!.data!['verify_token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static verifyChangePhoneOTP(
      {required String otp,
      required String token,
      required VoidCallback successCallback}) async {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .postApi(url: NetworkConstantsUtil.verifyChangePhoneOTP, param: {
      "otp": otp,
      "verify_token": token,
    }).then((response) {
      EasyLoading.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }
}
