import '/theme/colors.dart';
import '/util/dialog.dart/dialog.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  TextStyle get _myNameStyle => const TextStyle(fontSize: 25);
  TextStyle get _myInfoStyle =>
      TextStyle(fontSize: 15, color: ColorsPlus.secondaryColor);
  final List<Map> _contacts = [];
  final _searchBarContr = TextEditingController();
  final _myNameContr = TextEditingController();
  final _myInfoContr = TextEditingController();

  String _myNameStr = "My Name";
  String _myInfoStr = "My Info";

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  @override
  void dispose() {
    super.dispose();
    _myInfoContr.dispose();
    _myNameContr.dispose();
    _searchBarContr.dispose();
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
            "phoneNorm": contact.phones[0].normalizedNumber,
          });
        }
      });
    }
  }

  CircleAvatar _avatar({required double radius}) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: const AssetImage('assets/my_pfp.jpg'),
    );
  }

  Column _myInfo() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        _myNameStr,
        style: _myNameStyle,
      ),
      const SizedBox(height: 7),
      Text(_myInfoStr, style: _myInfoStyle)
    ]);
  }

  SliverList _myContactCard() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          height: 100,
          child: InkWell(
            onTap: () {
              DialogPlus.showDialogPlus(
                  context: context,
                  title: const Text("Update Info"),
                  content: Column(
                    children: [
                      _avatar(radius: 70),
                      const SizedBox(height: 20),
                      _myInfo(),
                      const SizedBox(height: 20),
                      DialogPlus.dialogTextField(
                        hintText: "Edit name",
                        contr: _myNameContr,
                      ),
                      const SizedBox(height: 5),
                      DialogPlus.dialogTextField(
                        hintText: "Edit info",
                        contr: _myInfoContr,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  ColorsPlus.secondaryColor)),
                          child: const Text("Change Photo"))
                    ],
                  ),
                  onSubmitTap: () {
                    if (_myNameContr.text.isNotEmpty &&
                        _myInfoContr.text.isNotEmpty) {
                      setState(() {
                        _myNameStr = _myNameContr.text.trim();
                        _myInfoStr = _myInfoContr.text.trim();
                      });
                    } else {
                      Fluttertoast.showToast(
                          msg: "Please provide name and info",
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1,
                          backgroundColor: ColorsPlus.secondaryColor,
                          textColor: ColorsPlus.primaryColor,
                          fontSize: 16.0);
                    }
                  },
                  onCancelTap: () {},
                  submitText: "Save",
                  cancelText: "Cancel");
            },
            child: Card(
              elevation: 5.0,
              shadowColor: ColorsPlus.secondaryColor,
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  _avatar(radius: 25),
                  const SizedBox(width: 15),
                  _myInfo(),
                  const Spacer(),
                  Icon(Icons.edit, color: ColorsPlus.secondaryColor),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  InkWell _contactCard(Map contact) {
    ImageProvider<Object> imageProvider =
        const AssetImage('assets/place_holder.png');
    if (contact['photo'] != null) {
      imageProvider = MemoryImage(contact['photo']);
    }
    return InkWell(
      onTap: (() => DialogPlus.showDialogPlus(
          context: context,
          title: AutoSizeText.rich(DialogPlus.contactMethodText(contact)),
          content: Column(
            children: [
              _makeCallBTN(phoneNumber: contact['phone']),
              _createSmsBTN(phoneNumber: contact['phone'])
            ],
          ),
          onSubmitTap: () {},
          onCancelTap: null,
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

  SliverGroupedListView _contactList(List<Map> contactList) {
    return SliverGroupedListView<dynamic, String>(
      elements: contactList,
      groupBy: (contact) => contact['name'][0],
      groupComparator: (value1, value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) => item2['name'].compareTo(item1['name']),
      order: GroupedListOrder.DESC,
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: ColorsPlus.secondaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorsPlus.primaryColor),
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
        if (contact['name'].toLowerCase().contains(query.toLowerCase())) {
          queriedContacts.add(contact);
        } else if (contact['phoneNorm'].toString().contains(query)) {
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
            "phoneNorm": contact['phoneNorm'],
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

  SliverList _noMatchingContactsMSG({required String numToContact}) {
    return SliverList(
        delegate: SliverChildListDelegate([
      const SizedBox(height: 10),
      const Center(
          child: Text("No contacts to show.", style: TextStyle(fontSize: 20))),
      const SizedBox(height: 10),
      if (int.tryParse(numToContact) != null &&
          numToContact.length >= 7 &&
          numToContact.length <= 11)
        Column(
          children: [
            _makeCallBTN(phoneNumber: numToContact, noMatchingContact: true),
            _createSmsBTN(phoneNumber: numToContact)
          ],
        )
    ]));
  }

  String _formatPhoneNumber(String phoneNumber) {
    String formattedPhoneNumber = "";
    if (phoneNumber.length == 11) {
      formattedPhoneNumber =
          // ignore: prefer_adjacent_string_concatenation
          "\n+${phoneNumber.substring(0, 1)} (${phoneNumber.substring(1, 4)}) " +
              "${phoneNumber.substring(4, 7)} - ${phoneNumber.substring(7, phoneNumber.length)}";
    } else if (phoneNumber.length >= 10) {
      // ignore: prefer_adjacent_string_concatenation
      formattedPhoneNumber = "\n(${phoneNumber.substring(0, 3)}) " +
          "${phoneNumber.substring(3, 6)} - ${phoneNumber.substring(6, phoneNumber.length)}";
    } else {
      formattedPhoneNumber =
          "${phoneNumber.substring(0, 3)} - ${phoneNumber.substring(3, phoneNumber.length)}";
    }
    return formattedPhoneNumber;
  }

  ElevatedButton _makeCallBTN(
      {required String phoneNumber, bool noMatchingContact = false}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          if (noMatchingContact) {
            DialogPlus.showDialogPlus(
                content: AutoSizeText.rich(TextSpan(
                    text: 'This will call ',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                          text: _formatPhoneNumber(phoneNumber),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorsPlus.secondaryColor))
                    ])),
                context: context,
                onCancelTap: () {},
                onSubmitTap: () => _makeCall(phoneNumber),
                cancelText: 'Back',
                submitText: 'Call',
                title: const Text("Make Call"));
          } else {
            _makeCall(phoneNumber);
          }
        },
        child: Icon(Icons.call, color: ColorsPlus.primaryColor));
  }

  ElevatedButton _createSmsBTN({required String phoneNumber}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          _createSMS(phoneNumber);
        },
        child: Icon(Icons.sms, color: ColorsPlus.primaryColor));
  }

  void _makeCall(String contactNumber) async {
    await FlutterPhoneDirectCaller.callNumber(contactNumber);
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
                child: CustomScrollView(
          slivers: [
            SliverAppBar(
                backgroundColor: ColorsPlus.secondaryColor,
                floating: true,
                leading: InkWell(
                    onTap: () => setState(() {
                          _searchBarContr.clear();
                          _contacts.clear();
                          _getContacts();
                          FocusManager.instance.primaryFocus?.unfocus();
                        }),
                    child: const Icon(Icons.contacts)),
                title: TextField(
                  controller: _searchBarContr,
                  style: TextStyle(color: ColorsPlus.primaryColor),
                  cursorColor: ColorsPlus.primaryColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Contacts | Phone #",
                    hintStyle: TextStyle(color: ColorsPlus.primaryColor),
                    suffixIcon:
                        Icon(Icons.search, color: ColorsPlus.primaryColor),
                  ),
                  onChanged: (value) {
                    _filterSearchResults(value);
                  },
                )),
            _myContactCard(),
            _contacts.isNotEmpty
                ? _contactList(_contacts)
                : _noMatchingContactsMSG(numToContact: _searchBarContr.text)
          ],
        ))));
  }
}
