import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/blocked_users.dart';
import '../live/live_history.dart';
import 'package:foap/helper/imports/setting_imports.dart';

class AppAccount extends StatefulWidget {
  const AppAccount({Key? key}) : super(key: key);

  @override
  State<AppAccount> createState() => _AppAccountState();
}

class _AppAccountState extends State<AppAccount> {
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: accountString.tr),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Column(
                  children: [
                    addTileEvent('assets/live_bw.png', liveHistoryString.tr,
                        liveHistorySubHeadlineString.tr, () {
                      Get.to(() => const LiveHistory());
                    }),
                    addTileEvent('assets/blocked_user.png',
                        blockedUserString.tr, manageBlockedUserString.tr, () {
                      Get.to(() => const BlockedUsersList());
                    }),
                    if (_settingsController
                        .setting.value!.enableProfileVerification)
                      addTileEvent('assets/verification.png',
                          requestVerificationString.tr, '', () {
                        Get.to(() => const RequestVerification());
                      }),
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
    );
  }

  addTileEvent(
      String icon, String title, String subTitle, VoidCallback action) {
    return InkWell(
        onTap: action,
        child: Column(
          children: [
            SizedBox(
              height: 75,
              child: Row(children: [
                Container(
                        color: AppColorConstants.themeColor.withOpacity(0.2),
                        child: Image.asset(
                          icon,
                          height: 20,
                          width: 20,
                          color: AppColorConstants.themeColor,
                        ).p8)
                    .circular,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyLargeText(title.tr, weight: TextWeight.medium)
                    ],
                  ),
                ),
                // const Spacer(),
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
}
