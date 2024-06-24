import 'package:chat_application_flutter/pages/current_song_page.dart';
import 'package:chat_application_flutter/pages/new_song_page.dart';
import 'package:chat_application_flutter/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          icon:  Icon(
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
            var songs = snapshot.data!.docs.toList();
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return musicCards(context, songs[index]);
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

Widget musicCards(BuildContext context, dynamic docs) {
  return Card(
    child: ListTile(
      leading: Image.network(
        docs['Logo'],
      ),
      title: Text(docs['Name']),
      subtitle: Text(docs['Author']),
      trailing: const Icon(
        Icons.play_arrow,
        size: 20,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SongPage(
              author: docs['Author'],
              logoLink: docs['Logo'],
              musicLink: docs['File'],
              name: docs['Name'],
            ),
          ),
        );
      },
    ),
  );
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
