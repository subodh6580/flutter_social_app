import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:lottie/lottie.dart';

import '../../model/reel_music_model.dart';

class AudioTile extends StatelessWidget {
  final ReelMusicModel audio;
  final bool isPlaying;
  final VoidCallback playCallBack;
  final VoidCallback stopBack;
  final VoidCallback useAudioBack;

  const AudioTile(
      {Key? key,
      required this.audio,
      required this.isPlaying,
      required this.playCallBack,
      required this.useAudioBack,
      required this.stopBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: audio.thumbnail,
            fit: BoxFit.cover,
            height: 50,
            width: 50,
          ).round(10),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BodyLargeText(audio.name, weight: TextWeight.semiBold),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  BodySmallText(
                    audio.artists,
                    weight: TextWeight.medium,
                    color: AppColorConstants.mainTextColor,
                  ),
                  Container(
                    height: 5,
                    width: 5,
                    color: AppColorConstants.mainTextColor,
                  ).circular.hP8,
                  BodySmallText(
                    '${audio.numberOfReelsMade.formatNumber} ${reelsString.tr}',
                    weight: TextWeight.medium,
                    color: AppColorConstants.mainTextColor,
                  ),
                  Container(
                    height: 5,
                    width: 5,
                    color: AppColorConstants.dividerColor,
                  ).circular.hP8,
                  BodySmallText(audio.duration.formatTime,
                      weight: TextWeight.medium,
                      color: AppColorConstants.mainTextColor),
                ],
              ),
            ],
          ).ripple(() {
            useAudioBack();
          }),
          const Spacer(),
          if (isPlaying)
            Container(
                child: Lottie.asset('assets/lottie/audio_playing.json').p4.rP8),
          Container(
            child: ThemeIconWidget(
              isPlaying ? ThemeIcon.pause : ThemeIcon.play,
              size: 20,
            ).p4,
          ).borderWithRadius(value: 2, radius: 20).ripple(() {
            if (isPlaying) {
              stopBack();
            } else {
              playCallBack();
            }
          })
        ],
      ),
    );
  }
}
