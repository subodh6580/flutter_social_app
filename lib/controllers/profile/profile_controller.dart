import 'package:camera/camera.dart';
import 'package:foap/apiHandler/apis/gift_api.dart';
import 'package:foap/apiHandler/apis/profile_api.dart';
import 'package:foap/apiHandler/apis/wallet_api.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import '../../apiHandler/apis/auth_api.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../apiHandler/apis/users_api.dart';
import '../../util/shared_prefs.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/manager/location_manager.dart';
import 'package:foap/util/form_validator.dart';
import 'package:foap/controllers/auth/login_controller.dart';
import 'package:foap/controllers/post/post_controller.dart';
import 'package:foap/model/payment_model.dart';
import 'package:foap/model/gift_model.dart';
import 'package:foap/model/post_model.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/profile/verify_otp_for_phone_number.dart';
import 'package:foap/screens/login_sign_up/login_screen.dart';
import 'package:foap/screens/login_sign_up/set_profile_category_type.dart';

class ProfileController extends GetxController {
  final PostController postController = Get.find<PostController>();
  final UserProfileManager _userProfileManager = Get.find();

  Rx<UserModel?> user = Rx<UserModel?>(null);

  int totalPages = 100;

  RxInt userNameCheckStatus = (-1).obs;
  RxBool isLoading = true.obs;

  RxList<PaymentModel> payments = <PaymentModel>[].obs;
  RxInt selectedSegment = 0.obs;

  RxBool noDataFound = false.obs;

  bool isLoadingPosts = false;
  int postsCurrentPage = 1;
  bool canLoadMorePosts = true;

  bool isLoadingReels = false;
  int reelsCurrentPage = 1;
  bool canLoadMoreReels = true;

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> mentions = <PostModel>[].obs;
  RxList<PostModel> reels = <PostModel>[].obs;

  int mentionsPostPage = 1;
  bool canLoadMoreMentionsPosts = true;
  bool mentionsPostsIsLoading = false;

  Rx<GiftModel?> sendingGift = Rx<GiftModel?>(null);

  clear() {
    selectedSegment.value = 0;

    isLoadingPosts = false;
    postsCurrentPage = 1;
    canLoadMorePosts = true;

    isLoadingReels = false;
    reelsCurrentPage = 1;
    canLoadMoreReels = true;

    mentionsPostPage = 1;
    canLoadMoreMentionsPosts = true;
    mentionsPostsIsLoading = false;

    totalPages = 100;

    posts.clear();
    mentions.clear();
    reels.clear();
  }

  getMyProfile() async {
    // user.value = _userProfileManager.user.value!;
    // update();
    await _userProfileManager.refreshProfile();
    user.value = _userProfileManager.user.value!;
    update();
  }

  setUser(UserModel userObj) {
    user.value = userObj;
    update();
  }

  segmentChanged(int index) {
    selectedSegment.value = index;
    postController.update();
    update();
  }

  void updateLocation({
    required String country,
    required String city,
  }) {
    if (FormValidator().isTextEmpty(country)) {
      AppUtil.showToast(message: pleaseEnterCountryString.tr, isSuccess: false);
    } else if (FormValidator().isTextEmpty(city)) {
      AppUtil.showToast(message: pleaseEnterCityString.tr, isSuccess: false);
    } else {
      EasyLoading.show(status: loadingString.tr);

      ProfileApi.updateCountryCity(
          country: country,
          city: city,
          resultCallback: () {
            EasyLoading.dismiss();
            AppUtil.showToast(
                message: profileUpdatedString.tr, isSuccess: true);
            _userProfileManager.refreshProfile();

            user.value!.country = country;
            user.value!.city = city;
            update();
            Future.delayed(const Duration(milliseconds: 1200), () {
              Get.back();
            });
          });
    }
  }

  void resetPassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (FormValidator().isTextEmpty(oldPassword)) {
      AppUtil.showToast(message: enterOldPasswordString.tr, isSuccess: false);
    } else if (FormValidator().isTextEmpty(newPassword)) {
      AppUtil.showToast(message: enterNewPasswordString.tr, isSuccess: false);
    } else if (FormValidator().isTextEmpty(confirmPassword)) {
      AppUtil.showToast(
          message: enterConfirmPasswordString.tr, isSuccess: false);
    } else if (newPassword != confirmPassword) {
      AppUtil.showToast(
          message: passwordsDoesNotMatchedString.tr, isSuccess: false);
    } else {
      EasyLoading.show(status: loadingString.tr);

      ProfileApi.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
          resultCallback: () {
            EasyLoading.dismiss();
            _userProfileManager.refreshProfile();
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.to(() => const LoginScreen());
            });
          });
    }
  }

  updatePaypalId({required String paypalId}) {
    if (FormValidator().isTextEmpty(paypalId)) {
      AppUtil.showToast(
          message: pleaseEnterPaypalIdString.tr, isSuccess: false);
    } else {
      ProfileApi.updatePaymentDetails(
          paypalId: paypalId,
          resultCallback: () {
            AppUtil.showToast(
                message: paymentDetailUpdatedString.tr, isSuccess: true);
            _userProfileManager.refreshProfile();

            Future.delayed(const Duration(milliseconds: 1200), () {
              Get.back();
            });
          });
    }
  }

  void updateMobile({
    required String countryCode,
    required String phoneNumber,
  }) {
    if (FormValidator().isTextEmpty(phoneNumber)) {
      AppUtil.showToast(message: enterPhoneNumberString.tr, isSuccess: false);
    } else {
      EasyLoading.show(status: loadingString.tr);

      ProfileApi.updatePhone(
          countryCode: countryCode,
          phone: phoneNumber,
          resultCallback: (token) {
            EasyLoading.dismiss();
            _userProfileManager.refreshProfile();
            Get.to(() => VerifyOTPPhoneNumberChange(
                  token: token,
                ));
          });
    }
  }

  updateUserName({
    required String userName,
    required isSigningUp,
  }) {
    if (FormValidator().isTextEmpty(userName)) {
      AppUtil.showToast(
          message: pleaseEnterUserNameString.tr, isSuccess: false);
    } else if (userNameCheckStatus.value != 1) {
      AppUtil.showToast(
          message: pleaseEnterValidUserNameString.tr, isSuccess: false);
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          EasyLoading.show(status: loadingString.tr);
          ProfileApi.updateUserName(
              userName: userName,
              resultCallback: () {
                EasyLoading.dismiss();
                AppUtil.showToast(
                    message: userNameIsUpdatedString.tr, isSuccess: true);
                getMyProfile();
                if (isSigningUp == true) {
                  Get.to(() => SetProfileCategoryType(
                        isFromSignup: isSigningUp,
                      ));
                } else {
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    Get.back();
                  });
                }
              });
        }
      });
    }
  }

  updateProfileCategoryType({
    required int profileCategoryType,
    required isSigningUp,
  }) {
    EasyLoading.show(status: loadingString.tr);

    ProfileApi.updateProfileCategoryType(
        categoryType: profileCategoryType,
        resultCallback: () {
          EasyLoading.dismiss();
          AppUtil.showToast(
              message: categoryTypeUpdatedString.tr, isSuccess: true);
          getMyProfile();
          if (isSigningUp == true) {
            isLoginFirstTime = false;
            getIt<LocationManager>().postLocation();
            Get.offAll(() => const DashboardScreen());
          } else {
            Future.delayed(const Duration(milliseconds: 1200), () {
              Get.back();
            });
          }
        });
  }

  void verifyUsername({required String userName}) {
    AuthApi.checkUsername(
        username: userName,
        successCallback: () {
          userNameCheckStatus.value = 1;
          update();
        },
        failureCallback: () {
          userNameCheckStatus.value = 0;
          update();
        });
  }

  void editProfileImageAction(XFile pickedFile, bool isCoverImage) async {
    if (isCoverImage) {
      Uint8List compressedData = await File(pickedFile.path)
          .compress(minHeight: 800, minWidth: 800, byQuality: 50);

      ProfileApi.uploadProfileCoverImage(compressedData, resultCallback: () {
        _userProfileManager.refreshProfile().then((value) {
          user.value = _userProfileManager.user.value;
          update();
        });
      });
    } else {
      Uint8List compressedData = await File(pickedFile.path)
          .compress(minHeight: 1000, minWidth: 1000, byQuality: 50);

      ProfileApi.uploadProfileImage(compressedData, resultCallback: () {
        _userProfileManager.refreshProfile().then((value) {
          user.value = _userProfileManager.user.value;
          update();
        });
      });
    }
  }

  updateBioMetricSetting(bool value, BuildContext context) {
    user.value!.isBioMetricLoginEnabled = value == true ? 1 : 0;
    SharedPrefs().setBioMetricAuthStatus(value);
    EasyLoading.show(status: loadingString.tr);

    ProfileApi.updateBiometricSetting(
        setting: user.value!.isBioMetricLoginEnabled ?? 0,
        resultCallback: () {
          _userProfileManager.refreshProfile();
          EasyLoading.dismiss();
          AppUtil.showToast(message: profileUpdatedString.tr, isSuccess: true);
        });
  }

  //////////////********** other user profile **************/////////////////

  void getOtherUserDetail({required int userId}) {
    UsersApi.getOtherUser(
        userId: userId,
        resultCallback: (result) {
          user.value = result;
          update();
        });
  }

  void followUnFollowUser({required UserModel user}) {
    if (user.isPrivate &&
        user.followingStatus == FollowingStatus.notFollowing) {
      this.user.value!.followingStatus = FollowingStatus.requested;
    } else if (user.followingStatus == FollowingStatus.notFollowing) {
      this.user.value!.followingStatus = FollowingStatus.following;
    } else {
      this.user.value!.followingStatus = FollowingStatus.notFollowing;
    }

    update();

    UsersApi.followUnfollowUser(
        isFollowing:
        this.user.value!.followingStatus == FollowingStatus.notFollowing
            ? false
            : true,
        userId: user.id)
        .then((value) {
      update();
    });
  }

  void reportUser(BuildContext context) {
    user.value!.isReported = true;
    update();

    UsersApi.reportUser(userId: user.value!.id, resultCallback: () {});
  }

  void blockUser(BuildContext context) {
    user.value!.isReported = true;
    update();

    UsersApi.blockUser(userId: user.value!.id, resultCallback: () {});
  }

//////////////********** other user profile **************/////////////////

  void withdrawalRequest() async {
    await WalletApi.performWithdrawalRequest();
    getMyProfile();
  }

  void redeemRequest(int coins, VoidCallback callback) async {
    await WalletApi.redeemCoinsRequest(coins: coins);
    await getMyProfile();
    callback();
  }

  void getWithdrawHistory() {
    WalletApi.getWithdrawHistory(resultCallback: (result) {
      payments.value = result;
      update();
    });
  }

  followUser(UserModel user) {
    user.followingStatus = FollowingStatus.following;
    update();
    UsersApi.followUnfollowUser(isFollowing: true, userId: user.id)
        .then((value) {
      update();
    });
  }

  unFollowUser(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;

    update();
    UsersApi.followUnfollowUser(isFollowing: false, userId: user.id)
        .then((value) {
      update();
    });
  }

  //******************** Posts ****************//

  // void getPosts(int userId) async {
  //   if (canLoadMorePosts == true && totalPages > postsCurrentPage) {
  //     isLoadingPosts = true;
  //
  //     PostApi.getPosts(
  //         userId: userId,
  //         page: postsCurrentPage,
  //         resultCallback: (result, metadata) {
  //           posts.addAll(
  //               result.where((element) => element.gallery.isNotEmpty).toList());
  //           posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
  //           posts.unique((e) => e.id);
  //
  //           isLoadingPosts = false;
  //
  //           if (postsCurrentPage >= metadata.pageCount) {
  //             canLoadMorePosts = false;
  //           } else {
  //             canLoadMorePosts = true;
  //           }
  //           postsCurrentPage += 1;
  //           totalPages = metadata.pageCount;
  //
  //           update();
  //         });
  //   }
  // }

  void getReels(int userId) async {
    if (canLoadMoreReels == true) {
      isLoadingReels = true;
      PostApi.getPosts(
          userId: userId,
          page: reelsCurrentPage,
          resultCallback: (result, metadata) {
            posts.addAll(
                result.where((element) => element.gallery.isNotEmpty).toList());
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e) => e.id);

            isLoadingReels = false;

            if (postsCurrentPage >= metadata.pageCount) {
              canLoadMoreReels = false;
            } else {
              canLoadMoreReels = true;
            }
            reelsCurrentPage += 1;
            // totalPages = metadata.pageCount;

            update();
          });
    }
  }

  void getMentionPosts(int userId) {
    if (canLoadMoreMentionsPosts && totalPages > mentionsPostPage) {
      mentionsPostsIsLoading = true;

      PostApi.getMentionedPosts(
          userId: userId,
          resultCallback: (result, metaData) {
            mentionsPostsIsLoading = false;

            mentions.addAll(result.reversed.toList());
            mentions.unique((e) => e.id);

            mentionsPostPage += 1;
            if (result.length == metaData.perPage) {
              canLoadMoreMentionsPosts = true;
              totalPages = metaData.pageCount;
            } else {
              canLoadMoreMentionsPosts = false;
            }
            update();
          });
    }
  }

  sendGift(GiftModel gift) {
    if (_userProfileManager.user.value!.coins > gift.coins) {
      sendingGift.value = gift;
      GiftApi.sendStickerGift(
          gift: gift,
          liveId: null,
          postId: null,
          receiverId: user.value!.id,
          resultCallback: () {
            Timer(const Duration(seconds: 1), () {
              sendingGift.value = null;
            });

            // refresh profile to get updated wallet info
            _userProfileManager.refreshProfile();
          });
    } else {}
  }

  otherUserProfileView({required int refId, required int sourceType}) {
    UsersApi.otherUserProfileView(refId: refId, sourceType: sourceType);
  }
}
