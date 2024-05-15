import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import '../../components/sm_tab_bar.dart';

class AuthTab extends StatefulWidget {
  const AuthTab({Key? key}) : super(key: key);

  @override
  State<AuthTab> createState() => _AuthTabState();
}

class _AuthTabState extends State<AuthTab> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            body: Stack(
          children: [
            const TabBarView(children: [
              LoginScreen(),
              SignUpScreen(),
            ]),
            Positioned(
              left: DesignConstants.horizontalPadding,
              right: DesignConstants.horizontalPadding,
              bottom: 20,
              child: Container(
                color: AppColorConstants.cardColor.withOpacity(0.8),
                child: SMTabBar(tabs: [
                  signInString,
                  signUpString,
                ], canScroll: false),
              ).round(40),
            )
          ],
        )));
  }
}
