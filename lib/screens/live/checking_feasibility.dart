import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../model/call_model.dart';

class CheckingLiveFeasibility extends StatefulWidget {
  final Live? battle;
  final VoidCallback successCallbackHandler;

  const CheckingLiveFeasibility(
      {Key? key,
        this.battle,
        required this.successCallbackHandler})
      : super(key: key);

  @override
  State<CheckingLiveFeasibility> createState() =>
      _CheckingLiveFeasibilityState();
}

class _CheckingLiveFeasibilityState extends State<CheckingLiveFeasibility> {
  final AgoraLiveController _agoraLiveController = Get.find();

  @override
  void initState() {
    _agoraLiveController.checkFeasibilityToLive(
        isOpenSettings: false,
        battle: widget.battle,
        successCallbackHandler: widget.successCallbackHandler);

    super.initState();
  }

  @override
  void dispose() {
    // _agoraLiveController.clear();
    super.dispose();
  }

  openSettingAppForAccess() {
    _agoraLiveController.checkFeasibilityToLive(
      isOpenSettings: true,
      battle: widget.battle,
      successCallbackHandler: widget.successCallbackHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.purple,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Obx(() => Stack(
          children: [
            if (_agoraLiveController.startLiveStreaming.value == 1 ||
                _agoraLiveController.startLiveStreaming.value == 2)
              const LiveBroadcastScreen(),
            if (_agoraLiveController.startLiveStreaming.value != 2)
              Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    color: AppColorConstants.backgroundColor,
                    child: Obx(() => _agoraLiveController.canLive.value == 0
                        ? Center(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            checkingConnectionString.tr,
                            textStyle: TextStyle(
                                fontSize: FontSizes.h3,
                                fontWeight: FontWeight.bold),
                            colors: colorizeColors,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {},
                      ),
                    )
                        : _agoraLiveController.canLive.value == -1
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          color: AppColorConstants.red
                              .withOpacity(0.5),
                          child: const ThemeIconWidget(
                            ThemeIcon.camera,
                            size: 100,
                          ),
                        ).circular,
                        const SizedBox(
                          height: 150,
                        ),
                        Heading4Text(
                          _agoraLiveController.errorMessage!,
                          textAlign: TextAlign.center,
                         weight: TextWeight.regular,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: AppThemeButton(
                            text: allowString.tr,
                            onPress: () {
                              openAppSettings();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 200,
                          height: 45,
                          child: Center(
                            child: Heading4Text(
                              backString.tr,
                            ),
                          ),
                        ).ripple(() {
                          Get.back();
                        })
                      ],
                    ).hp(DesignConstants.horizontalPadding)
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                            width: 20.0, height: 100.0),
                        Heading3Text(
                          goingLiveString.tr,
                        ),
                        const SizedBox(
                            width: 20.0, height: 100.0),
                        DefaultTextStyle(
                          style: TextStyle(
                              fontSize: FontSizes.h3,
                              fontWeight: TextWeight.semiBold,
                              color:
                              AppColorConstants.themeColor),
                          child: AnimatedTextKit(
                            pause:
                            const Duration(milliseconds: 10),
                            totalRepeatCount: 1,
                            animatedTexts: [
                              RotateAnimatedText('3',
                                  duration:
                                  const Duration(seconds: 1),
                                  textStyle: TextStyle(
                                      fontSize: FontSizes.h3,
                                      fontWeight:
                                      TextWeight.regular)),
                              RotateAnimatedText('2',
                                  duration:
                                  const Duration(seconds: 1),
                                  textStyle: TextStyle(
                                      fontSize: FontSizes.h3,
                                      fontWeight:
                                      TextWeight.regular)),
                              RotateAnimatedText('1',
                                  duration:
                                  const Duration(seconds: 1),
                                  textStyle: TextStyle(
                                      fontSize: FontSizes.h3,
                                      fontWeight:
                                      TextWeight.regular)),
                              RotateAnimatedText(goString.tr,
                                  duration:
                                  const Duration(seconds: 1),
                                  textStyle: TextStyle(
                                      fontSize: FontSizes.h3,
                                      fontWeight:
                                      TextWeight.regular)),
                            ],
                            onTap: () {},
                            onFinished: () {
                              goToLive();
                            },
                          ),
                        ),
                      ],
                    )),
                  )),
          ],
        )));
  }

  goToLive() {
    _agoraLiveController.showLiveStreaming();
    // if (widget.battle != null) {
    //   // join a battle
    //   Future.delayed(const Duration(milliseconds: 500), () {
    //     widget.successCallbackHandler();
    //   });
    //   _agoraLiveController.initializeLiveBattle(widget.battle!);
    // } else {
    //   // start new live
    //   _agoraLiveController.initializeLive();
    // }
  }
}
