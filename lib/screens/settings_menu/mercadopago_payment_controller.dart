import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:mercado_pago_mobile_checkout/mercado_pago_mobile_checkout.dart';
// import 'package:mercadopago_sdk/mercadopago_sdk.dart';

class MercadappagoPaymentController extends GetxController {
  final String accessToken =
      "APP_USR-198032055845990-040405-759ac20c431fdb0db1a4513178bdff82-675559183";
  final String clientId = "198032055845990";
  final String clientSecret = "ZYIggIkgxtHAcaYaG85zqyqB5D4VaOgN";
  final String publicKey = "APP_USR-386101b1-2bb8-4c7f-8bc4-c45fb097218e";

  // Future<Map<String, dynamic>> createCheckout() async {
  //   print('createCheckout creating checkout');
  //   var mp = MP(clientId, clientSecret);
  //
  //   var preference = {
  //     "items": [
  //       {
  //         "title": "Test",
  //         "quantity": 1,
  //         "currency_id": "BR",
  //         "unit_price": 10.4
  //       }
  //     ]
  //   };
  //   var result = await mp.createPreference(preference);
  //   print('createCheckout creating done');
  //   print('createCheckout result: $result');
  //
  //   // var result2  = await mp.post(uri);
  //   return result;
  // }

//
//   Future<Map<String, dynamic>> getPayment() async {
//     var mp = MP(clientId, clientSecret);
//     print('getPayment result: init...');
//     final paymentInfo = await mp.getPayment("675559183-0b7b187a-9c2a-46f1-b778-cbbe46e6458c");
//     print('getPayment result: $paymentInfo');
//     return paymentInfo;
//   }

  // Future<Map<String, dynamic>> makePayment() async {
  //   var mp = MP(clientId, clientSecret);
  //   Map<String, dynamic> paymentData = {
  //     "transaction_amount": 100.0,
  //     "token": "ff8080814c11e237014c1ff593b57b4d",
  //     "description": "Test payment",
  //     "installments": 1,
  //     "payment_method_id": "visa",
  //     "payer": {
  //       "email": "payer_email@example.com"
  //     }
  //   };
  //
  //   Map<String,String> param = {
  //     'Authorization': 'Bearer $accessToken'
  //   };
  //
  //   mp.post("/v1/payments",data: paymentData,params: param).then((response) {
  //     // Payment was successful
  //     print("makePayment response:  $response");
  //     return response;
  //   }).catchError((error) {
  //     // An error occurred
  //     print("makePayment error:  $error");
  //   });
  //   return {'faild':'payment not complete '};
  // }

  // void makePayment() async {
  //   final result = await MercadoPagoMobileCheckout.startCheckout(
  //     publicKey,
  //     "675559183-cd2bb8fe-4df0-4292-9e51-cb1d6b6dda55",
  //   );
  //   print('makepayment  result : $result ');
  // }

}
