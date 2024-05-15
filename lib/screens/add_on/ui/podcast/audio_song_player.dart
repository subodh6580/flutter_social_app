import 'package:cached_network_image/cached_network_image.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'package:foap/screens/add_on/ui/podcast/seekbar_data.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioSongPlayer extends StatefulWidget {
  final List<PodcastEpisodeModel>? songsArray;
  final PodcastModel? show;

  const AudioSongPlayer({Key? key, this.songsArray, this.show})
      : super(key: key);

  @override
  State<AudioSongPlayer> createState() => _AudioSongPlayerState();
}

class _AudioSongPlayerState extends State<AudioSongPlayer> {
  just_audio.AudioPlayer audioPlayer = just_audio.AudioPlayer();
  int currentSongIndex = 0;
  bool _favorite = false;
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    currentSongIndex = 0;
    List<just_audio.AudioSource> audios = widget.songsArray
            ?.map((e) => just_audio.AudioSource.uri(Uri.parse(e.audioUrl)))
            .toList() ??
        [];
    audioPlayer
        .setAudioSource(just_audio.ConcatenatingAudioSource(children: audios));
    audioPlayer.play();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Stream<SeekbarData> get _seekbarDataStream =>
      rxdart.Rx.combineLatest2<Duration, Duration?, SeekbarData>(
          audioPlayer.positionStream, audioPlayer.durationStream, (
        Duration position,
        Duration? duration,
      ) {
        return SeekbarData(position, duration ?? Duration.zero);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: widget.songsArray?[0].imageUrl ?? "",
            fit: BoxFit.cover,
            width: Get.width,
            // height: 230,
          ),
          ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(.5),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [
                      0.0,
                      0.4,
                      0.6
                    ]).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: (Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.black,
                      Colors.grey.withOpacity(0.8),
                    ])),
              ))),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading3Text(
                  widget.songsArray?[currentSongIndex].name ?? '',
                  weight: TextWeight.bold,
                  color: AppColorConstants.subHeadingTextColor,
                ),
                const SizedBox(height: 10),
                BodySmallText(
                  widget.show?.name ?? '',
                  maxLines: 2,
                  color: AppColorConstants.subHeadingTextColor,
                ),
                const SizedBox(height: 10),
                StreamBuilder<SeekbarData>(
                    stream: _seekbarDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                          position: positionData?.position ?? Duration.zero,
                          duration: positionData?.duration ?? Duration.zero,
                          onChangedEnd: audioPlayer.seek);
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                _favorite = !_favorite;
                              }),
                          iconSize: 30,
                          icon: Icon(
                            _favorite
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: _favorite
                                ? AppColorConstants.themeColor
                                : Colors.white,
                          )),
                    ),
                    StreamBuilder<just_audio.SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, index) {
                          return IconButton(
                              onPressed: () {
                                if (audioPlayer.hasPrevious) {
                                  currentSongIndex = currentSongIndex - 1;
                                  audioPlayer.seek(Duration.zero,
                                      index: currentSongIndex);
                                  setState(() {});
                                  // audioPlayer.seekToPrevious;
                                }
                              },
                              iconSize: 45,
                              icon: const Icon(
                                Icons.skip_previous,
                                color: Colors.white,
                              ));
                        }),
                    StreamBuilder(
                        stream: audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final playerState = snapshot.data;
                            final processingState =
                                (playerState! as just_audio.PlayerState)
                                    .processingState;

                            if (processingState ==
                                    just_audio.ProcessingState.loading ||
                                processingState ==
                                    just_audio.ProcessingState.buffering) {
                              return Container(
                                width: 64.0,
                                height: 64.0,
                                margin: const EdgeInsets.all(10.0),
                                child: const CircularProgressIndicator(),
                              );
                            } else if (!audioPlayer.playing) {
                              return IconButton(
                                  onPressed: audioPlayer.play,
                                  iconSize: 75,
                                  icon: const Icon(
                                    Icons.play_circle,
                                    color: Colors.white,
                                  ));
                            } else if (processingState !=
                                just_audio.ProcessingState.completed) {
                              return IconButton(
                                  onPressed: audioPlayer.pause,
                                  iconSize: 75,
                                  icon: const Icon(
                                    Icons.pause_circle,
                                    color: Colors.white,
                                  ));
                            } else {
                              return IconButton(
                                  onPressed: () {
                                    currentSongIndex = 0;
                                    audioPlayer.seek(Duration.zero,
                                        index: currentSongIndex);
                                    setState(() {});
                                    // audioPlayer.seek(
                                    //     Duration.zero,
                                    //     index:
                                    //     audioPlayer.effectiveIndices!.first)
                                  },
                                  iconSize: 75,
                                  icon: const Icon(
                                    Icons.replay_circle_filled_outlined,
                                    color: Colors.white,
                                  ));
                            }
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                    StreamBuilder<just_audio.SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, index) {
                          return IconButton(
                              onPressed: () {
                                if (audioPlayer.hasNext) {
                                  currentSongIndex = currentSongIndex + 1;
                                  audioPlayer.seek(Duration.zero,
                                      index: currentSongIndex);
                                  // audioPlayer.seekToNext;
                                  setState(() {});
                                }
                              },
                              iconSize: 45,
                              icon: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                              ));
                        }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: IconButton(
                          onPressed: () => setState(() {
                                _showList = !_showList;
                              }),
                          iconSize: 30,
                          icon: const Icon(
                            Icons.list,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
                addSongList()
              ],
            ),
          ),
        ],
      ),
    );
  }

  addSongList() {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showList
            ? MediaQuery.removePadding(
            context: context,

                removeTop: true,
                child: SizedBox(
                  height: Get.height / 2 - 100,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.songsArray?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Transform.translate(
                              offset: const Offset(0, 3),
                              child: BodyLargeText(
                                (index + 1).toString(),
                               color: AppColorConstants.subHeadingTextColor,
                              )),
                          title: Transform.translate(
                              offset: const Offset(-30, 0),
                              child: BodyLargeText(
                                widget.songsArray?[index].name ?? '',
                                color: AppColorConstants.subHeadingTextColor,
                              )),
                          trailing: const Icon(Icons.favorite),

                          selected: true,
                          onTap: () {
                            currentSongIndex = index;
                            setState(() {});
                            audioPlayer.seek(Duration.zero,
                                index: currentSongIndex);
                          },
                        );
                      }),
                ))
            : null);
  }
}
