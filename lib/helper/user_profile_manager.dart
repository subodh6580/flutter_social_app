import 'dart:async';
import 'package:foap/apiHandler/apis/auth_api.dart';
import 'package:foap/apiHandler/apis/profile_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/login_sign_up/auth_tab.dart';
import '../util/shared_prefs.dart';

class UserProfileManager extends GetxController {
  final DashboardController _dashboardController = Get.find();

  Rx<UserModel?> user = Rx<UserModel?>(null);

  bool get isLogin {
    return user.value != null;
  }

  logout() async {
    user.value = null;

    await AuthApi.logout();

    SharedPrefs().clearPreferences();
    Get.offAll(() => const AuthTab());
    getIt<SocketManager>().disconnect();
    getIt<DBManager>().clearAllUnreadCount();
    getIt<DBManager>().deleteAllChatHistory();

    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    Future.delayed(const Duration(seconds: 2), () {
      _dashboardController.indexChanged(0);
    });
    SharedPrefs().setBioMetricAuthStatus(false);
  }

  Future refreshProfile() async {
    String? authKey = await SharedPrefs().getAuthorizationKey();

    if (authKey != null) {
      await ProfileApi.getMyProfile(resultCallback: (result) {
        user.value = result;

        if (user.value != null) {
          setupSocketServiceLocator1();
        }
        return;
      });
    } else {
      return;
      // print('no auth token found');
    }
  }
}
