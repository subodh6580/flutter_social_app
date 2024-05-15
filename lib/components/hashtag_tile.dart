import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';

import '../model/hash_tag.dart';

class HashTagTile extends StatelessWidget {
  final Hashtag hashtag;
  final VoidCallback onItemCallback;

  const HashTagTile({
    Key? key,
    required this.hashtag,
    required this.onItemCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              height: 40,
              width: 40,
              child: Center(
                  child: Heading3Text(
                '#',
              )),
            ).borderWithRadius(value: 0.5, radius: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading5Text(
                  hashtag.name,
                  weight: TextWeight.medium,
                ).bP4,
                BodyLargeText(
                  '${hashtag.counter.formatNumber} ${postsString.tr.toLowerCase()}',
                  weight: TextWeight.medium,
                )
              ],
            ).hp(DesignConstants.horizontalPadding),
          ],
        ).vP16.ripple(() {
          onItemCallback();
        }),
      ],
    );
  }
}
