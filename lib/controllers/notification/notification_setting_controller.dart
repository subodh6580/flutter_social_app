import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/misc_api.dart';

class NotificationSettingController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxInt likesNotificationStatus = 0.obs;
  RxInt commentNotificationStatus = 0.obs;
  RxInt turnOfAll = 0.obs;

  RxBool isLoading = true.obs;

  initialize() {
    likesNotificationStatus.value =
        _userProfileManager.user.value!.likePushNotificationStatus;
    commentNotificationStatus.value =
        _userProfileManager.user.value!.commentPushNotificationStatus;
    update();
  }

  updateNotificationSetting(
      {required String section,
      required String title,
      }) {
    if (section == likesString.tr) {
      if (title == offString.tr) {
        likesNotificationStatus.value = 0;
      } else if (title == fromPeopleOrFollowString.tr) {
        likesNotificationStatus.value = 2;
        turnOfAll.value = 0;
      } else {
        likesNotificationStatus.value = 1;
        turnOfAll.value = 0;
      }
    } else {
      if (title == offString.tr) {
        commentNotificationStatus.value = 0;
      } else if (title == fromPeopleOrFollowString.tr) {
        commentNotificationStatus.value = 2;
        turnOfAll.value = 0;
      } else {
        commentNotificationStatus.value = 1;
        turnOfAll.value = 0;
      }
    }

    update();

    MiscApi.updateNotificationSettings(
        likesNotificationStatus: likesNotificationStatus.toString(),
        commentNotificationStatus: commentNotificationStatus.toString(),
        resultCallback: () {
          _userProfileManager.refreshProfile();
        });
  }
}
