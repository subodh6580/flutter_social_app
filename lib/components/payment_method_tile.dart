import 'package:foap/helper/imports/common_import.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    Key? key,
    required this.text,
    required this.price,
    required this.icon,
    required this.isSelected,
    this.press,
  }) : super(key: key);

  final String text, price, icon;
  final VoidCallback? press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
            color: AppColorConstants.cardColor.darken(),
            height: 50,
            width: double.infinity,
            child: Image.asset(
              icon,
              width: double.infinity,
              height: 50,
            ).p(12))
        .round(10)
        .vP8
        .ripple(press!);
  }
}
