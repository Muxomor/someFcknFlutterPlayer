import 'package:chat_application_flutter/components/Song.dart';
import 'package:chat_application_flutter/pages/current_radio_page.dart';
import 'package:chat_application_flutter/pages/home_page.dart';
import 'package:chat_application_flutter/pages/playlist_viewer_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';


TextEditingController searchController = TextEditingController();
List<Song> allRadios = [];
List<Song> displayedList = [];
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
        title: const Text('Библиотека радиостанций'),
      ),
      drawer: MyDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Radio').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var radios = snapshot.data!.docs
                .map((doc) => Song(
                      name: doc['Genre'],
                      author: doc['Title'],
                      logo: doc['Logo'],
                      file: doc['RadioLink'],
                    ))
                .toList();
                displayedList = radios;
                allRadios = radios;
            return RadioNameSearchBar();
          }
        },
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
          List<Song> currentRadio = [widget.song];
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CurrentRadio(
                playlist: currentRadio,
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
              onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
                title: const Text(
                  'Радио',
                  style: TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.radio,
                  size: 20,
                ),
                onTap: () => {Navigator.of(context).pop()},),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: const Text(
                'Плейлисты',
                style: TextStyle(fontSize: 20),
              ),
              leading: const Icon(Icons.playlist_play),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PlaylistView())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Row(
                children: [
                  const Text(
                    'Сменить тему ',
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


class RadioNameSearchBar extends StatefulWidget {
  const RadioNameSearchBar({super.key});

  @override
  State<RadioNameSearchBar> createState() => RadioNameSearchBarState();
}

class RadioNameSearchBarState extends State<RadioNameSearchBar> {
  @override
  void initState() {
    super.initState();
    //listener for controller initializing
    searchController.addListener(() {
      if (mounted) {
        setState(() {
          filterSongs();
        });
      }
    });
  }

  //filtering
  void filterSongs() {
    String query = searchController.text.toLowerCase();
    displayedList = allRadios.where((song) {
      return song.name!.toLowerCase().contains(query);
    }).toList();
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
              hintText: 'Поиск по названию радиостанции',
            ),
          ),
        ),
        if (displayedList.isNotEmpty)
          Expanded(
            child: ListView.builder(
              //physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 70),
              shrinkWrap: true,
              itemCount: displayedList.length,
              itemBuilder: (context, index) {
                return MusicCard(
                  song: displayedList[index],
                );
              },
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text('Нет доступных радиостанций!'),
            ),
          ),
      ],
    );
  }
}
