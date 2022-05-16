import 'package:flutter/material.dart';
import 'package:contacts_screen/pages/contacts_page/contacts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myContacts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
