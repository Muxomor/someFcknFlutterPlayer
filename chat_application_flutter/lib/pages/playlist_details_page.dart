import 'dart:convert';
import 'package:chat_application_flutter/components/Playlist.dart';
import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/pages/create_playlist_page.dart';
import 'package:chat_application_flutter/pages/current_song_page.dart';
import 'package:chat_application_flutter/pages/playlist_viewer_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

// factory Song.fromJson(Map<String, dynamic> json) {
//   return Song(
//     name: json['name'],
//     author: json['author'],
//     logo: json['logo'],
//   );
// }

class PlaylistDetailsPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailsPage> createState() => _PlaylistDetailsPageState();
}

class _PlaylistDetailsPageState extends State<PlaylistDetailsPage> {
  late List<Song> songs;

  @override
  void initState() {
    super.initState();

    // Десериализация списка песен из JSON-строки

    List<dynamic> jsonList =
        jsonDecode(widget.playlist.playlistInJson.toString());

    songs = jsonList.map((json) => Song.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Playlist Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.playlist.playlistLogo.toString(),
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.playlist.playlistName.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.playlist.playlistDescription.toString(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Songs:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return MusicCard(song: songs[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black54),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SongsSelectionPage(playlist: widget.playlist,)));
              },
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => SongPage(playlist: songs)),
                );
              },
              child: const Icon(Icons.play_arrow),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black54),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('Playlist')
                      .doc(widget.playlist.playlistId.toString())
                      .delete();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PlaylistView()));
                } catch (e) {
                  Toast.show(
                      'Произошла ошибка при удалении плейлиста. Проверьте поключение и/или попробуйте позже.$e');
                }
              },
            ),
          ],
        ),
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

  List<Song> playlist = [];

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
          onTap: () {
            // Логика при нажатии на элемент песни
          },
        ),
      ),
    );
  }
}
