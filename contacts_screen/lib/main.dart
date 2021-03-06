import 'dart:io';
import 'dart:developer' as dev;
import '/pages/contacts_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  if (!(Platform.isIOS || Platform.isAndroid)) {
    dev.log("This app is only intended for iOS and Android");
    exit(1);
  }
  // Locks app into portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'myContacts',
      home: ContactsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
