import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/pages/current_radio_page.dart';
import 'package:chat_application_flutter/pages/home_page.dart';
import 'package:chat_application_flutter/pages/new_song_page.dart';
import 'package:chat_application_flutter/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Radio(Ligma)'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Radio').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var songs = snapshot.data!.docs
                .map((doc) => Song(
                      name: doc['Genre'],
                      author: doc['Title'],
                      logo: doc['Logo'],
                      file: doc['RadioLink'],
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
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        child: const Icon(Icons.music_note),
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
        trailing: const Icon(Icons.play_arrow),
        onTap: () {
          List<Song> localSong = [widget.song];
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CurrentRadio(
                playlist: localSong,
              ),
            ),
          );
        },
      ),
    );
  }
}

