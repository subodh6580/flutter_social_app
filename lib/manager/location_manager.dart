import 'package:fl_location/fl_location.dart';
import 'package:get/get.dart';
import '../model/location.dart';

class LocationManager extends GetxController {
  Rx<LocationModel?> currentPosition = Rx<LocationModel?>(null);

  postLocation() {
    // Location().getLocation().then((locationData) {
    //   LatLng location = LatLng(
    //       latitude: locationData.latitude!, longitude: locationData.longitude!);
    //   ApiController().updateUserLocation(location);
    // }).catchError((error) {});
  }

  stopPostingLocation() {
    // Location().getLocation().then((locationData) {
    //   ApiController().stopSharingUserLocation();
    // }).catchError((error) {});
  }

  getLocation({required Function(LocationModel) locationCallback}) async {
    if (!await FlLocation.isLocationServicesEnabled) {
      // Location services are disabled.
      // locationCallback(AppConfigConstants.defaultLocationForMap);

      return false;
    }

    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      // locationCallback(AppConfigConstants.defaultLocationForMap);

      // Cannot request runtime permission because location permission is denied forever.
      return false;
    } else if (locationPermission == LocationPermission.denied) {
      // locationCallback(AppConfigConstants.defaultLocationForMap);

      // Ask the user for location permission.
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) return false;
    }

    // Location permission must always be allowed (LocationPermission.always)
    // to collect location data in the background.
    // if (locationPermission == LocationPermission.whileInUse) return false;

    // location.getLocation().then((value) {
    //   currentPosition.value = value;
    //   locationCallback(value);
    // });
    //
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   currentPosition.value =
    //       LocationModel(latitude: 0, longitude: 0, name: '');
    //   locationCallback(currentLocation);
    // });

    const timeLimit = Duration(seconds: 10);
    await FlLocation.getLocation(timeLimit: timeLimit).then((location) {
      currentPosition.value = LocationModel(
          latitude: location.latitude, longitude: location.longitude, name: '');
      locationCallback(currentPosition.value!);

    }).onError((error, stackTrace) {
      // locationCallback(AppConfigConstants.defaultLocationForMap);
    });
  }
}
