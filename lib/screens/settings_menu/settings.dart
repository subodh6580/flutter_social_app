import 'package:flutter_switch/flutter_switch.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:share_plus/share_plus.dart';
import '../post/saved_posts.dart';
import 'help_screen.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    _settingsController.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            children: [
              if (_settingsController.appearanceChanged!.value) Container(),
              backNavigationBar(title: settingsString.tr),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Column(
                      children: [
                        addTileEvent(
                            ThemeIcon.notification, notificationsString.tr, '',
                            () {
                          Get.to(() => const NotificationsScreen());
                        }, true),
                        addTileEvent(
                            ThemeIcon.language, changeLanguageString.tr, '',
                            () {
                          Get.to(() => const ChangeLanguage());
                        }, true),
                        addTileEvent(
                            ThemeIcon.wallet, paymentAndCoinsString.tr, '', () {
                          Get.to(() => const PaymentAndCoins());
                        }, true),
                        addTileEvent(ThemeIcon.account, accountString.tr, '',
                            () {
                          Get.to(() => const AppAccount());
                        }, true),
                        addTileEvent(
                            ThemeIcon.bookMark, savedPostsString.tr, '', () {
                          Get.to(() => const SavedPosts());
                        }, true),
                        addTileEvent(
                            ThemeIcon.privacyPolicy, privacyString.tr, '', () {
                          Get.to(() => const PrivacyOptions());
                        }, true),
                        addTileEvent(
                            ThemeIcon.setting,
                            notificationSettingsString.tr,
                            tuneSettingsString.tr, () {
                          Get.to(() => const AppNotificationSettings());
                        }, true),
                        addTileEvent(
                            ThemeIcon.info, faqString.tr, faqMessageString.tr,
                            () {
                          Get.to(() => const FaqList());
                        }, true),
                        addTileEvent(ThemeIcon.request, helpString.tr,
                            faqMessageString.tr, () {
                          Get.to(() => const HelpScreen());
                        }, true),
                        if (_settingsController
                            .setting.value!.enableDarkLightModeSwitch)
                          darkModeTile(),
                        addTileEvent(ThemeIcon.share, shareString.tr,
                            shareAppSubtitleString.tr, () {
                          Share.share(
                              '${installThisCoolAppString.tr} ${AppConfigConstants.liveAppLink}');
                        }, false),
                        addTileEvent(
                            ThemeIcon.logout, logoutString.tr, exitAppString.tr,
                            () {
                          AppUtil.showConfirmationAlert(
                              title: logoutString.tr,
                              subTitle: logoutConfirmationString.tr,
                              okHandler: () {
                                _userProfileManager.logout();
                              });
                        }, false),
                        addTileEvent(ThemeIcon.delete, deleteAccountString.tr,
                            deleteAccountSubheadingString.tr, () {
                          AppUtil.showConfirmationAlert(
                              title: deleteAccountString.tr,
                              subTitle: areYouSureToDeleteAccountString.tr,
                              okHandler: () {
                                _settingsController.deleteAccount();
                              });
                        }, false),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  addTileEvent(ThemeIcon icon, String title, String subTitle,
      VoidCallback action, bool showNextArrow) {
    return InkWell(
        onTap: action,
        child: Column(
          children: [
            SizedBox(
              height: 65,
              child: Row(children: [
                Container(
                        color: AppColorConstants.themeColor.withOpacity(0.2),
                        child: ThemeIconWidget(
                          icon,
                          color: AppColorConstants.iconColor,
                          size: 20,
                        ).p8)
                    .circular,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyLargeText(title.tr).bP4,
                    ],
                  ),
                ),
                // const Spacer(),
                if (showNextArrow)
                  ThemeIconWidget(
                    ThemeIcon.nextArrow,
                    color: AppColorConstants.iconColor,
                    size: 15,
                  )
              ]).hp(DesignConstants.horizontalPadding),
            ),
            divider()
          ],
        ));
  }

  darkModeTile() {
    return Column(
      children: [
        SizedBox(
          height: 65,
          child: Row(children: [
            Container(
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: Image.asset(
                      'assets/dark-mode.png',
                      height: 20,
                      width: 20,
                      color: AppColorConstants.iconColor,
                    ).p8)
                .circular,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [BodyLargeText(darkModeString.tr)],
              ),
            ),
            // const Spacer(),
            Obx(() => FlutterSwitch(
                  inactiveColor: AppColorConstants.disabledColor,
                  activeColor: AppColorConstants.themeColor,
                  width: 50.0,
                  height: 30.0,
                  valueFontSize: 15.0,
                  toggleSize: 20.0,
                  value: _settingsController.darkMode.value,
                  borderRadius: 30.0,
                  padding: 8.0,
                  // showOnOff: true,
                  onToggle: (val) {
                    _settingsController.appearanceModeChanged(val);
                  },
                )),
          ]).hp(DesignConstants.horizontalPadding),
        ),
        divider()
      ],
    );
  }
}
