import 'package:chat_application_flutter/components/Playlist.dart';
import 'package:chat_application_flutter/pages/create_playlist_page.dart';
import 'package:chat_application_flutter/pages/home_page.dart';
import 'package:chat_application_flutter/pages/playlist_details_page.dart';
import 'package:chat_application_flutter/pages/radios_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

TextEditingController searchController = TextEditingController();
List<Playlist> allPlaylists = [];
List<Playlist> displayedList = [];

class PlaylistView extends StatefulWidget {
  const PlaylistView({Key? key}) : super(key: key);

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Icon(Icons.playlist_add),onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SwipablePage()));
      },),
      appBar: AppBar(
        title: const Text('Playlists'),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('Playlist').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                var playlists = snapshot.data!.docs
                    .map((doc) => Playlist(
                          playlistName: doc['Name'],
                          playlistInJson: doc['Playlist'],
                          playlistLogo: doc['Logo'],
                          playlistDescription: doc['Description'],
                          playlistId: doc.id.toString()
                        ))
                    .toList();
                allPlaylists = playlists;
                displayedList = playlists;
                return TrackNameSearchBar();
              }
            },
          ),
        ],
      ),
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistCard({Key? key, required this.playlist, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  playlist.playlistLogo.toString(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                playlist.playlistName.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
  @override
  void initState() {
    super.initState();
    //listener for controller initializing
    searchController.addListener(() {
      if (mounted) {
        setState(() {
          filterPlaylists();
        });
      }
    });
  }

  //filtering
  void filterPlaylists() {
    String query = searchController.text.toLowerCase();
    displayedList = allPlaylists.where((playlist) {
      return playlist.playlistName!.toLowerCase().contains(query);
    }).toList();
  }

  // @override
  // void dispose() {
  //   searchController.removeListener((){});
  //   searchController.dispose(); //dispose for cleaning some shit
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: SearchBar(
              controller: searchController,
              hintText: 'Hint: Search by name of the playlist',
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Показывать 2 плейлиста в строке
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3 / 4, // Соотношение сторон для элемента
          ),
          itemCount: displayedList.length,
          itemBuilder: (context, index) {
            return PlaylistCard(
              playlist: displayedList[index],
              onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PlaylistDetailsPage(playlist: displayedList[index])));},
            );
          },
        ),
      ],
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
                onTap: () => {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false),
                    }),
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
                onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => RadioPage()),
                          (Route<dynamic> route) => false),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text(
                'Плейлисты',
                style: TextStyle(fontSize: 20),
              ),
              leading: const Icon(Icons.playlist_play),
              onTap: () => Navigator.pop(context),),
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
