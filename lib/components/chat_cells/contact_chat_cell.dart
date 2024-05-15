import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';

class ContactChatTile extends StatelessWidget {
  final ChatMessageModel message;

  const ContactChatTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading5Text(
                contactString.tr,
                  weight: TextWeight.bold),
              BodyLargeText(
                message.mediaContent.contact!.displayName,
              ),
              BodyLargeText(
                message.mediaContent.contact!.phones
                    .map((e) => e.number)
                    .toString(),
              ),
            ],
          ),
        ),
        ThemeIconWidget(
          ThemeIcon.nextArrow,
          size: 15,
          color: AppColorConstants.iconColor,
        )
      ],
    ).bP8;
  }
}
