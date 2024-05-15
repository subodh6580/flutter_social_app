import 'dart:developer';
import 'dart:typed_data';
import 'package:foap/helper/imports/models.dart';
import 'package:latlng/latlng.dart';
import 'package:foap/apiHandler/api_wrapper.dart';
import '../../helper/imports/common_import.dart';

class ProfileApi {
  static getMyProfile({required Function(UserModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getMyProfile;
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        log('user profile ${result!.data['user']}');
        resultCallback(UserModel.fromJson(result.data['user']));
      }
    });
  }

  static updateUserName(
      {required String userName, required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.updateUserProfile;

    ApiWrapper().postApi(url: url, param: {
      "username": userName,
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateProfileCategoryType(
      {required int categoryType, required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.updateUserProfile;

    ApiWrapper().postApi(url: url, param: {
      "profile_category_type": categoryType.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateBiometricSetting(
      {required int setting, required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.updateUserProfile;

    ApiWrapper().postApi(url: url, param: {
      "is_biometric_login": setting.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updatePhone(
      {required String countryCode,
      required String phone,
      required Function(String) resultCallback}) {
    var url = NetworkConstantsUtil.updatePhone;

    ApiWrapper().postApi(
        url: url,
        param: {"country_code": countryCode, "phone": phone}).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['verify_token']);
      }
    });
  }

  static updatePaymentDetails(
      {required String paypalId, required Function() resultCallback}) {
    var url = NetworkConstantsUtil.updatePaymentDetail;
    var params = {"paypal_id": paypalId};

    ApiWrapper().postApi(url: url, param: params).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateCountryCity(
      {required String country,
      required String city,
      required Function() resultCallback}) {
    var url = NetworkConstantsUtil.updateUserProfile;

    ApiWrapper().postApi(
        url: url, param: {"country": country, "city": city}).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateUserLocation(
      {required LatLng location, required Function() resultCallback}) {
    var url = NetworkConstantsUtil.updateLocation;

    ApiWrapper().postApi(url: url, param: {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'location': ''
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static pauseUserLocation(
      {required LatLng location, required Function() resultCallback}) {
    var url = NetworkConstantsUtil.updateLocation;

    ApiWrapper().postApi(url: url, param: {
      'latitude': '',
      'longitude': '',
      'location': ''
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static changePassword(
      {required String oldPassword,
      required String newPassword,
      required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.updatePassword;

    ApiWrapper().postApi(url: url, param: {
      "old_password": oldPassword,
      "password": newPassword
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static postRelationInviteUnInvite(
      {required int relationShipId,
      required int userId,
      required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.postInviteUnInvite;

    ApiWrapper().postApi(url: url, param: {
      "relation_ship_id": relationShipId.toString(),
      "user_id": userId.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static acceptRejectInvitation(
      {required int invitationId,
      required int status,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.putAcceptRejectInvite;

    ApiWrapper().postApi(url: url, param: {
      "id": invitationId.toString(),
      "status": status.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static sendProfileVerificationRequest(
      {required String userMessage,
      required String documentType,
      required List<Map<String, String>> images,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.requestVerification;

    ApiWrapper().postApi(url: url, param: {
      "user_message": userMessage,
      'document': images,
      'document_type': documentType,
    }).then((result) {
      resultCallback();
    });
  }

  static cancelProfileVerificationRequest(
      {required int id,
      required String userMessage,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.cancelVerification;

    ApiWrapper().postApi(url: url, param: {
      'user_message': userMessage,
      'id': id.toString(),
    }).then((result) {
      resultCallback();
    });
  }

  static getVerificationRequestHistory(
      {required Function(List<VerificationRequest>) resultCallback}) async {
    var url = NetworkConstantsUtil.requestVerificationHistory;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['verification']['items'];

        resultCallback(List<VerificationRequest>.from(
            items.map((x) => VerificationRequest.fromJson(x))));
      }
    });
  }

  static uploadProfileImage(Uint8List imageData,
      {required VoidCallback resultCallback}) {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .multipartImageUpload(
            url: NetworkConstantsUtil.updateProfileImage,
            imageFileData: imageData)
        .then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static uploadProfileCoverImage(Uint8List imageData,
      {required VoidCallback resultCallback}) {
    EasyLoading.show(status: loadingString.tr);

    ApiWrapper()
        .multipartImageUpload(
            url: NetworkConstantsUtil.updateProfileCoverImage,
            imageFileData: imageData)
        .then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateAccountPrivacy(
      {required bool isPrivate, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.updateAccountPrivacy;

    await ApiWrapper().postApi(url: url, param: {
      'profile_visibility': isPrivate ? 2 : 1,
    }).then((result) {
      resultCallback();
    });
  }
}
