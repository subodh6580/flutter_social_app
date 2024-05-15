import 'dart:typed_data';
import '../../helper/imports/common_import.dart';

class StoryReactionOptions extends StatelessWidget {
  final Function(String) reactionCallbackHandler;

  StoryReactionOptions({Key? key, required this.reactionCallbackHandler})
      : super(key: key);

  List<String> emoticons = [
    'emoji1.png',
    'emoji2.png',
    'emoji3.png',
    'emoji4.png',
    'emoji5.png',
    'emoji6.png',
  ];

  Future<Uint8List> emojiToImage(String emoji) async {
    final codeUnits = emoji.codeUnits;
    final bytes = Uint8List.fromList(codeUnits);
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: Get.width,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 50,
            crossAxisSpacing: 50,
            childAspectRatio: 1),
        padding: EdgeInsets.only(
            top: 150,
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding),
        itemBuilder: (context, index) {
          final emoji = 'assets/emoji/${emoticons[index]}';

          return Image.asset(
            emoji,
            height: 20,
            width: 20,
          ).ripple(() {
            reactionCallbackHandler(emoji);
          });
        },
        itemCount: emoticons.length,
      ),
    );
  }
}
