import 'dart:io';
import '/theme/colors.dart';
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
  /// The profile picture used for the user's avatar image.
  File? _pfp;

  /// This represents the user's name and is displayed in [_myContactCard].
  String _myNameStr = "My Name";

  /// This represents the user's info and is displayed in [_myContactCard].
  String _myInfoStr = "My Info";

  /// List of the user's contacts.
  final List<Map> _contacts = [];

  /// [TextEditingController] for the text field used to enter the user's name
  ///  in the Update Info dialog.
  final _myNameContr = TextEditingController();

  /// [TextEditingController] for the text field used to enter the user's info
  ///  in the Update Info dialog.
  final _myInfoContr = TextEditingController();

  /// [TextEditingController] for the text field used to enter the user's name
  ///  search query in the search bar.
  final _searchBarContr = TextEditingController();

  /// Style used for the user's name.
  TextStyle get _myNameStyle => const TextStyle(fontSize: 25);

  /// Style used for the user's info.
  TextStyle get _myInfoStyle =>
      TextStyle(fontSize: 15, color: ColorsPlus.secondaryColor);

  /// Indicates the visibility of [_dialer].
  bool _isDialerShown = false;

  @override
  void initState() {
    super.initState();
    _getContacts();
    _getProfilePic();
    _getMyNameAndInfo();
    _searchBarContr.addListener(() {
      _filterSearchResults(_searchBarContr.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _myInfoContr.dispose();
    _myNameContr.dispose();
    _searchBarContr.dispose();
  }

  /// Fetches user's contacts.
  ///
  /// If the contacts permission has not been granted, the user will be
  /// asked for approval.
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
            "email":
                contact.emails.isNotEmpty ? contact.emails[0].address : "N/A"
          });
        }
      });
    }
  }

  /// Fetches user's profile picture from local storage.
  void _getProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('_pfp');
    setState(() {
      _pfp = File(value.toString());
    });
  }

  /// Fetches user's name and info from local storage.
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

  /// Returns a column with user's name and info.
  Column _myNameAndInfo() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        _myNameStr,
        style: _myNameStyle,
      ),
      const SizedBox(height: 7),
      Text(_myInfoStr, style: _myInfoStyle)
    ]);
  }

  /// Shows Update Info dialog, allowing a user to change their
  /// name, info, and photo.
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
            _myNameAndInfo(),
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
            _showToast("Please provide name and info");
          }
        },
        onCancelTap: () {},
        submitText: "Save",
        cancelText: "Cancel");
  }

  /// Card used to display a user's name, info, and photo.
  ///
  /// Must be tapped to show the Update Info dialog.
  SliverList _myContactCard() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          height: 100,
          child: Card(
            elevation: 5.0,
            shadowColor: ColorsPlus.secondaryColor,
            child: Row(
              children: [
                const SizedBox(width: 15),
                InkWell(
                    onTap: (() => _showUpdateInfoDialog()),
                    child: _avatar(radius: 25)),
                const SizedBox(width: 15),
                InkWell(
                    onTap: (() => _showUpdateInfoDialog()),
                    child: _myNameAndInfo()),
                const Spacer(),
                _isDialerShown
                    ? InkWell(
                        onTap: () {
                          setState((() => _isDialerShown = false));
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Icon(Icons.toggle_on,
                            color: ColorsPlus.secondaryColor))
                    : InkWell(
                        onTap: () {
                          setState((() => _isDialerShown = true));
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Icon(Icons.toggle_off,
                            color: ColorsPlus.secondaryColor)),
                const SizedBox(width: 26),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  /// Displays a dialer for easier number entry.
  ///
  /// Can be toggled via [_myContactCard].
  SliverList _dialer() {
    return SliverList(
        delegate: SliverChildListDelegate([
      const SizedBox(height: 15),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dialerButton("1"),
              const SizedBox(width: 35),
              _dialerButton("2"),
              const SizedBox(width: 35),
              _dialerButton("3")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dialerButton("4"),
              const SizedBox(width: 35),
              _dialerButton("5"),
              const SizedBox(width: 35),
              _dialerButton("6")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dialerButton("7"),
              const SizedBox(width: 35),
              _dialerButton("8"),
              const SizedBox(width: 35),
              _dialerButton("9")
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _makeCallBTN(
                  phoneNumber: _searchBarContr.text,
                  contact: _searchBarContr.text),
              const SizedBox(width: 35),
              _dialerButton("0"),
              const SizedBox(width: 35),
              _dialerBackSpace()
            ],
          ),
          const SizedBox(height: 15),
        ],
      )
    ]));
  }

  /// Card used for the user's contacts.
  InkWell _contactCard(Map contact) {
    ImageProvider<Object> imageProvider =
        const AssetImage('assets/place_holder.png');
    if (contact['photo'] != null) {
      imageProvider = MemoryImage(contact['photo']);
    }
    return InkWell(
      onTap: (() => DialogPlus.showDialogPlus(
          context: context,
          title: AutoSizeText.rich(DialogPlus.contactDialogTitle(contact)),
          content: Column(
            children: [
              _makeCallBTN(
                  phoneNumber: contact['phone'], contact: contact['name']),
              _createSmsBTN(phoneNumber: contact['phone']),
              _sendEmailBTN(emailAddress: contact['email'])
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

  /// A list of the user's contacts.
  ///
  /// The list is sorted alphabetically and is displayed in sections.
  ///
  /// Example: All contacts whose name begin with 'B' is under the 'B' section.
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

  /// Avatar used for contact cards.
  CircleAvatar _avatar({required double radius}) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: _pfp != null
          ? FileImage(_pfp!) as ImageProvider
          : const AssetImage('assets/place_holder.png'),
    );
  }

  /// Saves the user's name and info to local storage.
  void _saveMyNameAndInfo() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('myName', _myNameStr);
    prefs.setString('myInfo', _myInfoStr);
  }

  /// Allows the user to pick and save an image from gallery to be used as their
  /// profile picture.
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

  /// Filters [_contactList] based on the [query].
  ///
  /// Contacts can be filtered by name or phone number.
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

  /// Message displayed if a user's has searched for a contact and has no
  /// results.
  ///
  /// If there are no results displayed and the user's query is a
  /// number (between 7 - 11 in character length), buttons to call and SMS
  /// the number will appear.
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
            if (!_isDialerShown)
              _makeCallBTN(
                  phoneNumber: numToContact, contact: _searchBarContr.text),
            _createSmsBTN(phoneNumber: numToContact)
          ],
        )
    ]));
  }

  /// Button that allows a user to make a call to the [phoneNumber].
  ///
  /// If [noMatchingContact] is true, a dialog box will appear after a button
  /// press, allowing the user to confirm their decision to call
  /// an unknown number.
  ElevatedButton _makeCallBTN(
      {required String phoneNumber, required String contact}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          if (phoneNumber.isNotEmpty) {
            DialogPlus.showDialogPlus(
                content: AutoSizeText.rich(TextSpan(
                    text: 'Call ',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                          text: contact,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ColorsPlus.secondaryColor),
                          children: const [
                            TextSpan(
                              text: ' ?',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            )
                          ])
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
            _showToast("Phone # is empty");
          }
        },
        child: Icon(Icons.call, color: ColorsPlus.primaryColor));
  }

  /// Button that allows a user to make a SMS to the [phoneNumber].
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

  /// Button that allows a user to make a email to the [emailAddress].
  ElevatedButton _sendEmailBTN({required String emailAddress}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          Navigator.pop(context);
          _sendEmail(emailAddress);
        },
        child: Icon(Icons.email, color: ColorsPlus.primaryColor));
  }

  /// Button used in [_dialer]
  ElevatedButton _dialerButton(String text) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          _searchBarContr.text += text;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Text(text));
  }

  /// Backspace button used in [_dialer]
  ElevatedButton _dialerBackSpace() {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(ColorsPlus.secondaryColor)),
        onPressed: () {
          var str = _searchBarContr.text;
          if (str.isNotEmpty) {
            _searchBarContr.text = str.substring(0, str.length - 1);
          }
        },
        child: const Icon(Icons.backspace));
  }

  /// Calls [contactNumber]. This is a direct call and starts immediately.
  void _makeCall(String contactNumber) async {
    await FlutterPhoneDirectCaller.callNumber(contactNumber);
  }

  /// Launches the default SMS app, opening the conversation with
  /// [contactNumber].
  void _createSMS(String contactNumber) {
    launchUrlString('sms:$contactNumber');
  }

  /// Launches the default email app, opening the email to
  /// [emailAddress].
  ///
  /// If the contact's [emailAddress] is not found, a toast warning will be
  /// displayed.
  void _sendEmail(String emailAddress) {
    if (emailAddress != "N/A") {
      launchUrlString('mailto:$emailAddress');
    }
    _showToast("No email found for this contact");
  }

  /// Shows toast message to user.
  _showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
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
                  maxLines: 1,
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
                )),
            _myContactCard(),
            if (_isDialerShown) _dialer(),
            _contacts.isNotEmpty
                ? _contactList(_contacts)
                : _noMatchingContactsMSG(numToContact: _searchBarContr.text)
          ],
        ))));
  }
}
