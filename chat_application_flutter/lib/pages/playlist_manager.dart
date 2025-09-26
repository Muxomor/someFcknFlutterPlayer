import 'package:chat_application_flutter/components/Song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

var currentSongTitleNotifier = ValueNotifier<String>('');
final playlistNotifier = ValueNotifier<List<String>>([]);

class PlaylistControlPage extends StatefulWidget {
  final List<Song> playlist;
  final AudioPlayer player;
  const PlaylistControlPage(
      {super.key, required this.playlist, required this.player});

  @override
  State<PlaylistControlPage> createState() => _PlaylistControlPageState();
}

class _PlaylistControlPageState extends State<PlaylistControlPage> {
  @override
  void initState() {
    //листенер для плеера при инициализации
    _listenForChangesInSequenceState(widget.player);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  //выход с форму, асинхронность сам не знаю зачем
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_outlined),
                ),
                Text('Менеджер очереди плейлиста'),
              ],
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.playlist.length,
                itemBuilder: (context, index) {
                  //обернуто в InheritedWidget для получения AudioPlayer в MusicCard
                  return CurrentAudioPlayer(
                    player: widget.player,
                    child: MusicCard(
                      song: widget.playlist[index],
                      index: index,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MusicCard extends StatefulWidget {
  final Song song;
  final int index;
  const MusicCard({super.key, required this.song, required this.index});

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  @override
  Widget build(BuildContext context) {
    //лютейший виджет, слушает поток, гениальное решение от команды разработчиков фреймворка
    return ValueListenableBuilder<String>(
      valueListenable: currentSongTitleNotifier,
      builder: (context, value, __) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.11,
          width: MediaQuery.of(context).size.width * 0.3,
          child: Opacity(
            // ignore: unrelated_type_equality_checks
            opacity: widget.song.name == currentSongTitleNotifier ? 0.5 : 1,
            child: Card(
              child: ListTile(
                enabled: currentSongTitleNotifier.value == widget.song.name
                    ? false
                    : true,
                leading: Image.network(
                  widget.song.logo.toString(),
                ),
                title: Text(widget.song.name.toString()),
                subtitle: Text(widget.song.author.toString()),
                onTap: () {
                  CurrentAudioPlayer.of(context)
                      ?.player
                      .seek(Duration.zero, index: widget.index);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

//current source title listener
void _listenForChangesInSequenceState(AudioPlayer player) {
  player.sequenceStateStream.listen((sequenceState) {
    if (sequenceState == null) return;

    // update current song title
    final currentItem = sequenceState.currentSource?.tag as MediaItem;
    final title = currentItem.title;
    currentSongTitleNotifier.value = title;
  },);
}

//доступ к плееру
class CurrentAudioPlayer extends InheritedWidget {
  final AudioPlayer player;

  const CurrentAudioPlayer({
    super.key,
    required this.player,
    required super.child,
  });

  static CurrentAudioPlayer? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CurrentAudioPlayer>();
  }

  @override
  bool updateShouldNotify(CurrentAudioPlayer oldWidget) => false;
}
