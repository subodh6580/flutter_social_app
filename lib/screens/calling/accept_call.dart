import 'package:flutter_svg/svg.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/call_model.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:pip_view/pip_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../controllers/chat_and_call/agora_call_controller.dart';

class AcceptCallScreen extends StatefulWidget {
  final Call call;

  const AcceptCallScreen({
    Key? key,
    required this.call,
  }) : super(key: key);

  @override
  State<AcceptCallScreen> createState() => _AcceptCallScreenState();
}

class _AcceptCallScreenState extends State<AcceptCallScreen> {
  final AgoraCallController agoraCallController = Get.find();
  // final GlobalKey<TimerViewState> _timerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Turn on wakelock feature till call is running
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: incomingCallView(),
    );
  }

  Widget incomingCallView() {
    return Stack(
      children: [
        Center(
          child: _renderLocalPreview(),
        ),
        _incomingCallBottomPortionWidget(),
        Center(child: opponentInfoView())
      ],
    );
  }

  Widget topBar() {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        SizedBox(
          height: 70,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const ThemeIconWidget(
              ThemeIcon.backArrow,
              color: Colors.white,
              size: 25,
            ).p8.ripple(() {
              // Get.back();
              PIPView.of(context)!.presentBelow(const DashboardScreen());
            }),
          ]),
        ),
      ],
    );
  }

  // Generate local preview
  Widget _renderLocalPreview() {
    // if (_joined) {
    return Container();
    // } else {
    //   return Padding(
    //     padding: const EdgeInsets.all(15),
    //     child: Text(
    //       waitForJoiningLabel,
    //       textAlign: TextAlign.center,
    //       style: TextStyle(fontSize: FontSizes.b2).themeColor,
    //     ),
    //   );
    // }
  }

  Widget opponentInfoView() {
    return Column(
      children: [
        const SizedBox(
          height: 120,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/outline/call_bubble_overlay.svg',
              height: 350,
              width: 250,
            ),
            Container(
              color: AppColorConstants.themeColor,
              child: UserAvatarView(
                user: widget.call.opponent,
                size: 150,
                onTapHandler: () {},
              ).p8,
            ).circular,
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        Heading3Text(
          widget.call.opponent.userName,
          weight: TextWeight.bold,
          color: AppColorConstants.mainTextColor,
        ),
        const SizedBox(
          height: 5,
        ),
        BodyExtraLargeText(
          widget.call.isOutGoing
              ? ringingString
              : incomingCallString,
          weight: TextWeight.medium,
          color: AppColorConstants.mainTextColor,
        ),
        const SizedBox(
          height: 150,
        ),
      ],
    );
  }

  Widget _incomingCallBottomPortionWidget() => Container(
        margin: const EdgeInsets.only(bottom: 50),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: AppColorConstants.red,
              height: 80,
              width: 80,
              child: const ThemeIconWidget(
                ThemeIcon.declineCall,
                size: 30,
                color: Colors.white,
              ).p16,
            ).circular.ripple(() {
              agoraCallController.declineCall(call: widget.call);
            }),
            const SizedBox(
              width: 25,
            ),
            Container(
              color: AppColorConstants.themeColor,
              height: 80,
              width: 80,
              child: const ThemeIconWidget(
                ThemeIcon.acceptCall,
                size: 30,
                color: Colors.white,
              ).p16,
            ).circular.ripple(() {
              agoraCallController.initiateAcceptCall(call: widget.call);
            }),
          ],
        ),
      );
}
