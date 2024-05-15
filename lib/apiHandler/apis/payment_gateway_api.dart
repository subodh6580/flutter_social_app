import 'package:foap/apiHandler/api_wrapper.dart';

class PaymentGatewayApi {
  static fetchPaymentIntentClientSecret(
      {required double amount,
      required Function(String) resultCallback}) async {
    var url = NetworkConstantsUtil.createPaymentIntent;

    ApiWrapper().postApi(url: url, param: {
      'amount': amount.toString(),
      'currency': 'USD',
    }).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['client_secret']);
      }
    });
  }

  static fetchPaypalClientToken(
      {required Function(String?) resultCallback}) async {
    var url = NetworkConstantsUtil.getPaypalClientToken;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['client_token']);
      } else {
        resultCallback(null);
      }
    });
  }

  static sendPaypalPayment(
      {required double amount,
      required String nonce,
      required String deviceData,
      required Function(String?) resultCallback}) async {
    var url = NetworkConstantsUtil.submitPaypalPayment;

    ApiWrapper().postApi(url: url, param: {
      'amount': amount.toString(),
      'payment_method_nonce': nonce,
      'device_data': deviceData,
    }).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['payment_id']);
      }
    });
  }
}
