import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/notification/notification_setting_controller.dart';

class AppNotificationSettings extends StatefulWidget {
  const AppNotificationSettings({Key? key}) : super(key: key);

  @override
  State<AppNotificationSettings> createState() =>
      _AppNotificationSettingsState();
}

class _AppNotificationSettingsState extends State<AppNotificationSettings> {
  final NotificationSettingController settingController =
      NotificationSettingController();

  @override
  void initState() {
    super.initState();
    settingController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            backNavigationBar(title: notificationSettingsString.tr),
            const SizedBox(
              height: 20,
            ),
            GetBuilder<NotificationSettingController>(
                init: settingController,
                builder: (ctx) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BodyLargeText(turnOffAllString.tr,
                              weight: TextWeight.bold),
                          settingController.turnOfAll.value == 1
                              ? ThemeIconWidget(
                                  ThemeIcon.selectedRadio,
                                  color: AppColorConstants.themeColor,
                                ).ripple(() {
                                  settingController.turnOfAll.value = 0;
                                })
                              : ThemeIconWidget(ThemeIcon.circleOutline,
                                      color: AppColorConstants.iconColor)
                                  .ripple(() {
                                  settingController.turnOfAll.value = 1;
                                  settingController
                                      .likesNotificationStatus.value = 0;
                                  settingController
                                      .commentNotificationStatus.value = 0;
                                })
                        ],
                      ).setPadding(left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, bottom: 16),
                      settingSegment(likesString.tr).vP8,
                      settingSegment(commentsString.tr).vP8,
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }

  Widget settingSegment(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyLargeText(title, weight: TextWeight.bold),
        const SizedBox(
          height: 10,
        ),
        settingOption(
            title,
            offString.tr,
            title == likesString.tr
                ? settingController.likesNotificationStatus.value == 0
                : settingController.commentNotificationStatus.value == 0),
        settingOption(
            title,
            fromPeopleOrFollowString.tr,
            title == likesString.tr
                ? settingController.likesNotificationStatus.value == 2
                : settingController.commentNotificationStatus.value == 2),
        settingOption(
            title,
            fromEveryoneString.tr,
            title == likesString.tr
                ? settingController.likesNotificationStatus.value == 1
                : settingController.commentNotificationStatus.value == 1),
      ],
    ).hp(DesignConstants.horizontalPadding);
  }

  Widget settingOption(String sectionName, String title, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BodyLargeText(
          title,
        ),
        isSelected == true
            ? ThemeIconWidget(
                ThemeIcon.selectedRadio,
                color: AppColorConstants.themeColor,
              )
            : ThemeIconWidget(ThemeIcon.circleOutline,
                color: AppColorConstants.iconColor)
      ],
    ).vP8.ripple(() {
      settingController.updateNotificationSetting(
          section: sectionName, title: title);
    });
  }
}
