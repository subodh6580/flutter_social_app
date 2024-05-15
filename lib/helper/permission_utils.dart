import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dialog_utils.dart';


class PermissionUtils {
  static void requestPermission(
    List<Permission> permission,
     {
    required Function permissionGrant,
    required Function permissionDenied,
    required Function permissionNotAskAgain,
    bool isOpenSettings = false,
    bool isShowMessage = false,
  }) async {
    Map<Permission, PermissionStatus> statuses = await permission.request();

    var allPermissionGranted = true;

    statuses.forEach((key, value) {
      allPermissionGranted =
          allPermissionGranted && (value == PermissionStatus.granted);
    });

    if (allPermissionGranted) {
      permissionGrant();
    } else {
      permissionDenied();
      if (isOpenSettings) {
        DialogUtils.showOkCancelAlertDialog(
          message: pleaseGrantRequiredPermissionString.tr,
          cancelButtonTitle: Platform.isAndroid
              ? noString.tr
              : cancelString.tr,
          okButtonTitle: Platform.isAndroid
              ? yesString.tr
              : okString.tr,
          cancelButtonAction: () {},
          okButtonAction: () {
            openAppSettings();
          },
        );
      } else if (isShowMessage) {
        DialogUtils.showAlertDialog(
             pleaseGrantRequiredPermissionString.tr);
      }
    }
  }
}
