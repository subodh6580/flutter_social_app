import 'package:flutter_contacts/contact.dart';
import 'package:foap/helper/imports/common_import.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final bool isSelected;

  const ContactTile({Key? key, required this.contact, required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading5Text(
                contact.displayName,
                weight: TextWeight.semiBold,
              ),
              BodyLargeText(
                contact.phones.map((e) => e.number).toList().join(','),
                color: AppColorConstants.subHeadingTextColor,
              )
            ],
          ),
        ),
        isSelected
            ? ThemeIconWidget(
                ThemeIcon.checkMarkWithCircle,
                size: 20,
                color: AppColorConstants.themeColor,
              )
            : const ThemeIconWidget(
                ThemeIcon.circleOutline,
                size: 20,
              )
      ],
    );
  }
}
