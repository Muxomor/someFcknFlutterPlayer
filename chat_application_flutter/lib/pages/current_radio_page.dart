import 'package:audio_service/audio_service.dart';
import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/components/photo_box.dart';
import 'package:chat_application_flutter/pages/current_song_page.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CurrentRadio extends StatefulWidget {
  final List<Song> playlist;
  
  const CurrentRadio({super.key, required this.playlist});

  @override
  State<CurrentRadio> createState() => _CurrentRadioState();
}


class _CurrentRadioState extends State<CurrentRadio> {
  final player = AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     List<AudioSource> sources = [];
     var _playlist;
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
      _playlist = ConcatenatingAudioSource(children: sources);
    // }
    //устанавливаем источник аудио
    player.setAudioSource(_playlist);

    
  }
  
  @override
  Widget build(BuildContext context) {
    player.setLoopMode(LoopMode.one);
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 0, bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      player.stop();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_outlined),
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
                          name:"Радиостанция: "+ metadata.title,
                          author: "Жанр: "+ metadata.artist.toString(),
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
                        Center(
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
                                      iconSize: 100,
                                    );
                                  } else if (processtingState !=
                                      ProcessingState.completed) {
                                    return IconButton(
                                      onPressed: player.pause,
                                      icon: const Icon(Icons.pause),
                                      iconSize: 100,
                                    );
                                  }
                                  return const Icon(Icons.play_arrow);
                                }),
                          ),
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