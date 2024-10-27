import 'dart:convert';
import 'dart:io';
import 'package:chat_application_flutter/components/Playlist.dart';
import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/components/photo_box.dart';
import 'package:chat_application_flutter/pages/playlist_viewer_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

List<Song> playlist = [];
List<Song> allSongs = [];
List<Song> displayedList = [];
File? fileName;

class SwipablePage extends StatefulWidget {
  const SwipablePage({super.key});

  @override
  State<SwipablePage> createState() => _SwipablePageState();
}

class _SwipablePageState extends State<SwipablePage> {
  @override
  Widget build(BuildContext context) {
    return SongsSelectionPage();
  }
}

class SongsSelectionPage extends StatefulWidget {
  final Playlist? playlist; // Accept an optional Playlist object

  const SongsSelectionPage({super.key, this.playlist});

  @override
  State<SongsSelectionPage> createState() => _SongsSelectionPageState();
}

class _SongsSelectionPageState extends State<SongsSelectionPage> {
  @override
  void initState() {
    super.initState();

    if (widget.playlist != null) {
      setState(() {
        playlist.clear();
        playlist.addAll(songsFromJson(widget.playlist!.playlistInJson));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).colorScheme.background,
        body: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('Songs').snapshots(),
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
              allSongs = songs;
              displayedList = songs;
        
              return TrackNameSearchBar();
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  label: Text('Отменить'),
                  backgroundColor: Colors.red,
                  icon: Icon(Icons.cancel),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.green,
                  heroTag: null,
                  onPressed: () {
                    if (playlist.isEmpty) {
                      Toast.show(
                          'Для продолжения выберите хотя-бы одну композицию из списка');
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistParametersPage(
                            playlist: widget.playlist,
                          ),
                        ),
                      );
                    }
                  },
                  label: Text('Далее'),
                  icon: Icon(Icons.done),shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistParametersPage extends StatefulWidget {
  final Playlist? playlist; // Accept an optional Playlist object

  const PlaylistParametersPage({super.key, this.playlist});

  @override
  State<PlaylistParametersPage> createState() => _PlaylistParametersPageState();
}

class _PlaylistParametersPageState extends State<PlaylistParametersPage> {
  File? _selectedFile;
  XFile? _fileName;
  TextEditingController playlistNameController = TextEditingController();
  TextEditingController playlistDescController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.playlist != null) {
      playlistNameController.text = widget.playlist!.playlistName;
      playlistDescController.text = widget.playlist!.playlistDescription;
      fileName = null; // обнуляем это дерьмо чтобы дать возможность заменить его
    }
  }

  Future<String> pushImageToStorage(XFile file) async {
    try {
      final path = 'playlistsLogo/${file.name}${DateTime.now()}';

      Reference storageRef = FirebaseStorage.instance.ref().child(path);

      UploadTask task = storageRef.putFile(File(file.path));

      TaskSnapshot taskSnapshot = await task.whenComplete(() => null);

      String url = await taskSnapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      Toast.show('Произошла ошибка при загрузке изображения');

      return 'error';
    }
  }

  Future<String> pushNewPlaylistToFirestore(Playlist playlist) async {
    try {
      if (playlist.playlistId != null) {
        // Update existing playlist

        await FirebaseFirestore.instance
            .collection('Playlist')
            .doc(playlist.playlistId)
            .update({
          'Description': playlist.playlistDescription,
          'Logo': playlist.playlistLogo,
          'Name': playlist.playlistName,
          'Playlist': playlist.playlistInJson,
        });

        Toast.show('Плейлист обновлен');
      } else {
        // Create new playlist

        await FirebaseFirestore.instance.collection('Playlist').add({
          'Description': playlist.playlistDescription,
          'Logo': playlist.playlistLogo,
          'Name': playlist.playlistName,
          'Playlist': playlist.playlistInJson,
        });

        Toast.show('Плейлист загружен');
      }

      return 'Success';
    } catch (e) {
      Toast.show('Ошибка при загрузке плейлиста');

      return 'error';
    }
  }

  selectImageFromGallery() async {
    final returnedimage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedimage == null) {
      return;
    } else {
      setState(() {
        _fileName = returnedimage;
        _selectedFile = File(returnedimage.path);
        fileName = _selectedFile!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return SafeArea(
      child: Scaffold(
        // ignore: deprecated_member_use
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Column(
          children: [
            Center(
              child: PhotoBox(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: GestureDetector(
                        onTap: () async {
                          await selectImageFromGallery();
                        },
                        child: _selectedFile == null && fileName == null
                            ? Image.network(
                                playlist[0].logo.toString(),
                              )
                            : Image.file(fileName!),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                          'В случае если вы не предоставите своё изображение, для плейлиста будет использовано изображение из первой композиции в списке.'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            TextField(
              controller: playlistNameController,
              decoration: InputDecoration(
                hintText: 'Введите название плейлиста',
                labelText: 'Название плейлиста',
                icon: Icon(Icons.short_text),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: playlistDescController,
              decoration: InputDecoration(
                hintText: 'Введите описание плейлиста',
                labelText: 'Описание плейлиста',
                icon: Icon(Icons.description),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: Text('Назад'),
                    icon: Icon(Icons.cancel),
                  backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      if (playlistNameController.text.isEmpty ||
                          playlistDescController.text.isEmpty) {
                        Toast.show('Введите название и описание плейлиста');
                        return;
                      }
                      String jsonPlaylist = songsToJson(playlist);
                      String logoUrl;
                      if (_fileName == null || widget.playlist != null) {
                        logoUrl = widget.playlist?.playlistLogo??playlist[0].logo.toString();
                      } else {
                        logoUrl = await pushImageToStorage(_fileName!);
                      }
                      Playlist newPlaylist = Playlist(
                        playlistName: playlistNameController.text,
                        playlistLogo: logoUrl,
                        playlistInJson: jsonPlaylist,
                        playlistDescription: playlistDescController.text,
                        playlistId: widget.playlist?.playlistId,
                      );
                      showDialog(
                        context: context,
                        builder: (context) =>
                            Center(child: CircularProgressIndicator()),
                      );
                      String result =
                          await pushNewPlaylistToFirestore(newPlaylist);
                  
                      Navigator.pop(context);
                      if (result == 'Success') {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => PlaylistView()),
                          (Route<dynamic> route) => false);
                      }
                    },
                    label: Text(
                        widget.playlist != null ? 'Обновить' : 'Сохранить'),
                    icon: Icon(Icons.done),
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
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
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        filterSongs();
      });
    });
  }

  void filterSongs() {
    String query = searchController.text.toLowerCase();
    displayedList = allSongs.where((song) {
      return song.name!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: SearchBar(
              controller: searchController,
              hintText: 'Hint: Search by name of the song',
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 70),
            shrinkWrap: true,
            itemCount: displayedList.length,
            itemBuilder: (context, index) {
              return MusicCard(
                song: displayedList[index],
              );
            },
          ),
        ),
      ],
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
  

  bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.11,
      width: MediaQuery.of(context).size.width * 0.3,
      child: Card(
        child: ListTile(
          leading: Image.network(widget.song.logo.toString()),
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
          onTap: () {},
        ),
      ),
    );
  }
}

// Utility functions to convert songs to and from JSON

String songsToJson(List<Song> songs) {
  List<Map<String, dynamic>> songsMap =
      songs.map((song) => song.toJson()).toList();

  return jsonEncode(songsMap);
}

List<Song> songsFromJson(String jsonString) {
  final List<dynamic> jsonData = jsonDecode(jsonString);

  return jsonData.map((item) => Song.fromJson(item)).toList();
}
