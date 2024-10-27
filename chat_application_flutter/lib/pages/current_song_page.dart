import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/components/photo_box.dart';
import 'package:chat_application_flutter/pages/home_page.dart';
import 'package:chat_application_flutter/pages/playlist_manager.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toast/toast.dart';

class SongPage extends StatefulWidget {
  final List<Song> playlist;
  const SongPage({super.key, required this.playlist});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final player = AudioPlayer();
  bool isOnRepeat = false;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  @override
  void initState() {
    super.initState();
    List<AudioSource> sources = [];
    ConcatenatingAudioSource concatenatingPlaylist;
    // if (playlist.first == []) {
    //   final _playlist = ConcatenatingAudioSource(children: [
    //     AudioSource.uri(
    //       Uri.parse(widget.musicLink),
    //       tag: MediaItem(
    //         id: '1',
    //         title: widget.name,
    //         artist: widget.author,
    //         artUri: Uri.parse(widget.logoLink),
    //       ),
    //     )
    //   ]);
    // } else {
    //   //добавление в фоновый плейлист через цикл
    for (Song item in widget.playlist) {
      sources.add(
        AudioSource.uri(
          Uri.parse(item.file.toString()),
          tag: MediaItem(
            id: item.name.toString(),
            title: item.name.toString(),
            artist: item.author.toString(),
            artUri: Uri.parse(
              item.logo.toString(),
            ),
          ),
        ),
      );
    }
    //заполнение источников для фона из массива
    concatenatingPlaylist = ConcatenatingAudioSource(children: sources);
    // }
    //устанавливаем источник аудио
    player.setAudioSource(concatenatingPlaylist);
    player.load();
  }

  @override
  Widget build(BuildContext context) {
    //player.setLoopMode(LoopMode.all);
    ToastContext().init(context);
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 0, bottom: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      await player.stop();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_outlined),
                  ),
                  const Text('Плеер'),
                  IconButton(
                    onPressed: () {
                      if (playlist.length == 1) {
                        //TODO: придумай че сюда написать нормальное
                        Toast.show(
                            'There is no available songs in your playlist');
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlaylistControlPage(
                                playlist: widget.playlist, player: player),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
              //logo + artist name + track name
              PhotoBox(
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        if (state?.sequence.isEmpty ?? true) {
                          return const SizedBox();
                        }
                        final metadata = state!.currentSource!.tag as MediaItem;
                        return MediaMetadata(
                          logoLink: metadata.artUri.toString(),
                          name: metadata.title,
                          author: metadata.artist.toString(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        //instruments, repeat, shuffle, etc...
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (player.loopMode == LoopMode.all) {
                                  await player.setLoopMode(LoopMode.one);
                                  setState(() {
                                    isOnRepeat = !isOnRepeat;
                                  });
                                } else if (player.loopMode == LoopMode.one) {
                                  await player.setLoopMode(LoopMode.all);
                                  setState(() {
                                    isOnRepeat = !isOnRepeat;
                                  });
                                } else {
                                  await player.setLoopMode(LoopMode.all);
                                }
                              },
                              icon: !isOnRepeat
                                  ? const Icon(Icons.repeat)
                                  : const Icon(Icons.repeat_one),
                            ),
                          ],
                        ),
                        //progress bar for current track
                        StreamBuilder<PositionData>(
                          stream: _positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;
                            return ProgressBar(
                              progress: positionData?.position ?? Duration.zero,
                              buffered: positionData?.bufferedPosition ??
                                  Duration.zero,
                              total: positionData?.duration ?? Duration.zero,
                              onSeek: player.seek,
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              //seek -30
                              child: PhotoBox(
                                child: IconButton(
                                  icon: const Icon(Icons.replay_30),
                                  onPressed: () {
                                    player.seek(
                                      Duration(
                                          seconds:
                                              player.position.inSeconds - 30),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 2,
                              //play pause button
                              child: PhotoBox(
                                child: StreamBuilder<PlayerState>(
                                  stream: player.playerStateStream,
                                  builder: (context, snapshot) {
                                    final playerState = snapshot.data;
                                    final processtingState =
                                        playerState?.processingState;
                                    final playing = playerState?.playing;
                                    if (!(playing ?? false)) {
                                      return IconButton(
                                        onPressed: player.play,
                                        icon: const Icon(Icons.play_arrow),
                                      );
                                    } else if (processtingState !=
                                        ProcessingState.completed) {
                                      return IconButton(
                                        onPressed: player.pause,
                                        icon: const Icon(Icons.pause),
                                      );
                                    }
                                    return const Icon(Icons.play_arrow);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              //seek +30
                              child: PhotoBox(
                                child: IconButton(
                                  icon: const Icon(Icons.forward_30),
                                  onPressed: () async => {
                                    await player.seek(
                                      Duration(
                                          seconds:
                                              player.position.inSeconds + 30),
                                    ),
                                  },
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

//for progress bar(deez nuts)
class PositionData {
  const PositionData(this.position, this.bufferedPosition, this.duration);
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

//for current track name, author,logo
class MediaMetadata extends StatelessWidget {
  const MediaMetadata({
    super.key,
    required this.logoLink,
    required this.name,
    required this.author,
  });
  final String logoLink;
  final String name;
  final String author;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            height: MediaQuery.of(context).size.height * 0.4,
            logoLink,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //current track name
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  //current track author
                  Text(author),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
