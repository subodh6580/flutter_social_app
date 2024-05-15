import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:foap/helper/imports/common_import.dart';

class DialogUtils {
  static void showOkCancelAlertDialog({
    required String message,
    required String okButtonTitle,
    required String cancelButtonTitle,
    required Function cancelButtonAction,
    required Function okButtonAction,
    bool? isCancelEnable = true,
  }) {
    showDialog(
      barrierDismissible: isCancelEnable == true,
      builder: (context) {
        if (Platform.isIOS) {
          return WillPopScope(
            onWillPop: () async => false,
            child: _showOkCancelCupertinoAlertDialog(
                context,
                message,
                okButtonTitle,
                cancelButtonTitle,
                okButtonAction,
                isCancelEnable == true,
                cancelButtonAction),
          );
        } else {
          return WillPopScope(
            onWillPop: () async => false,
            child: _showOkCancelMaterialAlertDialog(
                context,
                message,
                okButtonTitle,
                cancelButtonTitle,
                okButtonAction,
                isCancelEnable == true,
                cancelButtonAction),
          );
        }
      }, context: Get.context!,
    );
  }

  static void showAlertDialog( String message) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        if (Platform.isIOS) {
          return WillPopScope(
              onWillPop: () async => false,
              child: _showCupertinoAlertDialog(context, message));
        } else {
          return WillPopScope(
              onWillPop: () async => false,
              child: _showMaterialAlertDialog(context, message));
        }
      },
    );
  }

  static CupertinoAlertDialog _showCupertinoAlertDialog(
      BuildContext context, String message) {
    return CupertinoAlertDialog(
      title: Text(AppConfigConstants.appName),
      content: Text(message),
      actions: _actions(context),
    );
  }

  static AlertDialog _showMaterialAlertDialog(
      BuildContext context, String message) {
    return AlertDialog(
      title: Text(AppConfigConstants.appName),
      content: Text(message),
      actions: _actions(context),
    );
  }

  static AlertDialog _showOkCancelMaterialAlertDialog(
      BuildContext context,
      String message,
      String okButtonTitle,
      String cancelButtonTitle,
      Function okButtonAction,
      bool isCancelEnable,
      Function cancelButtonAction) {
    return AlertDialog(
      title: Text(AppConfigConstants.appName),
      content: Text(message),
      actions: _okCancelActions(
        okButtonTitle: okButtonTitle,
        cancelButtonTitle: cancelButtonTitle,
        okButtonAction: okButtonAction,
        isCancelEnable: isCancelEnable,
        cancelButtonAction: cancelButtonAction,
      ),
    );
  }

  static CupertinoAlertDialog _showOkCancelCupertinoAlertDialog(
      BuildContext context,
      String message,
      String okButtonTitle,
      String cancelButtonTitle,
      Function okButtonAction,
      bool isCancelEnable,
      Function cancelButtonAction,
      {String? title}) {
    return CupertinoAlertDialog(
        title: Text(title ?? AppConfigConstants.appName),
        content: Text(message),
        actions: isCancelEnable
            ? _okCancelActions(
                okButtonTitle: okButtonTitle,
                cancelButtonTitle: cancelButtonTitle,
                okButtonAction: okButtonAction,
                isCancelEnable: isCancelEnable,
                cancelButtonAction: cancelButtonAction,
              )
            : _okAction(
                okButtonAction: okButtonAction, okButtonTitle: okButtonTitle));
  }

  static List<Widget> _actions(BuildContext context) {
    return <Widget>[
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(okString.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : Text(okString.tr).ripple(() {
              Navigator.of(context).pop();
            }),
    ];
  }

  static List<Widget> _okCancelActions({
    required String okButtonTitle,
    required String cancelButtonTitle,
    required Function okButtonAction,
    required bool isCancelEnable,
    required Function cancelButtonAction,
  }) {
    return <Widget>[
      Platform.isIOS
          ? CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(cancelButtonTitle),
              onPressed: () {
                Get.back();
              })
          : Text(cancelButtonTitle).ripple(() {
              Get.back();
            }),
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(okButtonTitle),
              onPressed: () {
                Get.back();
                okButtonAction();
              },
            )
          : Text(okButtonTitle).ripple(() {
              Get.back();
              okButtonAction();
            }),
    ];
  }

  static List<Widget> _okAction(
      {required String okButtonTitle, required Function okButtonAction}) {
    return <Widget>[
      Platform.isIOS
          ? CupertinoDialogAction(
              child: Text(okButtonTitle),
              onPressed: () {
                Get.back();
                okButtonAction();
              },
            )
          : Text(okButtonTitle).ripple(() {
              Get.back();
              okButtonAction();
            }),
    ];
  }
}
