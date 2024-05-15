import 'package:foap/helper/imports/common_import.dart';

import '../model/payment_model.dart';

class TransactionTile extends StatelessWidget {
  final PaymentModel model;

  const TransactionTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 15.0),
            child: Row(children: [
              Container(
                color: AppColorConstants.themeColor.withOpacity(0.1),
                height: 31,
                width: 31,
                child: ThemeIconWidget(ThemeIcon.wallet,
                    color: AppColorConstants.iconColor, size: 18),
              ).circular,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BodyLargeText(
                    withdrawalString.tr,
                    color: AppColorConstants.themeColor,
                  ),
                  const SizedBox(height: 5),
                  BodySmallText(
                    model.createDate,
                  )
                ],
              ).lP8,
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BodyLargeText('\$${model.amount}',
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor)
                      .bP4,
                  BodyMediumText(
                    model.status == 1
                        ? pendingString.tr
                        : model.status == 2
                            ? rejectedString.tr
                            : completedString.tr,
                    weight: TextWeight.medium,
                    color: model.status == 1
                        ? AppColorConstants.themeColor
                        : AppColorConstants.red,
                  ),
                ],
              )
            ])),
      ],
    );
  }
}
