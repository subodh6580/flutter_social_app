import 'package:flutter/material.dart';
import '../util/app_config_constants.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Color? backgroundColor;
  final AppBar? appBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool? extendBodyBehindAppBar;

  const AppScaffold(
      {Key? key,
        required this.body,
        this.backgroundColor,
        this.appBar,
        this.floatingActionButton,
        this.bottomNavigationBar,
        this.resizeToAvoidBottomInset,
        this.extendBodyBehindAppBar,
        this.floatingActionButtonLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            backgroundColor:
            backgroundColor ?? AppColorConstants.backgroundColor,
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: body),
            appBar: appBar,
            floatingActionButton: floatingActionButton,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButtonLocation: floatingActionButtonLocation));
  }
}
