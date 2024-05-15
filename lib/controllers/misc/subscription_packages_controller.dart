import 'package:foap/apiHandler/apis/wallet_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/util/ad_helper.dart';
import 'package:foap/model/package_model.dart';

class SubscriptionPackageController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxList<PackageModel> packages = <PackageModel>[].obs;
  Rx<UserModel> user = UserModel().obs;

  RxInt coins = 0.obs;

  final bool kAutoConsume = true;
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  RxList<ProductDetails> products = <ProductDetails>[].obs;
  RxBool isAvailable = false.obs;
  RxString selectedPurchaseId = ''.obs;

  initiate() {
    WalletApi.getAllPackages(resultCallback: (result) {
      packages.value = result;
      initStoreInfo();
      update();
    });

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  Future<void> initStoreInfo() async {
    isAvailable.value = await InAppPurchase.instance.isAvailable();
    if (!isAvailable.value) {
      products.value = [];
      update();
      return;
    }

    List<String> kProductIds = packages
        .map((e) =>
            Platform.isIOS ? e.inAppPurchaseIdIOS : e.inAppPurchaseIdAndroid)
        .toList();
    ProductDetailsResponse productDetailResponse =
        await inAppPurchase.queryProductDetails(kProductIds.toSet());

    products.value = productDetailResponse.productDetails;
  }

  showRewardedAds() {
    RewardedInterstitialAds().show(() async {
      await WalletApi.rewardCoins();
      _userProfileManager.refreshProfile();
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //showPending error
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //show error
          AppUtil.showToast(message: purchaseErrorString.tr, isSuccess: false);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          //show success

          AppUtil.checkInternet().then((value) {
            if (value) {
              subscribeToPackage(
                  purchaseDetails.purchaseID!, purchaseDetails.productID);
              // ApiController()
              //     .subscribePackage(
              //         packages[selectedPackage.value].id.toString(),
              //         purchaseDetails.purchaseID!,
              //         packages[selectedPackage.value].price.toString())
              //     .then((response) {
              //   AppUtil.showToast(
              //
              //       message: coinsAdded,
              //       isSuccess: true);
              //   _userProfileManager.refreshProfile();
              //   if (response.success) {
              //     user.value.coins = packages[selectedPackage.value].coin;
              //   }
              // });
            }
          });
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume &&
              purchaseDetails.productID == selectedPurchaseId.value) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  subscribeToPackage(String purchaseId, String productId) {
    List<PackageModel> boughtPackages = packages.where((package) {
      if (Platform.isIOS) {
        if (package.inAppPurchaseIdIOS == productId) {
          return true;
        } else {
          return false;
        }
      } else {
        if (package.inAppPurchaseIdAndroid == productId) {
          return true;
        } else {
          return false;
        }
      }
    }).toList();

    PackageModel boughtPackage = boughtPackages.first;

    WalletApi.subscribePackage(
        packageId: boughtPackage.id.toString(),
        transactionId: purchaseId,
        amount: boughtPackage.price.toString(),
        resultCallback: () {
          AppUtil.showToast(message: coinsAddedString.tr, isSuccess: true);
          _userProfileManager.refreshProfile();
          user.value.coins = boughtPackage.coin;
        });
  }

  subscribeToDummyPackage(String purchaseId) {
    WalletApi.subscribePackage(
        packageId: packages[0].id.toString(),
        transactionId: purchaseId,
        amount: packages[0].price.toString(),
        resultCallback: () {
          AppUtil.showToast(message: coinsAddedString.tr, isSuccess: true);
          _userProfileManager.refreshProfile();
          user.value.coins = packages[0].coin;
        });
  }
}
