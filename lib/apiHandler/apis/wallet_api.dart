import 'dart:ui';

import 'package:foap/apiHandler/api_wrapper.dart';

import '../../model/package_model.dart';
import '../../model/payment_model.dart';

class WalletApi {
  static getAllPackages(
      {required Function(List<PackageModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getPackages;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var packagesArr = result!.data['package'];
        resultCallback(List<PackageModel>.from(
            packagesArr.map((x) => PackageModel.fromJson(x))));
      }
    });
  }

  static subscribePackage(
      {required String packageId,
      required String transactionId,
      required String amount,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.subscribePackage;

    ApiWrapper().postApi(url: url, param: {
      "package_id": packageId,
      "transaction_id": transactionId,
      "amount": amount
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static getWithdrawHistory(
      {required Function(List<PaymentModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.withdrawHistory;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        resultCallback(List<PaymentModel>.from(
            result!.data['payment'].map((x) => PaymentModel.fromJson(x))));
      }
    });
  }

  static Future performWithdrawalRequest() async {
    var url = NetworkConstantsUtil.withdrawalRequest;

    await ApiWrapper().postApi(url: url, param: null).then((result) {
      if (result?.success == true) {}
    });
  }

  static Future redeemCoinsRequest({required int coins}) async {
    var url = NetworkConstantsUtil.redeemCoins;

    await ApiWrapper().postApi(
        url: url, param: {"redeem_coin": coins.toString()}).then((result) {
      if (result?.success == true) {}
    });
  }

  static Future rewardCoins() async {
    var url = NetworkConstantsUtil.rewardedAdCoins;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {}
    });
  }
}
