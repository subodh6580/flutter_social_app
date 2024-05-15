import 'package:foap/helper/imports/common_import.dart';

import '../model/location.dart';

class LocationTile extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onItemCallback;

  const LocationTile({
    Key? key,
    required this.location,
    required this.onItemCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: ThemeIconWidget(
                ThemeIcon.addressPin,
                size: 20,
                color: AppColorConstants.iconColor,
              ),
            ).borderWithRadius( value: 0.5, radius: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading5Text(location.name, weight: TextWeight.medium).bP4,
                const BodyLargeText(
                  '1.50k posts',
                )
              ],
            ).hp(DesignConstants.horizontalPadding),
          ],
        ).p16.ripple(() {
          onItemCallback();
        }),
      ],
    );
  }
}
