import 'package:foap/helper/imports/common_import.dart';

import 'package:foap/helper/imports/chat_imports.dart';

class ChatImageViewer extends StatefulWidget {
  final ChatMessageModel chatMessage;
  final VoidCallback? handler;

  const ChatImageViewer({Key? key, required this.chatMessage, this.handler})
      : super(key: key);

  @override
  EnlargeImageViewState createState() => EnlargeImageViewState();
}

class EnlargeImageViewState extends State<ChatImageViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ThemeIconWidget(
                  ThemeIcon.backArrow,
                  size: 20,
                  color: Colors.white,
                ).ripple(() {
                  Get.back();
                }),
              ],
            ).hp(DesignConstants.horizontalPadding),
            divider().vP8,
            Expanded(
                child: MessageImage(
                    message: widget.chatMessage, fitMode: BoxFit.contain)),
          ],
        ));
  }
}
