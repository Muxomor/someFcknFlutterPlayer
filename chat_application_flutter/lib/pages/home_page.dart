import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/components/drawer_navigation.dart';
import 'package:chat_application_flutter/pages/current_song_page.dart';
import 'package:chat_application_flutter/pages/radios_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';


List<Song> playlist = [];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
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
              if (playlist.isEmpty) {
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
      drawer: const CustomDrawer(),
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
            MaterialPageRoute(builder: (context) => const RadioPage()),
          );
        },
        child: const Icon(Icons.radio),
      ),
    );
  }
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
    );
  }
}
