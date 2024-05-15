import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../components/package_tile.dart';
import '../../controllers/misc/subscription_packages_controller.dart';
import '../../model/package_model.dart';
import '../../util/constant_util.dart';

class CoinPackagesWidget extends StatefulWidget {
  const CoinPackagesWidget({Key? key}) : super(key: key);

  @override
  State<CoinPackagesWidget> createState() => _CoinPackagesWidgetState();
}

class _CoinPackagesWidgetState extends State<CoinPackagesWidget> {
  final SubscriptionPackageController packageController = Get.find();
  // final MercadappagoPaymentController _paymentController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor,
      child: GetBuilder<SubscriptionPackageController>(
          init: packageController,
          builder: (ctx) {
            return ListView.separated(
                padding: const EdgeInsets.only(top: 20, bottom: 70),
                itemBuilder: (ctx, index) {
                  return PackageTile(
                    package: packageController.packages[index],
                    index: index,
                    buyPackageHandler: () {
                      // _paymentController.makePayment();
                      buyPackage(packageController.packages[index]);
                    },
                  );
                },
                separatorBuilder: (ctx, index) {
                  return divider().vP16;
                },
                itemCount: packageController.packages.length);
          }).hp(DesignConstants.horizontalPadding),
    );
  }

  buyPackage(PackageModel package) {
    if (AppConfigConstants.isDemoApp) {
      AppUtil.showDemoAppConfirmationAlert(
          title: 'Demo app',
          subTitle:
              'This is demo app so you can not make payment to test it, but still you will get some coins',
          okHandler: () {
            packageController.subscribeToDummyPackage(randomId());
          });
      return;
    }
    if (packageController.isAvailable.value) {
      // packageController.selectedPackage.value = index;
      // For Real Time
      packageController.selectedPurchaseId.value = Platform.isIOS
          ? package.inAppPurchaseIdIOS
          : package.inAppPurchaseIdAndroid;
      List<ProductDetails> matchedProductArr = packageController.products
          .where((element) =>
              element.id == packageController.selectedPurchaseId.value)
          .toList();
      if (matchedProductArr.isNotEmpty) {
        ProductDetails matchedProduct = matchedProductArr.first;
        PurchaseParam purchaseParam = PurchaseParam(
            productDetails: matchedProduct, applicationUserName: null);
        packageController.inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam,
            autoConsume: packageController.kAutoConsume || Platform.isIOS);
      } else {
        AppUtil.showToast(
            message: noProductAvailableString.tr, isSuccess: false);
      }
    } else {
      AppUtil.showToast(
          message: storeIsNotAvailableString.tr, isSuccess: false);
    }
  }
}
