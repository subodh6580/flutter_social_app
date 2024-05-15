import 'package:foap/components/place_picker/entities/entities.dart';
import 'package:foap/helper/imports/common_import.dart';

class NearbyPlaceItem extends StatelessWidget {
  final NearbyPlace nearbyPlace;
  final VoidCallback onTap;

  const NearbyPlaceItem(this.nearbyPlace, this.onTap, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: <Widget>[
              CachedNetworkImage(imageUrl: nearbyPlace.icon!, width: 16),
              const SizedBox(width: 24),
              Expanded(
                  child: Heading6Text(
                "${nearbyPlace.name}",
              ))
            ],
          ),
        ),
      ),
    );
  }
}
