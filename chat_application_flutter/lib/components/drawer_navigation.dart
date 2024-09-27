import 'package:chat_application_flutter/pages/radios_page.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});
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
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/songHomePage') {
                  Navigator.of(context).popAndPushNamed('/songHomePage');
                } else {
                  Navigator.of(context).pop();
                }
              },
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
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/radioHomePage') {
                  Navigator.of(context).popAndPushNamed('/radioHomePage');
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
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
                  ),
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
