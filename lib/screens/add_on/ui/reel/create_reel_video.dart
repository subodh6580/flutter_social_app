import 'package:camera/camera.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:foap/screens/add_on/ui/reel/select_music.dart';

import '../../../../main.dart';
import '../../controller/reel/create_reel_controller.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({Key? key}) : super(key: key);

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen>
    with TickerProviderStateMixin {
  CameraController? controller;

  CameraLensDirection lensDirection = CameraLensDirection.back;
  final CreateReelController _createReelController = Get.find();
  AnimationController? animationController;

  @override
  void initState() {
    _initCamera();
    _initAnimation();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CreateReelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initCamera();
    _initAnimation();
  }

  @override
  void dispose() {
    controller!.dispose();
    _createReelController.clear();
    super.dispose();
  }

  _initAnimation() {
    animationController = AnimationController(
        vsync: this,
        duration:
        Duration(seconds: _createReelController.recordingLength.value));
    animationController!.addListener(() {
      setState(() {});
    });
    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        stopRecording();
      }
    });
  }

  _initCamera() async {
    final front =
    cameras.firstWhere((camera) => camera.lensDirection == lensDirection);

    controller = CameraController(front, ResolutionPreset.max,
        enableAudio: _createReelController.croppedAudioFile == null);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              controller == null
                  ? Container()
                  : AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(
                  controller!,
                ).round(20),
              ),
              Positioned(
                left: DesignConstants.horizontalPadding,
                right: DesignConstants.horizontalPadding,
                top: 25,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            color: AppColorConstants.themeColor,
                            child:
                            const ThemeIconWidget(ThemeIcon.close).p4)
                            .circular
                            .ripple(() {
                          Get.back();
                        }),
                        Obx(() => Container(
                            color: AppColorConstants.themeColor,
                            child: Row(
                              children: [
                                if (_createReelController
                                    .selectedAudio.value !=
                                    null)
                                  ThemeIconWidget(
                                    ThemeIcon.music,
                                    color: AppColorConstants.mainTextColor,
                                  ),
                                BodyLargeText(
                                  _createReelController
                                      .selectedAudio.value !=
                                      null
                                      ? _createReelController
                                      .selectedAudio.value!.name
                                      : selectMusicString.tr,
                                  weight: TextWeight.bold,
                                ),
                              ],
                            ).setPadding(
                                left: DesignConstants.horizontalPadding,
                                right: DesignConstants.horizontalPadding,
                                top: 8,
                                bottom: 8))
                            .circular).ripple(() {
                          Get.bottomSheet(
                            SelectMusic(
                              selectedAudioCallback: (croppedAudio, music) {
                                _createReelController
                                    .setCroppedAudio(croppedAudio);
                                _initCamera();
                              },
                              duration:
                              _createReelController.recordingLength.value,
                            ),
                            isScrollControlled: true,
                            ignoreSafeArea: true,
                          );
                        }),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: DesignConstants.horizontalPadding,
                top: 150,
                child: Container(
                  color: AppColorConstants.cardColor.withOpacity(0.5),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (controller == null) {
                            return;
                          }
                          if (controller!.description.lensDirection ==
                              CameraLensDirection.back) {
                            lensDirection = CameraLensDirection.front;
                            _initCamera();
                          } else {
                            lensDirection = CameraLensDirection.back;
                            _initCamera();
                          }
                        },
                        child: Icon(
                          Icons.cameraswitch_outlined,
                          size: 30,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                        onTap: () {
                          if (controller == null) {
                            return;
                          }
                          if (_createReelController.flashSetting.value) {
                            controller!.setFlashMode(FlashMode.off);
                            _createReelController.turnOffFlash();
                          } else {
                            controller!.setFlashMode(FlashMode.always);
                            _createReelController.turnOnFlash();
                          }
                        },
                        child: Icon(
                          _createReelController.flashSetting.value
                              ? Icons.flash_on
                              : Icons.flash_off,
                          size: 30,
                          color: AppColorConstants.themeColor,
                        ),
                      )),
                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                        onTap: () {
                          _createReelController.updateRecordingLength(15);
                          _initAnimation();
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _createReelController
                                  .recordingLength.value ==
                                  15
                                  ? AppColorConstants.themeColor
                                  : AppColorConstants.backgroundColor),
                          child: const Center(child: BodySmallText('15s')),
                        ),
                      )),
                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                        onTap: () {
                          _createReelController.updateRecordingLength(30);
                          _initAnimation();
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _createReelController
                                  .recordingLength.value ==
                                  30
                                  ? AppColorConstants.themeColor
                                  : AppColorConstants.backgroundColor),
                          child: const Center(child: BodySmallText('30s')),
                        ),
                      ))
                    ],
                  ).setPadding(left: 8, right: 8, top: 12, bottom: 12),
                ).round(20),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              animationController!.forward();
              _recordVideo();
              // _recordVideo();
            },
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: animationController!.value,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColorConstants.themeColor),
                  ),
                ),
                Obx(() => Container(
                  height: 50,
                  width: 50,
                  color: AppColorConstants.themeColor,
                  child: ThemeIconWidget(
                    _createReelController.isRecording.value
                        ? ThemeIcon.pause
                        : ThemeIcon.play,
                    size: 30,
                  ),
                ).circular)
              ],
            ),
          ),
        ],
      ),
    );
  }

  _recordVideo() async {
    if (_createReelController.isRecording.value) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void stopRecording() async {
    animationController?.reset();

    final file = await controller!.stopVideoRecording();
    final videoInfo = FlutterVideoInfo();

    var info = await videoInfo.getVideoInfo(file.path);

    if (info?.duration != null) {
      _createReelController.updateRecordingLength(info!.duration!.toInt());
    }

    debugPrint('RecordedFile:: ${file.path}');
    _createReelController.stopRecording();
    if (_createReelController.croppedAudioFile != null) {
      _createReelController.stopPlayingAudio();
    }
    _createReelController.isRecording.value = false;
    _createReelController.createReel(
        _createReelController.croppedAudioFile, file);
  }

  void startRecording() async {
    await controller!.prepareForVideoRecording();
    await controller!.startVideoRecording();
    _createReelController.startRecording();
    if (_createReelController.croppedAudioFile != null) {
      _createReelController
          .playAudioFile(_createReelController.croppedAudioFile!);
    }
    // startRecordingTimer();
  }
}
