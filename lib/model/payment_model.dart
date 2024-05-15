import 'package:intl/intl.dart';

class PaymentModel {
  String amount = '';
  int status = 0;
  String createDate = '';

  PaymentModel();

  factory PaymentModel.fromJson(dynamic json) {
    PaymentModel model = PaymentModel();
    model.amount = (json['amount'] ?? '').toString();
    model.status = json['status'];

    DateTime createDate =
        DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000).toUtc();
    String dateString = DateFormat('MMM dd, yyyy').format(createDate);
    model.createDate = dateString;

    return model;
  }
}
