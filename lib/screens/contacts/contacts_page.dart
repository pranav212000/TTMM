import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/screens/addgroup.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/shared/constants.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with SingleTickerProviderStateMixin {
  List<Contact> _registeredContacts = new List<Contact>();
  List<Contact> _inviteContacts = new List<Contact>();
  String _phoneNumber;
  List<String> _selectedNumbers = new List<String>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSyncComplete = false;
  TabController _tabController;

  @override
  void initState() {
    getContacts();
    getPhoneNumber();
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  Future getPhoneNumber() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = preferences.getString(currentPhoneNUmber);
    });
  }

  Future<void> syncContacts(Iterable<Contact> contacts) async {
    Future.wait(contacts.map((contact) async {
      print('Phones Length :  ${contact.phones.length}');
      if (contact.phones.length > 0) {
        String phoneNumber = contact.phones.first.value.replaceAll(' ', '');
        print('Phone 0 : ${contact.phones.first.value}');

        if (phoneNumber.length == 10) {
          phoneNumber = '+91' + phoneNumber;
        }
        bool isUserPresent =
            await DatabaseService().checkUserPresent(phoneNumber);
        if (isUserPresent) {
          print('Adding to registered ${contact.phones.first.value}');
          if(contact.phones.first.value.replaceAll(' ', '') != _phoneNumber)
            _registeredContacts.add(contact);
        } else {
          print('Adding to invite ${contact.phones.first.value}');
          _inviteContacts.add(contact);
        }
      }
    })).then((value) => setState(() {
          _registeredContacts.sort((contact1, contact2) =>
              contact1.displayName.compareTo(contact2.displayName));
          _inviteContacts.sort((contact1, contact2) =>
              contact1.displayName.compareTo(contact2.displayName));

          _isSyncComplete = true;

          print(' Invite contacts length : ${_inviteContacts.length}');
        }));
  }

  Future<void> getContacts() async {
    try {
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      await syncContacts(contacts);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Select Contact'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Available',
            ),
            Tab(
              text: 'Invite',
            )
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: _isSyncComplete,
        child: _fabs(),
      ),
      // child: FloatingActionButton(
      //   onPressed: _isSyncComplete
      //       ?
      //       : null,
      //   child: Icon(
      //     Icons.navigate_next,
      //   ),
      // ),
      // ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isSyncComplete
              //Build a list view of all contacts, displaying their avatar and
              // display name
              ? (_registeredContacts.length != 0
                  ? ListView.builder(
                      itemCount: _registeredContacts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        Contact contact = _registeredContacts?.elementAt(index);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 18),
                          leading: (contact.avatar != null &&
                                  contact.avatar.isNotEmpty)
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(contact.avatar),
                                )
                              : CircleAvatar(
                                  child: Text(contact.initials()),
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                ),
                          title: Text(contact.displayName ?? ''),
                          trailing: _selectedNumbers.contains(contact
                                  .phones.first.value
                                  .replaceAll(' ', ''))
                              ? Icon(Icons.check, color: Colors.green)
                              : Icon(Icons.group_add),
                          onTap: () {
                            setState(() {
                              if (_selectedNumbers.contains(contact
                                  .phones.first.value
                                  .replaceAll(' ', ''))) {
                                _selectedNumbers.remove(contact
                                    .phones.first.value
                                    .replaceAll(' ', ''));
                              } else {
                                print('Selected Contact');
                                _selectedNumbers.add(contact.phones.first.value
                                    .replaceAll(' ', ''));
                              }
                            });
                          },

                          //This can be further expanded to showing contacts detail
                          // onPressed().
                        );
                      },
                    )
                  : Center(
                      child: Text('No User Found'),
                    ))
              : Center(child: CircularProgressIndicator()),
          _isSyncComplete
              ? ((_inviteContacts.length != 0 && _isSyncComplete)
                  ? ListView.builder(
                      itemCount: _inviteContacts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        Contact contact = _inviteContacts?.elementAt(index);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 18),
                          leading: (contact.avatar != null &&
                                  contact.avatar.isNotEmpty)
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(contact.avatar),
                                )
                              : CircleAvatar(
                                  child: Text(contact.initials()),
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                ),
                          title: Text(contact.displayName ?? ''),
                          trailing: FlatButton(
                              onPressed: null, child: Text('Invite')),
                          // TODO Send invite on predding flat button!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        );
                      },
                    )
                  : Center(
                      child: Text('No User Found'),
                    ))
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _fabs() {
    return _tabController.index == 0
        ? FloatingActionButton(
            shape: StadiumBorder(),
            onPressed: () {
              if (_selectedNumbers.length > 0)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new AddGroup(_selectedNumbers)));
              else
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    'Please select a contact',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.red,
                ));

              // DatabaseService(uid: _uid)
              //     .addGroup(phoneNumbers)
              //     .whenComplete(() => print('Group Added'));
            },
            child: Icon(
              Icons.navigate_next,
              size: 20.0,
            ))
        : FloatingActionButton(
            shape: StadiumBorder(),
            onPressed: null,
            backgroundColor: Colors.redAccent,
            child: Icon(
              Icons.edit,
              size: 20.0,
            ),
          );
  }
}
