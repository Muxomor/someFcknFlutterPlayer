import 'package:chat_application_flutter/pages/home_page.dart';
import 'package:chat_application_flutter/themes/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyAFk3EKtxrjQx3s6G84w6kUHU4_8t0s2fk',
        appId: '1:1096003489828:android:a39dc04891c2de82de88b1',
        messagingSenderId: '1096003489828',
        projectId: 'some-shitty-chat-app'),
  );

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:const HomePage(),
        theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
