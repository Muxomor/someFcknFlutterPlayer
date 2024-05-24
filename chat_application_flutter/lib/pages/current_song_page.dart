import 'package:chat_application_flutter/components/photo_box.dart';
import 'package:flutter/material.dart';
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
  bool isOnRepeat = false;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;
  void startPlaying() async {
    await player.setUrl(widget.musicLink);
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  void pause() async {
    await player.pause();
  }

  @override
  Widget build(BuildContext context) {
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
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('0:00'),
                            IconButton(onPressed: ()async {
                              if(player.loopMode==LoopMode.off)
                              {
                                await player.setLoopMode(LoopMode.one);
                                setState(() {
                                  isOnRepeat = true;
                                });
                              }else{
                                await player.setLoopMode(LoopMode.off);
                                setState(() {
                                  isOnRepeat =false;
                                });
                              }
                              
                            },icon: !isOnRepeat? const Icon(Icons.repeat):const Icon(Icons.repeat_one)),
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
                                child: PhotoBox(
                                    child: IconButton(
                              icon: const Icon(Icons.replay_30),
                              onPressed: () {
                                player.seek(currentDuration -=
                                    const Duration(seconds: 30));
                              },
                            ))),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                flex: 2,
                                child: PhotoBox(
                                  child: IconButton(
                                      onPressed: () => startPlaying(),
                                      icon: player.playing
                                          ? Icon(Icons.pause)
                                          : Icon(Icons.play_arrow)),
                                )),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: PhotoBox(
                                    child: IconButton(
                              icon: const Icon(Icons.forward_30),
                              onPressed: () => {
                                player.seek(currentDuration +=
                                    const Duration(seconds: 30))
                              },
                            )))
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
