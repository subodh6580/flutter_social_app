import 'package:foap/helper/imports/common_import.dart';
import 'package:google_static_maps_controller/google_static_maps_controller.dart'
    as static_map;

class StaticMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final int height;
  final int width;

  const StaticMapWidget(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.height,
      required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = static_map.StaticMapController(
        googleApiKey: AppConfigConstants.googleMapApiKey,
        width: width,
        height: height,
        zoom: 15,
        center: static_map.Location(latitude, longitude),
        markers: [
          static_map.Marker(locations: [static_map.Location(latitude, longitude)])
        ]);
    ImageProvider image = controller.image;

    return Image(image: image).round(10);
  }
}
