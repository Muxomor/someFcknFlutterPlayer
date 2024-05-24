import 'package:chat_application_flutter/components/photo_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

class SongPage extends StatefulWidget {
  //final dynamic song;
  final String author;
  final String name;
  final String logoLink;
  final String musicLink;
  const SongPage(
      {super.key,
      required this.author,
      required this.logoLink,
      required this.musicLink,
      required this.name});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final player = AudioPlayer();
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;
  
    Widget playPauseButton(
      ProcessingState processingState) {
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (processingState == ProcessingState.ready) {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: player.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () => player.seek(Duration.zero),
      );
    }
  }
  void setPlayerUrl() async{
await player.setUrl(widget.musicLink);
  }
  void startPlaying() async {
    //player.setVolume(1);
    //await player.stop();
    //await player.play(UrlSource(widget.musicLink));
    await player.setUrl(widget.musicLink);
    if(player.playing){
      await player.pause();
    }
    else{
    await player.play();
    }
    
    //notifyListeners();
  }

  void pause() async {
    //await player.pause();
    //notifyListeners();
  }

  void resume() async {
    //await player.resume();
    //notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    setPlayerUrl();
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 2, bottom: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_outlined),
                  ),
                  const Text('Player'),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
              PhotoBox(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        height: MediaQuery.of(context).size.height * 0.5,
                        widget.logoLink,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(widget.author),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('0:00'),
                            Icon(Icons.repeat),
                            Text('0:00')
                          ],
                        ),
                        Slider(
                          value: 0,
                          min: 0,
                          max: 100,
                          onChanged: (value) {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: GestureDetector(
                              onTap: () {},
                              child:
                                  const PhotoBox(child: Icon(Icons.replay_30)),
                            )),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                flex: 2,
                                child: PhotoBox(
                                  child: playPauseButton(player.processingState),
                                )),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {},
                              child:
                                  const PhotoBox(child: Icon(Icons.forward_30)),
                            ))
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
