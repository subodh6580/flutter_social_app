import 'package:foap/helper/imports/common_import.dart';

import 'package:foap/helper/imports/setting_imports.dart';

class PaymentAndCoins extends StatefulWidget {
  const PaymentAndCoins({Key? key}) : super(key: key);

  @override
  State<PaymentAndCoins> createState() => _PaymentAndCoinsState();
}

class _PaymentAndCoinsState extends State<PaymentAndCoins> {
  final SettingsController settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  int coin = 0;

  @override
  void initState() {
    super.initState();
    coin = _userProfileManager.user.value!.coins ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
               title: paymentAndCoinsString.tr),
          const SizedBox(height: 8,),
          Expanded(
            child: ListView(
              padding:  EdgeInsets.zero,
              children: [
                Column(
                  children: [
                    addTileEvent(
                        'assets/coins.png',
                        '${coinsString.tr} ($coin)',
                        checkYourCoinsAndEarnMoreCoinsString.tr, () {
                      Get.to(() => const PackagesScreen());
                    }),
                    addTileEvent(
                        'assets/earning.png',
                        earningsString.tr,
                        trackEarningString.tr, () {
                      Get.to(() => const PaymentWithdrawalScreen());
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
                      BodyLargeText(title,
                          weight: TextWeight.medium)

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
