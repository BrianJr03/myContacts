import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';

class ContactsPage extends StatelessWidget {
  ContactsPage({Key? key}) : super(key: key);

  TextStyle get contactNameStyle => const TextStyle(fontSize: 25);
  TextStyle get contactInfoStyle =>
      TextStyle(fontSize: 15, color: Colors.grey[600]);

  final _contacts = [
    {'name': '*'},
    {'name': 'John'},
    {'name': 'Will'},
    {'name': 'Beth'},
    {'name': 'Miranda'},
    {'name': 'Mike'},
    {'name': 'Danny'},
  ];

  SliverList get myContactCard => SliverList(
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
                          style: contactNameStyle,
                        ),
                        const SizedBox(height: 7),
                        Text("Software Engineer", style: contactInfoStyle)
                      ])
                ],
              ),
            ),
          ),
        ]),
      );

  SliverGroupedListView myContacts(List<dynamic> contactList) {
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
      itemBuilder: (c, contact) {
        return Card(
          elevation: 5.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: const Icon(Icons.account_circle, size: 30),
            title: Text(contact['name']),
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
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
                onSubmitted: (value) {},
              )),
          myContactCard,
          myContacts(_contacts)
        ],
      ))),
    );
  }
}
