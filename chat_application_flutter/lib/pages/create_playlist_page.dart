import 'dart:io';

import 'package:chat_application_flutter/components/Song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

final List<Song> playlist = [];
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
  const SongsSelectionPage({super.key});

  @override
  State<SongsSelectionPage> createState() => _SongsSelectionPageState();
}

class _SongsSelectionPageState extends State<SongsSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Songs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  var songs = snapshot.data!.docs
                      .map(
                        (doc) => Song(
                          name: doc['Name'],
                          author: doc['Author'],
                          logo: doc['Logo'],
                          file: doc['File'],
                        ),
                      )
                      .toList();
                  allSongs = songs;
                  displayedList = songs;
                  return TrackNameSearchBar();
                }
              },
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: Text('Отменить'),
                    icon: Icon(Icons.cancel),
                  )),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (playlist.isEmpty) {
                      Toast.show(
                          'Для продолжения выберите хотя-бы одну композицию из списка');
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlaylistParametersPage(),
                        ),
                      );
                    }
                  },
                  label: Text('Далее'),
                  icon: Icon(Icons.done),
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
  const PlaylistParametersPage({super.key});

  @override
  State<PlaylistParametersPage> createState() => _PlaylistParametersPageState();
}

class _PlaylistParametersPageState extends State<PlaylistParametersPage> {
  File? _selectedFile;
  XFile? _fileName;
  TextEditingController playlistNameController = TextEditingController();
  TextEditingController playlistDescController = TextEditingController();

  selectImageFromGallery() async {
    final returnedimage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _fileName = returnedimage;
      _selectedFile = File(returnedimage!.path);
      fileName = _selectedFile!;
    });
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: GestureDetector(
                      onTap: () async {
                        await selectImageFromGallery();
                      },
                      child: _selectedFile == null && fileName==null
                          ? Image.network(
                              playlist[0].logo.toString(),
                            )
                          : Image.file(fileName!),
                    ),
                  ),
                  Text(
                      'В случае если вы не предоставите своё изображение, для плейлиста будет использовано изображение из первой композиции в списке.'),
                ],
              ),
            ),
            TextField(
              controller: playlistNameController,
              decoration: InputDecoration(
                  hintText: 'Введите название плейлиста',
                  labelText: 'Название плейлиста',
                  icon: Icon(Icons.short_text)),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
                controller: playlistDescController,
                decoration: InputDecoration(
                    hintText: 'Введите описание плейлиста',
                    labelText: 'Описание плейлиста',
                    icon: Icon(Icons.description))),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: Text('Назад'),
                    icon: Icon(Icons.cancel),
                  )),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PlaylistParametersPage()),
                      );
                    },
                    label: Text('Сохранить'),
                    icon: Icon(Icons.done),
                  )),
            ],
          ),
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
          onTap: () {},
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
    //listener for controller initializing
    searchController.addListener(() {
      setState(() {
        filterSongs();
      });
    });
  }

  //filtering
  void filterSongs() {
    String query = searchController.text.toLowerCase();
    displayedList = allSongs.where((song) {
      return song.name!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose(); //dispose for cleaning some shit
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
        ListView.builder(
          shrinkWrap: true,
          itemCount: displayedList.length,
          itemBuilder: (context, index) {
            return MusicCard(
              song: displayedList[index],
            );
          },
        ),
      ],
    );
  }
}
