import 'dart:async';
import 'package:foap/controllers/chat_and_call/voip_controller.dart';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/manager/file_manager.dart';
import 'package:foap/manager/location_manager.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<DBManager>(() => DBManager());
  // getIt.registerLazySingleton<MediaManager>(() => MediaManager());
  getIt.registerLazySingleton<FileManager>(() => FileManager());
  getIt.registerLazySingleton<VoipController>(() => VoipController());
  // getIt.registerLazySingleton<GalleryLoader>(() => GalleryLoader());
  // getIt.registerLazySingleton<NotificationManager>(() => NotificationManager());
  getIt.registerLazySingleton<LocationManager>(() => LocationManager());

}

Future<void> setupSocketServiceLocator1() async {
  if (!getIt.isRegistered<SocketManager>()) {
    getIt.registerLazySingleton<SocketManager>(() => SocketManager());
  }
}
