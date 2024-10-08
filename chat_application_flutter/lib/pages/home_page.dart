import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/pages/current_song_page.dart';
import 'package:chat_application_flutter/pages/radios_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:toast/toast.dart';

List<Song> playlist = [];
TextEditingController searchController = TextEditingController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Deez Nuts'),
        //TODO: implements search bar you fucking moron
        actions: [
          IconButton(
            onPressed: () async {
              if (playlist.length == 0) {
                Toast.show(
                    'Для начала работы выберите один или более треков из треклиста');
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SongPage(
                      playlist: playlist,
                    ),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.play_circle_fill,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          TrackNameSearchBar(),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Songs').where('Name', arrayContains: searchController.text)
      .orderBy('Name').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                var songs = snapshot.data!.docs
                    .map((doc) => Song(
                          name: doc['Name'],
                          author: doc['Author'],
                          logo: doc['Logo'],
                          file: doc['File'],
                        ))
                    .toList();
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return MusicCard(
                      song: songs[index],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const RadioPage()),
          );
        },
        child: const Icon(Icons.radio),
      ),
    );
  }
}

Widget musicCards(BuildContext context, Song song) {
  return Card(
    child: ListTile(
      leading: Image.network(
        song.logo.toString(),
      ),
      title: Text(song.name.toString()),
      subtitle: Text(song.author.toString()),
      trailing: const Icon(
        Icons.play_arrow,
        size: 20,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SongPage(
              playlist: [
                Song(
                    author: song.author,
                    file: song.file,
                    logo: song.logo,
                    name: song.name)
              ],
            ),
          ),
        );
      },
    ),
  );
}

class MusicCard extends StatefulWidget {
  final Song song;
  const MusicCard({super.key, required this.song});

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  bool? isChecked = true;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.11,
      width: MediaQuery.of(context).size.width * 0.3,
      child: Card(
        child: ListTile(
          leading: Image.network(
            widget.song.logo.toString(),
          ),
          title: Text(widget.song.name.toString()),
          subtitle: Text(widget.song.author.toString()),
          trailing: Checkbox(
              value: playlist.contains(widget.song),
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value;
                });
                if (value!) {
                  playlist.add(widget.song);
                } else {
                  playlist.remove(widget.song);
                }
              }),
          onTap: () {
            List<Song> localSong = [widget.song];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SongPage(
                  playlist: localSong,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          DrawerHeader(
              child: Center(
            child: Icon(
              Icons.music_note_outlined,
              size: 50,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 20),
              ),
              leading: const Icon(
                Icons.home,
                size: 20,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
                title: const Text(
                  'Radio',
                  style: TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.radio,
                  size: 20,
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RadioPage()))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Row(
                children: [
                  const Text(
                    'Change theme',
                    style: TextStyle(fontSize: 20),
                  ),
                  Switch(
                    value: ThemeProvider.controllerOf(context).currentThemeId ==
                            'dark'
                        ? true
                        : false,
                    onChanged: ((value) =>
                        ThemeProvider.controllerOf(context).nextTheme()),
                  )
                ],
              ),
              leading: const Icon(
                Icons.brightness_6_outlined,
                size: 20,
              ),
              onTap: () => ThemeProvider.controllerOf(context).nextTheme(),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackNameSearchBar extends StatefulWidget {
  const TrackNameSearchBar({super.key});

  @override
  State<TrackNameSearchBar> createState() => TrackNameSearchBarState();
}

class TrackNameSearchBarState extends State<TrackNameSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.09,
        width: MediaQuery.of(context).size.width * 0.86,
        child: SearchBar(
          //controller: searchController,
          onChanged: (value) {
            setState(() {
              searchController.text = value;
            });
          },
          hintText: 'Hint: Search by name of the song',
        ),
      ),
    );
  }
}
