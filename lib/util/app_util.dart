import 'package:connectivity/connectivity.dart';
import 'package:foap/helper/imports/common_import.dart';

import '../components/timer_view.dart';

class AppUtil {
  static showToast({required String message, required bool isSuccess}) {
    Get.snackbar(isSuccess == true ? successString.tr : errorString.tr, message,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: isSuccess == true
            ? AppColorConstants.themeColor.darken()
            : AppColorConstants.red.lighten(),
        icon: Icon(Icons.error, color: AppColorConstants.iconColor));
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Widget addProgressIndicator({double? size}) {
    return Center(
        child: SizedBox(
      width: size ?? 50,
      height: size ?? 50,
      child: CircularProgressIndicator(
          strokeWidth: 2.0,
          backgroundColor: Colors.black12,
          valueColor:
              AlwaysStoppedAnimation<Color>(AppColorConstants.themeColor)),
    ));
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  static void showConfirmationAlert(
      {required String title,
      required String subTitle,
      required VoidCallback okHandler}) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 200,
            width: Get.width,
            color: AppColorConstants.backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading3Text(
                  title,
                  color: AppColorConstants.themeColor,
                  weight: TextWeight.bold,
                ),
                const SizedBox(
                  height: 10,
                ),
                Heading6Text(
                  subTitle,
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: AppThemeBorderButton(
                              text: yesString.tr,
                              onPress: () {
                                Get.back(closeOverlays: true);
                                okHandler();
                              }),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: AppThemeButton(
                              text: noString.tr,
                              onPress: () {
                                Get.back(closeOverlays: true);
                              }),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ).hp(DesignConstants.horizontalPadding),
          ).round(20),
        );
      },
    );
  }

  static void showNewConfirmationAlert(
      {required String title,
      required String subTitle,
      required VoidCallback okHandler,
      required VoidCallback cancelHandler}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      builder: (context) => Container(
        height: 220,
        width: Get.width,
        color: AppColorConstants.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Heading3Text(
              title,
              color: AppColorConstants.themeColor,
              weight: TextWeight.bold,
            ),
            const SizedBox(
              height: 10,
            ),
            BodyLargeText(
              subTitle,
              weight: TextWeight.regular,
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Wrap(
                  spacing: 20,
                  children: [
                    BodyLargeText(
                      okString,
                      color: AppColorConstants.subHeadingTextColor,
                    )
                        .makeChip(
                            backGroundColor: AppColorConstants.mainTextColor)
                        .ripple(() {
                      Get.back(closeOverlays: true);
                      okHandler();
                    }),
                    BodyLargeText(
                      cancelString,
                      color: Colors.white,
                    )
                        .makeChip(backGroundColor: AppColorConstants.red)
                        .ripple(() {
                      cancelHandler();
                      Get.back(closeOverlays: true);
                    }),
                  ],
                ),
              ],
            )
          ],
        ).hp(DesignConstants.horizontalPadding),
      ).round(20),
    );
  }

  static void showNewConfirmationAlertWithTimer(
      {required String title,
      required String subTitle,
      required int time,
      required VoidCallback okHandler,
      required VoidCallback cancelHandler}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      builder: (context) => Container(
        height: 220,
        width: Get.width,
        color: AppColorConstants.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 30,
                width: 120,
                color: AppColorConstants.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ThemeIconWidget(
                      ThemeIcon.clock,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Center(
                        child: UnlockTimerView(
                      unlockTime: time,
                      completionHandler: () {
                        Get.back(closeOverlays: true);
                        // cancelHandler();
                      },
                    )),
                  ],
                ).hP4,
              ).bottomRounded(10),
            ),
            const SizedBox(
              height: 20,
            ),
            Heading3Text(
              title,
              color: AppColorConstants.themeColor,
              weight: TextWeight.bold,
            ),
            const SizedBox(
              height: 10,
            ),
            BodyLargeText(
              subTitle,
              weight: TextWeight.regular,
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Wrap(
                  spacing: 20,
                  children: [
                    BodyLargeText(
                      acceptString,
                      color: AppColorConstants.subHeadingTextColor,
                    )
                        .makeChip(
                            backGroundColor: AppColorConstants.mainTextColor)
                        .ripple(() {
                      Get.back(closeOverlays: true);
                      okHandler();
                    }),
                    BodyLargeText(
                      declineString,
                      color: Colors.white,
                    )
                        .makeChip(backGroundColor: AppColorConstants.red)
                        .ripple(() {
                      cancelHandler();
                      Get.back(closeOverlays: true);
                    }),
                  ],
                ),
              ],
            )
          ],
        ).hp(DesignConstants.horizontalPadding),
      ).round(20),
    );
  }

  static void showDemoAppConfirmationAlert(
      {required String title,
      required String subTitle,
      required VoidCallback okHandler}) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 200,
            width: Get.width,
            color: AppColorConstants.backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading3Text(
                  title,
                  color: AppColorConstants.themeColor,
                  weight: TextWeight.bold,
                ),
                const SizedBox(
                  height: 10,
                ),
                BodyLargeText(
                  subTitle,
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          height: 30,
                          child: AppThemeBorderButton(
                              text: okString.tr,
                              onPress: () {
                                Get.back(closeOverlays: true);
                                okHandler();
                              }),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ).p16,
          ).round(20),
        );
      },
    );
  }
}
