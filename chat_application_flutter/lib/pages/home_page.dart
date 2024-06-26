import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/pages/current_song_page.dart';
import 'package:chat_application_flutter/pages/new_song_page.dart';
import 'package:chat_application_flutter/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<Song> playlist = [];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Deez Nuts'),
        actions: [
          IconButton(
            onPressed: () async {
              //тут будет переход на страницу трека, но для этого надо сделать чтобы он принимал List<Song>
            },
            icon: Icon(
              Icons.play_circle_fill,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Songs').snapshots(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NewSongPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget musicCards(BuildContext context, Song song) {
  bool isChecked = false;
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
              author: song.author.toString(),
              logoLink: song.logo.toString(),
              musicLink: song.file.toString(),
              name: song.name.toString(),
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
    return Card(
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SongPage(
                author: widget.song.author.toString(),
                logoLink: widget.song.logo.toString(),
                musicLink: widget.song.file.toString(),
                name: widget.song.name.toString(),
              ),
            ),
          );
        },
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
              title: Row(
                children: [
                  const Text(
                    'ChangeTheme',
                    style: TextStyle(fontSize: 20),
                  ),
                  Switch(
                      value: Provider.of<ThemeProvider>(context, listen: false)
                          .isLightMode,
                      onChanged: ((value) =>
                          Provider.of<ThemeProvider>(context, listen: false)
                              .changeTheme()))
                ],
              ),
              leading: const Icon(
                Icons.brightness_6_outlined,
                size: 20,
              ),
              onTap: () => Provider.of<ThemeProvider>(context).changeTheme(),
            ),
          ),
        ],
      ),
    );
  }
}
