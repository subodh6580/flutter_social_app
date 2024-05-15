import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:facebook_audience_network/ad/ad_rewarded.dart';
import 'package:foap/helper/imports/common_import.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../screens/settings_menu/settings_controller.dart';
import 'ad_network_keys.dart';

// class BannerAdsHelper {
//   late BannerAd _bannerAd;
//
//   loadBannerAds(Function(BannerAd) callback) {
//     _bannerAd = BannerAd(
//       adUnitId: AdHelper.bannerAdUnitId,
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           callback(_bannerAd);
//           print(_bannerAd.adUnitId);
//           print('Ad loaded.');
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           print('Ad failed to load .');
//         },
//         onAdOpened: (ad) => print('Ad opened.'),
//         onAdClosed: (ad) => print('Ad closed.'),
//         onAdImpression: (ad) => print('Ad impression.'),
//       ),
//     )..load();
//   }
// }

class AdNetworkHelper {}

class BannerAdmob extends StatefulWidget {
  const BannerAdmob({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BannerAdmobState();
  }
}

class _BannerAdmobState extends State<BannerAdmob> {
  BannerAd? _bannerAd;
  bool _bannerReady = false;

  @override
  void initState() {
    super.initState();
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdmobKeys().bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _bannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          setState(() {
            _bannerReady = false;
          });
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerReady
        ? SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : Container();
  }
}

class BannerAdsWidget {
  static List<Widget> cachedAds = [];

  static Future<Widget> getBannerWidget(
      { required int index
      // AdSize adSize,
      }) async {
    if (cachedAds.length > index) {
      return cachedAds[index];
    }

    BannerAd bannerAd = BannerAd(
      adUnitId: AdmobKeys().bannerAdUnitId,
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          // if(_debug){
          //   print('Ad loaded.');
          // }
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // if(_debug){
          //   print('Ad failed to load: $error');
          //   //_bannerAd.dispose();
          // }
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {
          // if(_debug){
          //   print('Ad opened.');
          // }
        },
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {
          // if(_debug){
          //   print('Ad closed.');
          // }
        },
        // Called when an ad is in the process of leaving the application.
      ),
    );

    bannerAd.load();

    Widget adWidget = Container(
      constraints: BoxConstraints(
        maxHeight: 50,
        maxWidth: Get.size.width,
        minHeight: 32,
        minWidth: Get.size.width,
      ),
      child: AdWidget(ad: bannerAd),
    );
    cachedAds.add(adWidget);

    return adWidget;
  }
}

//ignore: must_be_immutable
class RewardedInterstitialAds {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  SettingsController settingsController = Get.find();

  void show(VoidCallback onRewarded) {
    if (int.parse(settingsController.setting.value!.networkToUse!) == 1) {
      FacebookRewardedVideoAd.loadRewardedVideoAd(
        placementId: FacebookAudienceNetworkKeys().rewardInterstitialAdUnitId,
        listener: (result, value) {
          if (result == RewardedVideoAdResult.LOADED) {
            FacebookRewardedVideoAd.showRewardedVideoAd();
            // _isRewardedAdLoaded = true;
          }
          if (result == RewardedVideoAdResult.VIDEO_COMPLETE) {
            // updateCoinsBank(coins: 10);
            onRewarded();
          }

          /// Once a Rewarded Ad has been closed and becomes invalidated,
          /// load a fresh Ad by calling this function.
          if (result == RewardedVideoAdResult.VIDEO_CLOSED &&
              (value == true || value["invalidated"] == true)) {}
        },
      );
    } else {
      RewardedInterstitialAd.load(
          adUnitId: AdmobKeys().rewardInterstitialAdUnitId,
          request: const AdRequest(),
          rewardedInterstitialAdLoadCallback:
              RewardedInterstitialAdLoadCallback(
            onAdLoaded: (RewardedInterstitialAd ad) {
              // Keep a reference to the ad so you can show it later.
              _rewardedInterstitialAd = ad;
              _rewardedInterstitialAd?.show(onUserEarnedReward:
                  (AdWithoutView ad, RewardItem rewardItem) {
                // Reward the user for watching an ad.
                onRewarded();
              });
            },
            onAdFailedToLoad: (LoadAdError error) {
              // print('RewardedInterstitialAd failed to load: $error');
            },
          ));
    }
  }
}

//ignore: must_be_immutable
class InterstitialAds {
  InterstitialAd? _interstitialAd;
  SettingsController settingsController = Get.find();

  void show() {
    if (settingsController.setting.value!.networkToUse == '1') {
      FacebookInterstitialAd.loadInterstitialAd(
        placementId: FacebookAudienceNetworkKeys().interstitialAdUnitId,
        listener: (result, value) {
          if (result == InterstitialAdResult.LOADED) {
            FacebookInterstitialAd.showInterstitialAd(delay: 1000);
          }
        },
      );
    } else {
      InterstitialAd.load(
        adUnitId: AdmobKeys().interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialAd?.show();
            _interstitialAd = null;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {},
            );
          },
          onAdFailedToLoad: (err) {},
        ),
      );
    }
  }
}
