import 'dart:io';
import 'package:flutter/rendering.dart';

import '/util/toast.dart';
import '/util/dialer.dart';
import '/util/dialog.dart';
import '../theme/colors_plus.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Contact> myContacts = [];

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

  /// Indicates the visibility of dialerPad.
  bool _isDialerShown = false;

  /// Indicates if the user has toggled their theme.
  bool isThemeChanged = false;

  /// Indicates if the FAB is visible.
  bool isFabVisible = true;

  /// Represents the current theme color.
  String theme = "blue";

  @override
  void initState() {
    super.initState();
    _getContacts();
    _getProfilePic();
    _getMyNameAndInfo();
    _setSavedTheme();
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
      setState(() async {
        myContacts = await FlutterContacts.getContacts(
          withPhoto: true, withProperties: true);
      });
    }
  }

  /// Fetches user's profile picture from local storage.
  void _getProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('_pfp');
    if (value != null) {
      setState(() {
        _pfp = File(value.toString());
      });
    }
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
            ToastedPlus.showToast("Please provide name and info");
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

  /// Card used for the user's contacts.
  InkWell _contactCard(Contact contact) {
    ImageProvider<Object> imageProvider =
        const AssetImage('assets/place_holder.png');
    if (contact.photoOrThumbnail != null) {
      imageProvider = MemoryImage(contact.photoOrThumbnail!);
    }
    return InkWell(
      onLongPress: () => DialogPlus.showDialogPlus(
          context: context,
          title: const Text("Delete Contact"),
          content: AutoSizeText.rich(TextSpan(
              text: 'Are you sure you want to delete',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                    text: "${contact.name.first} ${contact.name.last}",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorsPlus.secondaryColor),
                    children: const [
                      TextSpan(
                          text: "?",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black))
                    ]),
              ])),
          onSubmitTap: () async {
            await contact.delete();
            setState(() {
              myContacts.clear();
              _getContacts();
            });
          },
          onCancelTap: () {},
          submitText: "Delete",
          cancelText: "Back"),
      onTap: (() => DialogPlus.showDialogPlus(
          context: context,
          title: AutoSizeText.rich(DialogPlus.contactDialogTitle(contact)),
          content: Column(
            children: [
              DialerPlus.makeCallBTN(
                  context: context,
                  phoneNumber: contact.phones[0].number,
                  contact: "${contact.name.first} ${contact.name.last}"),
              DialerPlus.createSmsBTN(
                  context: context, phoneNumber: contact.phones[0].number),
              DialerPlus.sendEmailBTN(
                  context: context,
                  emailAddress: contact.emails.isNotEmpty
                      ? contact.emails[0].address
                      : "N/A"),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(ColorsPlus.secondaryColor)),
                  onPressed: () async {
                    Navigator.pop(context);
                    var result =
                        await FlutterContacts.openExternalEdit(contact.id);
                    if (result != null) {
                      setState(() {
                        myContacts.clear();
                        _getContacts();
                      });
                    }
                  },
                  child: const Icon(Icons.edit))
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
          title:
              Text("${contact.name.first.trim()} ${contact.name.last.trim()}"),
          trailing: Icon(Icons.contact_phone, color: ColorsPlus.secondaryColor),
        ),
      ),
    );
  }

  /// A list of the user's contacts.
  ///
  /// The list is sorted alphabetically and is displayed in sections.
  ///
  /// Example: All contacts whose name begin with 'B' is under the 'B' section.
  SliverGroupedListView _contactList(List<Contact> contactList) {
    return SliverGroupedListView<dynamic, String>(
      elements: contactList,
      groupBy: (contact) => contact.name.first.toString()[0],
      groupComparator: (value1, value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) =>
          item2.name.toString().compareTo(item1.name.toString()),
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

  /// Fetches user's stored theme and applies it.
  void _setSavedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var theme = prefs.getString('theme');
    if (theme == 'pink') {
      ColorsPlus.setSecondaryColor = Colors.pink[300]!;
    } else {
      ColorsPlus.setSecondaryColor = const Color(0xff53a99a);
    }
  }

  /// Saves user's selected theme to local storage.
  void _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme);
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
      List<Contact> queriedContacts = [];
      for (var contact in myContacts) {
        if ("${contact.name.first} ${contact.name.last}"
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          queriedContacts.add(contact);
        } else if (contact.phones[0].normalizedNumber
            .toString()
            .contains(query)) {
          queriedContacts.add(contact);
        }
      }
      setState(() {
        myContacts.clear();
        for (var contact in queriedContacts) {
          myContacts.add(contact);
        }
      });
      return;
    } else {
      setState(() {
        myContacts.clear();
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
              DialerPlus.makeCallBTN(
                  context: context,
                  phoneNumber: numToContact,
                  contact: _searchBarContr.text),
            DialerPlus.createSmsBTN(context: context, phoneNumber: numToContact)
          ],
        )
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            floatingActionButton: isFabVisible
                ? FloatingActionButton(
                    onPressed: () async {
                      await FlutterContacts.openExternalInsert();
                      setState(() {
                        myContacts.clear();
                        _getContacts();
                      });
                    },
                    backgroundColor: ColorsPlus.secondaryColor,
                    child: const Icon(Icons.add),
                  )
                : null,
            body: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                if (n.direction == ScrollDirection.forward) {
                  if (!isFabVisible) setState(() => isFabVisible = true);
                } else if (n.direction == ScrollDirection.reverse) {
                  if (isFabVisible) setState(() => isFabVisible = false);
                }
                return true;
              },
              child: Center(
                  child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                      backgroundColor: ColorsPlus.secondaryColor,
                      floating: true,
                      leading: InkWell(
                          onTap: () {
                            isThemeChanged = !isThemeChanged;
                            if (isThemeChanged) {
                              setState(() => ColorsPlus.setSecondaryColor =
                                  Colors.pink[300]!);
                              _saveTheme('pink');
                            } else {
                              setState(() => ColorsPlus.setSecondaryColor =
                                  const Color(0xff53a99a));
                              _saveTheme('blue');
                            }

                            FocusManager.instance.primaryFocus?.unfocus();
                          },
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
                          suffixIcon: Icon(Icons.search,
                              color: ColorsPlus.primaryColor),
                        ),
                      )),
                  _myContactCard(),
                  if (_isDialerShown)
                    DialerPlus.showDialerPad(
                        contr: _searchBarContr, context: context),
                  myContacts.isNotEmpty
                      ? _contactList(myContacts)
                      : _noMatchingContactsMSG(
                          numToContact: _searchBarContr.text)
                ],
              )),
            )));
  }
}
