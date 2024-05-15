import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import '../../controllers/misc/subscription_packages_controller.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({Key? key}) : super(key: key);

  @override
  PackagesScreenState createState() => PackagesScreenState();
}

class PackagesScreenState extends State<PackagesScreen> {
  final SubscriptionPackageController packageController = Get.find();
  final SettingsController settingsController = Get.find();

  @override
  void initState() {
    super.initState();

    settingsController.getSettings();
    packageController.initiate();
  }

  @override
  void dispose() {
    packageController.subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        backNavigationBar( title: packagesString.tr),
        const SizedBox(height: 8,),
        const Expanded(child: CoinPackagesWidget()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            BodyLargeText(watchAdsString.tr,
                weight: TextWeight.bold, color: AppColorConstants.themeColor),
            const SizedBox(height: 10),
            Obx(() => BodyMediumText(
                  settingsController.setting.value == null
                      ? watchAdsRewardString.tr
                          .replaceAll('coins_value', loadingString.tr)
                      : watchAdsRewardString.tr.replaceAll(
                          'coins_value',
                          settingsController
                              .setting.value!.watchVideoRewardCoins
                              .toString()),
                )),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 45,
                child: AppThemeButton(
                    text: watchAdsString.tr,
                    onPress: () {
                      packageController.showRewardedAds();
                    }),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ).hp(DesignConstants.horizontalPadding)
      ]),
    );
  }
}
