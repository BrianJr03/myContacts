import 'dart:io';
import '/theme/colors.dart';
import '/util/format/format.dart';
import '/util/dialog.dart/dialog.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  File? _pfp;

  String _myNameStr = "My Name";
  String _myInfoStr = "My Info";

  final List<Map> _contacts = [];

  final _myNameContr = TextEditingController();
  final _myInfoContr = TextEditingController();
  final _searchBarContr = TextEditingController();

  TextStyle get _myNameStyle => const TextStyle(fontSize: 25);
  TextStyle get _myInfoStyle =>
      TextStyle(fontSize: 15, color: ColorsPlus.secondaryColor);

  @override
  void initState() {
    super.initState();
    _getContacts();
    _getProfilePic();
    _getMyNameAndInfo();
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
            "email": contact.emails.isNotEmpty ? contact.emails[0].address : "N/A"
          });
        }
      });
    }
  }

  void _getProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('_pfp');
    setState(() {
      _pfp = File(value.toString());
    });
  }

  void _getMyNameAndInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _myNameStr = prefs.getString('myName') != null
        ? prefs.getString('myName')!
        : "My Name";
    _myInfoStr = prefs.getString('myInfo') != null
        ? prefs.getString('myInfo')!
        : "My Info";
    _myNameContr.text = _myNameStr;
    _myInfoContr.text = _myInfoStr;
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

  void _showUpdateInfoDialog() {
    DialogPlus.showDialogPlus(
        context: context,
        title: const Text("Update Info"),
        content: Column(
          children: [
            InkWell(
                onTap: (() {
                  Navigator.pop(context);
                  _setProfilePic();
                }),
                child: _avatar(radius: 70)),
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
                onPressed: () {
                  Navigator.pop(context);
                  _setProfilePic();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(ColorsPlus.secondaryColor)),
                child: const Text("Change Photo"))
          ],
        ),
        onSubmitTap: () {
          if (_myNameContr.text.isNotEmpty && _myInfoContr.text.isNotEmpty) {
            setState(() {
              _myNameStr = _myNameContr.text.trim();
              _myInfoStr = _myInfoContr.text.trim();
            });
            _saveMyNameAndInfo();
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
  }

  SliverList _myContactCard() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          height: 100,
          child: InkWell(
            onTap: () {
              _showUpdateInfoDialog();
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
              _createSmsBTN(phoneNumber: contact['phone']),
              _sendEmailBTN(email: contact['email'])
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

  CircleAvatar _avatar({required double radius}) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: _pfp != null
          ? FileImage(_pfp!) as ImageProvider
          : const AssetImage('assets/place_holder.png'),
    );
  }

  void _saveMyNameAndInfo() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('myName', _myNameStr);
    prefs.setString('myInfo', _myInfoStr);
  }

  Future _setProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final profileImagePicker =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    final dir = await getApplicationDocumentsDirectory();
    await File(profileImagePicker!.path).copy('${dir.path}/image.png');
    prefs.setString('_pfp', '${dir.path}/image.png');
    setState(() {
      _pfp = File(profileImagePicker.path);
    });
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
            "email": contact['email']
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
                          text: FormatPlus.formatPhoneNumber(phoneNumber),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorsPlus.secondaryColor))
                    ])),
                context: context,
                onCancelTap: () {},
                onSubmitTap: () {
                  Navigator.pop(context);
                  _makeCall(phoneNumber);
                },
                cancelText: 'Back',
                submitText: 'Call',
                title: const Text("Make Call"));
          } else {
            Navigator.pop(context);
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
          Navigator.pop(context);
          _createSMS(phoneNumber);
        },
        child: Icon(Icons.sms, color: ColorsPlus.primaryColor));
  }

  ElevatedButton _sendEmailBTN({required String email}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          Navigator.pop(context);
          _sendEmail(email);
        },
        child: Icon(Icons.email, color: ColorsPlus.primaryColor));
  }

  void _makeCall(String contactNumber) async {
    await FlutterPhoneDirectCaller.callNumber(contactNumber);
  }

  void _createSMS(String contactNumber) {
    launchUrlString('sms:$contactNumber');
  }

  void _sendEmail(String email) {
    if (email != "N/A") {
      launchUrlString('mailto:$email');
    }
    Fluttertoast.showToast(
        msg: "No email found for this contact",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: ColorsPlus.secondaryColor,
        textColor: ColorsPlus.primaryColor,
        fontSize: 16.0);
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
