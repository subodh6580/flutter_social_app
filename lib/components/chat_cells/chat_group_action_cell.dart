import 'dart:convert';

import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';

class ChatGroupActionCell extends StatelessWidget {
  final ChatMessageModel message;

  const ChatGroupActionCell({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> actionMessage = json.decode(message.messageContent.decrypted());
    int action = actionMessage['action'] as int;
    String actionMessageString = '';

    if (action == 1) {
      String userName = actionMessage['username'] as String;

      actionMessageString = '$userName ${addedToGroupString.tr}';
    } else if (action == 2) {
      String userName = actionMessage['username'] as String;

      actionMessageString = '$userName ${removedFromGroupString.tr}';
    } else if (action == 3) {
      String userName = actionMessage['username'] as String;

      actionMessageString = '$userName ${madeAdminString.tr}';
    } else if (action == 4) {
      String userName = actionMessage['username'] as String;

      actionMessageString = '$userName ${removedFromAdminsString.tr}';
    } else if (action == 5) {
      String userName = actionMessage['username'] as String;

      actionMessageString = '$userName ${leftTheGroupString.tr}';
    }

    return Container(
            color: AppColorConstants.themeColor.lighten(0.2),
            child: BodyLargeText(
              actionMessageString,
            ).setPadding(left: 8, right: 8, top: 4, bottom: 4))
        .round(10);
  }
}
