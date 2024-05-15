import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:foap/components/timer_widget.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/call_model.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:pip_view/pip_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../controllers/chat_and_call/agora_call_controller.dart';

class VideoCallingScreen extends StatefulWidget {
  final Call call;

  const VideoCallingScreen({
    Key? key,
    required this.call,
  }) : super(key: key);

  @override
  State<VideoCallingScreen> createState() => _VideoCallingScreenState();
}

class _VideoCallingScreenState extends State<VideoCallingScreen> {
  final AgoraCallController agoraCallController = Get.find();
  final GlobalKey<TimerViewState> _timerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Turn on wakelock feature till call is running
  }

  @override
  void dispose() {
    // _engine.leaveChannel();
    // _engine.destroy();
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return PIPView(
      builder: (context, isFloating) {
        return Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: widget.call.isOutGoing
              ? outgoingCallView(isFloating)
              : incomingCallView(isFloating),
        );
      },
      floatingHeight: 150,
      floatingWidth: 100,
    );
  }

  Widget outgoingCallView(bool isFloating) {
    return GetBuilder<AgoraCallController>(
        init: agoraCallController,
        builder: (ctx) {
          return agoraCallController.remoteJoined.value == false
              ? Stack(
                  children: [
                    Center(
                      child: _renderLocalPreview(),
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        Expanded(child: opponentNameAndCallStatus()),
                        const SizedBox(
                          height: 100,
                        ),
                        _outgoingCallBottomPortionWidget(),
                      ],
                    ),
                  ],
                )
              : connectedCallView(isFloating);
        });
  }

  Widget connectedCallView(bool isFloating) {
    return Stack(
      children: [
        Obx(() => Center(
              child: agoraCallController.switchMainView.value
                  ? _renderLocalPreview()
                  : _renderRemoteVideo(isFloating),
            )),
        // _timerView(),
        _cameraView(isFloating),
        isFloating == false ? _outgoingCallBottomPortionWidget() : Container(),
        // isFloating == false ? topBar() : Container(),
      ],
    );
  }

  Widget incomingCallView(bool isFloating) {
    return GetBuilder<AgoraCallController>(
        init: agoraCallController,
        builder: (ctx) {
          return agoraCallController.remoteJoined.value == false
              ? Stack(
                  children: [
                    Center(
                      child: _renderLocalPreview(),
                    ),
                    _incomingCallBottomPortionWidget(),
                    Center(child: opponentInfoView(isFloating))
                  ],
                )
              : connectedCallView(isFloating);
        });
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
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: agoraCallController.engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
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

  // Generate remote preview
  Widget _renderRemoteVideo(bool isFloating) {
    if (agoraCallController.remoteJoined.value == true &&
        agoraCallController.remoteUserId.value != 0) {
      return Stack(
        children: [
          agoraCallController.reConnectingRemoteView.value
              ? Container(
                  color: AppColorConstants.red,
                  child: Center(
                      child: Heading6Text(
                    reConnectingString.tr,
                    color: AppColorConstants.mainTextColor,
                  )))
              : agoraCallController.videoPaused.value
                  ? Container(
                      color: AppColorConstants.themeColor,
                      child: Center(
                          child: Heading6Text(
                        videoPausedString.tr,
                        color: AppColorConstants.mainTextColor,
                      )))
                  : AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: agoraCallController.engine!,
                        canvas: VideoCanvas(
                            uid: agoraCallController.remoteUserId.value),
                        connection:
                            RtcConnection(channelId: widget.call.channelName),
                      ),
                    ),
        ],
      );
    } else {
      return opponentInfoView(isFloating);
    }
  }

  Widget opponentInfoView(bool isFloating) {
    return isFloating
        ? UserAvatarView(
            user: widget.call.opponent,
            size: double.infinity,
            onTapHandler: () {},
          )
        : Column(
            children: [
              const SizedBox(
                height: 120,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // SvgPicture.asset(
                    //     'assets/svg/outline/call_bubble_overlay.svg'),
                    Container(
                      color: AppColorConstants.themeColor,
                      child: UserAvatarView(
                        user: widget.call.opponent,
                        size: 200,
                        onTapHandler: () {},
                      ).p8,
                    ).circular,
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              opponentNameAndCallStatus()
            ],
          );
  }

  opponentNameAndCallStatus() {
    return Column(
      children: [
        Heading3Text(
          widget.call.opponent.userName,
          weight: TextWeight.bold,
          color: AppColorConstants.mainTextColor,
        ),
        const SizedBox(
          height: 5,
        ),
        agoraCallController.remoteJoined.value == false
            ? BodyExtraLargeText(
                widget.call.isOutGoing
                    ? ringingString.tr
                    : incomingCallString.tr,
                weight: TextWeight.medium,
                color: AppColorConstants.mainTextColor,
              )
            : _timerView(),
      ],
    );
  }

  //Timer Ui
  Widget _timerView() => TimerView(
        key: _timerKey,
      );

  //Local Camera View
  Widget _cameraView(bool isFloating) => Container(
        padding: const EdgeInsets.symmetric(vertical: 150, horizontal: 20),
        alignment: Alignment.bottomRight,
        child: FractionallySizedBox(
          child: Container(
            width: 110,
            height: 140,
            alignment: Alignment.topRight,
            color: Colors.black,
            child: GestureDetector(
              onTap: () {
                agoraCallController.toggleMainView();
              },
              child: Center(
                child: agoraCallController.switchMainView.value
                    ? _renderRemoteVideo(isFloating)
                    : _renderLocalPreview(),
              ),
            ),
          ).round(10),
        ),
      );

  // Ui & UX For Bottom Portion (Switch Camera,Video On/Off,Mic On/Off)
  Widget _outgoingCallBottomPortionWidget() => Container(
        margin: const EdgeInsets.only(bottom: 50),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(() => Container(
                  color: agoraCallController.isFront.value
                      ? AppColorConstants.themeColor
                      : AppColorConstants.themeColor.lighten(),
                  height: 65,
                  width: 65,
                  child: const ThemeIconWidget(
                    ThemeIcon.cameraSwitch,
                    size: 30,
                    color: Colors.white,
                  ).p16,
                )).circular.ripple(() {
              agoraCallController.onToggleCamera();
            }),
            const SizedBox(
              width: 15,
            ),
            // Obx(() => Container(
            //       color: agoraCallController.mutedVideo.value
            //           ? AppColorConstants.themeColor.withOpacity(0.5)
            //           : AppColorConstants.themeColor,
            //       height: 65,
            //       width: 65,
            //       child: ThemeIconWidget(
            //         agoraCallController.mutedVideo.value
            //             ? ThemeIcon.videoCameraOff
            //             : ThemeIcon.videoCamera,
            //         size: 30,
            //         color: Colors.white,
            //       ).p16,
            //     )).circular.ripple(() {
            //   agoraCallController.onToggleMuteVideo();
            // }),
            // const SizedBox(
            //   width: 15,
            // ),
            Obx(() => Container(
                  color: agoraCallController.mutedAudio.value
                      ? AppColorConstants.themeColor.withOpacity(0.5)
                      : AppColorConstants.themeColor,
                  height: 65,
                  width: 65,
                  child: ThemeIconWidget(
                    agoraCallController.mutedAudio.value
                        ? ThemeIcon.micOff
                        : ThemeIcon.mic,
                    size: 30,
                    color: Colors.white,
                  ).p16,
                )).circular.ripple(() {
              agoraCallController.onToggleMuteAudio();
            }),
            const SizedBox(
              width: 15,
            ),
            Container(
              color: AppColorConstants.red,
              height: 65,
              width: 65,
              child: const ThemeIconWidget(
                ThemeIcon.callEnd,
                size: 30,
                color: Colors.white,
              ).p16,
            ).circular.ripple(() {
              agoraCallController.onCallEnd(widget.call);
            }),
          ],
        ),
      );

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
