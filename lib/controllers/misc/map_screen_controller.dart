import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/manager/location_manager.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;

class MapScreenController extends GetxController {
  RxList<UserModel> users = <UserModel>[].obs;
  RxSet<google_map.Marker> markers = <google_map.Marker>{}.obs;
  Rx<LocationModel?> currentLocation = Rx<LocationModel?>(null);
  final LocationManager _locationManager = Get.find();

  clear() {
    users.clear();
    markers.clear();
  }

  getLocation() {
    _locationManager.getLocation(locationCallback: (locationData){
      currentLocation.value = locationData;
      update();
      queryFollowers();
    });
    // Location().getLocation().then((locationData) {
    //
    // }).catchError((error) {});
  }

  Future<List<UserModel>> queryFollowers() async {
    await UsersApi.getFollowingUsers(resultCallback: (result, metadata) {
      users.value = result;
      createMarkers();
    });

    return users;
  }

  createMarkers() async {
    for (UserModel userModel in users) {
      if (userModel.latitude != null) {
        String? imgUrl = userModel.picture;
        Uint8List bytes;

        if (imgUrl != null) {
          bytes = (await NetworkAssetBundle(Uri.parse(imgUrl)).load(imgUrl))
              .buffer
              .asUint8List();
          convertImageFileToCustomBitmapDescriptor(bytes,
                  title: userModel.userName,
                  size: 170,
                  borderSize: 20,
                  addBorder: true,
                  borderColor: Colors.white)
              .then((value) {
            getMarkers(userModel, value);
          });
        } else {
          final ByteData bytesData =
              (await rootBundle.load('assets/account_selected.png'));
          bytes = bytesData.buffer.asUint8List();

          // bytes = await Image.asset(name)
          google_map.BitmapDescriptor.fromAssetImage(
                  const ImageConfiguration(size: Size(12, 12)),
                  'assets/account_selected.png')
              .then((icon) {
            getMarkers(userModel, icon);
          });
        }
      }
    }
  }

  getMarkers(UserModel userModel, google_map.BitmapDescriptor icon) async {
    markers.add(google_map.Marker(
      //add first marker
      markerId: google_map.MarkerId(userModel.id.toString()),
      position: google_map.LatLng(double.parse(userModel.latitude!),
          double.parse(userModel.longitude!)),
      icon: icon,
      onTap: () {
        Get.to(() => OtherUserProfile(userId: userModel.id));
        // QuickActions.showUserProfile(context, userModel)
      },
    ));
    markers.refresh();
    update();
  }

  static Future<google_map.BitmapDescriptor>
      convertImageFileToCustomBitmapDescriptor(Uint8List imageUint8List,
          {int size = 150,
          bool addBorder = false,
          Color borderColor = Colors.white,
          double borderSize = 10,
          String? title,
          Color titleColor = Colors.white,
          Color titleBackgroundColor = Colors.black}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;
    final TextPainter textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );
    final double radius = size / 2;

//make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        const Radius.circular(100)));
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        const Radius.circular(100)));
    canvas.clipPath(clipPath);

//paintImage
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);

    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image);

    if (addBorder) {
//draw Border
      paint.color = borderColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    if (title != null) {
      if (title.length > 9) {
        title = title.substring(0, 9);
      }
//draw Title background
      paint.color = titleBackgroundColor;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
              const Radius.circular(100)),
          paint);

//draw Title
      textPainter.text = TextSpan(
          text: title,
          style: TextStyle(
            fontSize: radius / 2.5,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ));
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(radius - textPainter.width / 2,
              size * 9.5 / 10 - textPainter.height / 2));
    }

//convert canvas as PNG bytes
    final image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());

    final data = await image.toByteData(format: ui.ImageByteFormat.png);

//convert PNG bytes as BitmapDescriptor
    return google_map.BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}
