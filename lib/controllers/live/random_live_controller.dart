// import 'package:foap/apiHandler/api_controller.dart';
// import 'package:foap/apiHandler/apis/live_streaming_api.dart';
// import 'package:foap/helper/imports/common_import.dart';
// import 'package:foap/model/user_model.dart';
// import 'package:get/get.dart';
//
// class RandomLivesController extends GetxController {
//   RxList<UserModel> randomUsers = <UserModel>[].obs;
//
//   int page = 1;
//   bool canLoadMore = true;
//
//   clear() {
//     randomUsers.clear();
//     canLoadMore = true;
//     page = 1;
//   }
//
//   // getAllRandomLives() {
//   //   if (canLoadMore) {
//   //     LiveStreamingApi.getRandomLiveUsers(resultCallback: (result, metadata) {
//   //       randomUsers.addAll(result);
//   //       randomUsers.refresh();
//   //
//   //       page += 1;
//   //       if (result.length == metadata.perPage) {
//   //         canLoadMore = true;
//   //       } else {
//   //         canLoadMore = false;
//   //       }
//   //     });
//   //   }
//   // }
// }
