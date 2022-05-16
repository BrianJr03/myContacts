import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  TextStyle get myNameStyle => const TextStyle(fontSize: 25);
  TextStyle get myInfoStyle => TextStyle(fontSize: 15, color: Colors.grey[600]);

  final List<Map> _contacts = [];
  final List<String> _contactNames = [];

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  SliverList get _myContactCard => SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            height: 100,
            child: Card(
              elevation: 5.0,
              shadowColor: const Color(0xff53a99a),
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/my_pfp.jpg'),
                  ),
                  const SizedBox(width: 15),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Brian Walker",
                          style: myNameStyle,
                        ),
                        const SizedBox(height: 7),
                        Text("Software Engineer", style: myInfoStyle)
                      ])
                ],
              ),
            ),
          ),
        ]),
      );

  SliverGroupedListView _contactList(List<dynamic> contactList) {
    return SliverGroupedListView<dynamic, String>(
      elements: contactList,
      groupBy: (contact) => contact['name'][0],
      groupComparator: (value1, value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) => item2['name'].compareTo(item1['name']),
      order: GroupedListOrder.DESC,
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: const Color(0xff53a99a),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (context, contact) {
        return Card(
          elevation: 5.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: const Icon(Icons.account_circle, size: 30),
            title: Text(contact['name'].toString().trim()),
            trailing: const Icon(Icons.call, color: Color(0xff53a99a)),
          ),
        );
      },
    );
  }

  void _getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(
          withPhoto: true, withProperties: true);
      setState(() {
        for (var contact in contacts) {
          _contactNames.add("${contact.name.first} ${contact.name.last}");
          _contacts.add({"name": "${contact.name.first} ${contact.name.last}"});
        }
      });
    }
  }

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<String> queriedNames = [];
      for (var name in _contactNames) {
        if (name.toLowerCase().startsWith(query.toLowerCase())) {
          queriedNames.add(name);
        }
      }
      setState(() {
        _contacts.clear();
        for (var name in queriedNames) {
          _contacts.add({"name": name});
        }
      });
      return;
    } else {
      setState(() {
        _contacts.clear();
        _contactNames.clear();
        _getContacts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Center(
              child: CustomScrollView(
        slivers: [
          SliverAppBar(
              backgroundColor: const Color(0xff53a99a),
              floating: true,
              leading: const Icon(Icons.contacts),
              title: TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search Contacts",
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: Icon(Icons.search, color: Colors.white),
                ),
                onChanged: (value) {
                  _filterSearchResults(value);
                },
              )),
          _myContactCard,
          _contactList(_contacts)
        ],
      ))),
    );
  }
}
