import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '/util/contact_onclick_dialog/contact_onclick_dialog.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  TextStyle get _myNameStyle => const TextStyle(fontSize: 25);
  TextStyle get _myInfoStyle =>
      TextStyle(fontSize: 15, color: Colors.grey[600]);

  final List<Map> _contacts = [];

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  void _getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(
          withPhoto: true, withProperties: true);
      setState(() {
        for (var contact in contacts) {
          _contacts.add({
            "name": "${contact.name.first} ${contact.name.last}",
            "photo": contact.photoOrThumbnail,
            "phone": contact.phones[0].number,
          });
        }
      });
    }
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
                          style: _myNameStyle,
                        ),
                        const SizedBox(height: 7),
                        Text("Software Engineer", style: _myInfoStyle)
                      ])
                ],
              ),
            ),
          ),
        ]),
      );

  InkWell _contactCard(Map contact) {
    ImageProvider<Object> imageProvider =
        const AssetImage('assets/place_holder.png');
    if (contact['photo'] != null) {
      imageProvider = MemoryImage(contact['photo']);
    }
    return InkWell(
      onTap: (() => ConfirmationDialog.showConfirmationDialog(
          context: context,
          title: AutoSizeText.rich(ConfirmationDialog.dialogTitleText(contact)),
          content: Column(
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff53a99a))),
                  onPressed: () => _makeCall(contact['phone']),
                  child: const Icon(Icons.call, color: Colors.white)),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff53a99a))),
                  onPressed: () => _createSMS(contact['phone']),
                  child: const Icon(Icons.sms, color: Colors.white))
            ],
          ),
          onSubmitTap: () => Navigator.pop(context),
          onCancelTap: () => Navigator.pop(context),
          submitText: 'Back',
          cancelText: '')),
      child: Card(
        elevation: 5.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: CircleAvatar(
            radius: 15,
            backgroundImage: imageProvider,
          ),
          title: Text(contact['name'].toString().trim()),
          trailing: const Icon(Icons.contact_phone, color: Color(0xff53a99a)),
        ),
      ),
    );
  }

  SliverList get _noImportedContactsMSG => SliverList(
          delegate: SliverChildListDelegate([
        const SizedBox(height: 10),
        const Center(
            child: Text("No contacts have been imported.",
                style: TextStyle(fontSize: 20)))
      ]));

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
        return _contactCard(contact);
      },
    );
  }

  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<Map> queriedContacts = [];
      for (var contact in _contacts) {
        if (contact['name'].toLowerCase().startsWith(query.toLowerCase())) {
          queriedContacts.add(contact);
        }
      }
      setState(() {
        _contacts.clear();
        for (var contact in queriedContacts) {
          _contacts.add({
            "name": contact['name'],
            "photo": contact['photo'],
            "phone": contact['phone'],
          });
        }
      });
      return;
    } else {
      setState(() {
        _contacts.clear();
        _getContacts();
      });
    }
  }

  void _makeCall(String contactNumber) {
    launchUrlString("tel://$contactNumber");
  }

  void _createSMS(String contactNumber) {
    launchUrlString('sms:$contactNumber');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Center(
              child: _contacts.isNotEmpty
                  ? CustomScrollView(
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
                                suffixIcon:
                                    Icon(Icons.search, color: Colors.white),
                              ),
                              onChanged: (value) {
                                _filterSearchResults(value);
                              },
                            )),
                        _myContactCard,
                        _contacts.isNotEmpty
                            ? _contactList(_contacts)
                            : _noImportedContactsMSG
                      ],
                    )
                  : const CircularProgressIndicator())),
    );
  }
}
