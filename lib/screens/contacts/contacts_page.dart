import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/screens/grouphome/addgroup.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/user_api_service.dart';
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
  String _uid;
  List<String> _selectedNumbers = new List<String>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSyncComplete = false;
  TabController _tabController;

  @override
  void initState() {
    getContacts();
    getUserCredentials();
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

  Future getUserCredentials() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = preferences.getString(currentPhoneNUmber);
      _uid = preferences.getString(currentUser);
    });
  }

  Future<void> syncContacts(Iterable<Contact> contacts) async {
    Map<String, Contact> numberToContact = new Map<String, Contact>();
    for (Contact contact in contacts) {
      if (contact.phones.length > 0) {
        String phoneNumber = contact.phones.first.value.replaceAll(' ', '');
        // print('Phone 0 : ${contact.phones.first.value}');

        if (phoneNumber.length == 10) {
          phoneNumber = '+91' + phoneNumber;
        }
        numberToContact[phoneNumber] = contact;
      }
    }

    print(numberToContact.keys);

    Response response = await UserApiService.create()
        .syncContacts({'contacts': numberToContact.keys.toList()});

    List<dynamic> presentStatus = response.body;

    for (dynamic status in presentStatus) {
      Map<String, dynamic> map = new Map<String, dynamic>.from(status);
      if (map.keys.elementAt(0) != _phoneNumber) {
        if (map.values.elementAt(0))
          _registeredContacts.add(numberToContact[map.keys.elementAt(0)]);
        else
          _inviteContacts.add(numberToContact[map.keys.elementAt(0)]);
      }
    }

    setState(() {
      _registeredContacts.sort((contact1, contact2) =>
          contact1.displayName.compareTo(contact2.displayName));
      _inviteContacts.sort((contact1, contact2) =>
          contact1.displayName.compareTo(contact2.displayName));

      _isSyncComplete = true;

      print(' Invite contacts length : ${_inviteContacts.length}');
    });
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
            onPressed: () async {
              if (_selectedNumbers.length > 0) {
                String result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new AddGroup(_selectedNumbers)));

                if (result == 'OK') {
                  Navigator.of(context).pop('OK');
                }
              } else
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    'Please select a contact',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.red,
                ));
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
