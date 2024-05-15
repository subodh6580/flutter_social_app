import 'package:foap/helper/imports/common_import.dart';
import '../settings_menu/packages_screen.dart';

class EarnCoinForContestPopup extends StatefulWidget {
  final int needCoins;

  const EarnCoinForContestPopup({Key? key, required this.needCoins})
      : super(key: key);

  @override
  State<EarnCoinForContestPopup> createState() =>
      _EarnCoinForContestPopupState();
}

class _EarnCoinForContestPopupState extends State<EarnCoinForContestPopup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar( title: coinsString.tr),
          const Spacer(),
          Container(
                  height: 450,
                  color: AppColorConstants.backgroundColor,
                  child: Column(
                    children: [
                      Heading6Text(
                        youNeedString.tr,
                      ).bp(20),
                      Heading4Text(
                        '${widget.needCoins} ${coinsString.tr}',
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ).bp(15),
                      Heading6Text(
                        toJoinThisCompetitionString.tr,
                      ).bp(120),
                      Heading5Text(
                        watchAdsToEarnCoinsString.tr,
                        color: AppColorConstants.themeColor,
                      ).ripple(() {}).bp(20),
                      AppThemeButton(
                        text: buyCoinsString.tr,
                        onPress: () {
                          Get.back();
                          Get.to(() => const PackagesScreen());
                        },
                      ).hp(DesignConstants.horizontalPadding)
                    ],
                  ).setPadding(top: 70, bottom: 45))
              .round(20)
              .hP25,
          const Spacer(),
        ],
      ),
    );
  }
}
