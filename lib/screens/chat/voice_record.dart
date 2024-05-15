import 'dart:async';
import 'dart:io';
export 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../util/constant_util.dart';
import 'package:audio_session/audio_session.dart';
import 'package:record/record.dart';

class VoiceRecord extends StatefulWidget {
  final Function(Media) recordingCallback;

  const VoiceRecord({Key? key, required this.recordingCallback})
      : super(key: key);

  @override
  State<VoiceRecord> createState() => _VoiceRecordState();
}

class _VoiceRecordState extends State<VoiceRecord> {
  bool isRecorded = false;
  String? recordingPath;

  // final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final record = Record();

  int _seconds = 0;
  late Timer _timer;

  // final FlutterSoundRecorderSettings settings = FlutterSoundRecorderSettings();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startRecording();
    });
    super.initState();
  }

  startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    recordingPath = '${tempDir.path}/${randomId()}.m4a';
    File audioFile = File(recordingPath!);
    if (!audioFile.existsSync()) {
      audioFile.createSync();
    }

    // Map<Permission, PermissionStatus> statuses =
    //     await [Permission.microphone].request();

    if (await record.hasPermission()) {
      await record.start(
        path: recordingPath,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        // sampleRate: 44100, // by default
      );
      _startTimer();
    } else {
      AppUtil.showToast(
          message: 'Recording permissions are not provided', isSuccess: false);
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.allowBluetooth |
      AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
      AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds += 1;
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  @override
  void dispose() async {
    bool isRecording = await record.isRecording();
    if (isRecording) {
      await record.stop();
    }
    // setState(() {
    //   _seconds = 0;
    // });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.backgroundColor,
      child: Column(
        children: [
          // const Spacer(),
          Container(
            height: 150,
            color: AppColorConstants.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ThemeIconWidget(
                  ThemeIcon.mic,
                  color: AppColorConstants.themeColor,
                  size: 60,
                ),
                // const SizedBox(
                //   width: 10,
                // ),
                SizedBox(
                  width: 150,
                  child: Heading1Text(
                    '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
                    weight: TextWeight.regular,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ).round(20).p16,
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  color: AppColorConstants.cardColor,
                  child: Center(
                    child: ThemeIconWidget(
                      isRecorded == true ? ThemeIcon.send : ThemeIcon.stop,
                      size: 25,
                    ),
                  ),
                ).circular.ripple(() {
                  setState(() {
                    if (isRecorded == true) {
                      sendRecording();
                    } else {
                      stopRecording();
                      isRecorded = true;
                    }
                  });
                }),
                const SizedBox(
                  width: 50,
                ),
                Container(
                  height: 50,
                  width: 50,
                  color: AppColorConstants.cardColor,
                  child: Center(
                    child: ThemeIconWidget(
                      ThemeIcon.close,
                      color: AppColorConstants.iconColor,
                      size: 25,
                    ),
                  ),
                ).circular.ripple(() {
                  Get.back();
                })
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    ).topRounded(40);
  }

  stopRecording() async {
    // await recorder.stopRecorder();
    // await recorder.closeRecorder();
    await record.stop();

    _stopTimer();
  }

  sendRecording() {
    // print(recordingPath);
    File file = File(recordingPath!);
    // print(recordingPath);

    Uint8List data = file.readAsBytesSync();

    if (recordingPath != null) {
      Media media = Media(
        file: File(recordingPath!),
        filePath: recordingPath!,
        fileSize: data.length,
        mainFileBytes: data,
        id: randomId(),
        creationTime: DateTime.now(),
        mediaType: GalleryMediaType.audio,
      );
      widget.recordingCallback(media);
    }
    Get.back();
  }
}
