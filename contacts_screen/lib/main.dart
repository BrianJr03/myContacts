import 'dart:io';

import 'pages/contacts_page/contacts_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;

void main() {
  if (Platform.isIOS || Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
    runApp(const MyApp());
  } else {
    dev.log("This app is only intended for iOS and Android");
    exit(1);
  }
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
