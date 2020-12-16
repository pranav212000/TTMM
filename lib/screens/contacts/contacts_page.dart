import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/floor/dao/person_dao.dart';
import 'package:ttmm/floor/database/database.dart';
import 'package:ttmm/floor/entity/person_entity.dart';
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
    with TickerProviderStateMixin {
  List<Person> _registeredContacts = new List<Person>();
  List<Person> _inviteContacts = new List<Person>();
  String _phoneNumber;
  String _uid;
  List<String> _selectedNumbers = new List<String>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSyncComplete = false;
  bool _isLoadingComplete = false;
  bool _isOneSyncDone = false;
  TabController _tabController;
  final ScrollController _inviteController = ScrollController();
  final ScrollController _registeredController = ScrollController();
  AnimationController controller;
  Animation colorAnimation;
  Animation rotateAnimation;

// TODO add sync button and instead of sync always do once a day or on clicking sync button
  @override
  void initState() {
    getContactsFromFloor();
    getContacts();
    getUserCredentials();
    getOneSyncComplete();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 200));
    rotateAnimation = Tween<double>(begin: 360, end: 0.0).animate(controller);

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

  Future getOneSyncComplete() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _isOneSyncDone = preferences.getBool(isOneSyncComplete);
      if (_isOneSyncDone == null) _isOneSyncDone = false;
    });
  }

  Future getUserCredentials() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = preferences.getString(currentPhoneNUmber);
      _uid = preferences.getString(currentUser);
    });
  }

  Future<void> syncContacts(Iterable<Contact> contacts) async {
    _isSyncComplete = false;
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final personDao = database.personDao;

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

    // print(numberToContact.keys);

    Response response = await UserApiService.create()
        .syncContacts({'contacts': numberToContact.keys.toList()});

    List<dynamic> presentStatus = response.body;

    for (dynamic status in presentStatus) {
      Map<String, dynamic> map = new Map<String, dynamic>.from(status);
      if (map.keys.elementAt(0) != _phoneNumber) {
        Contact contact = numberToContact[map.keys.elementAt(0)];

        if (map.values.elementAt(0)) {
          Contact contact = numberToContact[map.keys.elementAt(0)];
          Person person = new Person(map.keys.elementAt(0), contact.displayName,
              contact.initials(), contact.avatar, true);
          personDao.replacePerson(person);
          // _registeredContacts.add(person);
        } else {
          Person person = new Person(map.keys.elementAt(0), contact.displayName,
              contact.initials(), contact.avatar, false);
          personDao.replacePerson(person);
          // _inviteContacts.add(person);
        }
      }
    }

    setState(() async {
      print('Sync Complete');
      showSnackbar(_scaffoldKey, 'Sync Complete');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool(isOneSyncComplete, true);
      _isOneSyncDone = true;
      _isSyncComplete = true;
      _isLoadingComplete = false;
      // controller.stop();
      // controller.reset();
      getContactsFromFloor();

      print(' Invite contacts length : ${_inviteContacts.length}');
    });
  }

  Future<void> getContacts() async {
    // controller.forward();
    try {
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      return await syncContacts(contacts);
    } catch (e) {
      // controller.stop();
      // controller.reset();
      print(e.toString());
    }
  }

  Future getContactsFromFloor() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final personDao = database.personDao;
    // List<Person> persons = await personDao.findAllPersons();
    _registeredContacts = await personDao.registeredPeople();
    _registeredContacts
        .removeWhere((person) => person.phoneNumber == _phoneNumber);
    print('GOT REGISTERED');
    _inviteContacts = await personDao.unregisteredPeople();
    print('GOT INVITE');
    setState(() {
      // _registeredContacts.sort((contact1, contact2) =>
      //     contact1.displayName.compareTo(contact2.displayName));
      // _inviteContacts.sort((contact1, contact2) =>
      //     contact1.displayName.compareTo(contact2.displayName));

      _isLoadingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Select Contact'),
        actions: <Widget>[
          AnimatedSync(
            animation: rotateAnimation,
            callback: () async {
              controller.forward();

              if (_isSyncComplete) {
                showSnackbar(_scaffoldKey, 'Syncing Contacts.');
                await getContacts();
              } else {
               showSnackbar(_scaffoldKey, 'Please wait sync already in progress!!');
              }
              controller.stop();
              controller.reset();
            },
          ),
        ],
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
        visible: _isSyncComplete || (_isLoadingComplete && _isOneSyncDone),
        child: _fabs(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isSyncComplete || (_isLoadingComplete && _isOneSyncDone)
              //Build a list view of all contacts, displaying their avatar and
              // display name
              ? (_registeredContacts.length != 0
                  ? DraggableScrollbar.arrows(
                      controller: _registeredController,
                      child: ListView.builder(
                        controller: _registeredController,
                        itemCount: _registeredContacts?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          Person person = _registeredContacts?.elementAt(index);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 18),
                            leading: (person.avatar != null &&
                                    person.avatar.isNotEmpty)
                                ? CircleAvatar(
                                    backgroundImage: MemoryImage(person.avatar),
                                  )
                                : CircleAvatar(
                                    child: Text(person.initials),
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                  ),
                            title: Text(person.displayName ?? ''),
                            trailing:
                                _selectedNumbers.contains(person.phoneNumber)
                                    ? Icon(Icons.check, color: Colors.green)
                                    : Icon(Icons.group_add),
                            onTap: () {
                              setState(() {
                                if (_selectedNumbers
                                    .contains(person.phoneNumber)) {
                                  _selectedNumbers.remove(person.phoneNumber);
                                } else {
                                  print('Selected Contact');
                                  _selectedNumbers.add(person.phoneNumber);
                                }
                              });
                            },

                            //This can be further expanded to showing contacts detail
                            // onPressed().
                          );
                        },
                      ))
                  : Center(
                      child: Text('No User Found'),
                    ))
              : Center(child: CircularProgressIndicator()),
          _isSyncComplete || (_isLoadingComplete && _isOneSyncDone)
              ? ((_inviteContacts.length != 0 &&
                      (_isSyncComplete ||
                          (_isLoadingComplete && _isOneSyncDone)))
                  ? DraggableScrollbar.arrows(
                      controller: _inviteController,
                      child: ListView.builder(
                        controller: _inviteController,
                        itemCount: _inviteContacts?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          Person person = _inviteContacts?.elementAt(index);
                          return ListTile(
                            onTap: () {
                              _scaffoldKey.currentState.removeCurrentSnackBar();
                              showSnackbar(_scaffoldKey, 'Coming real soon ;)');
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 18),
                            leading: (person.avatar != null &&
                                    person.avatar.isNotEmpty)
                                ? CircleAvatar(
                                    backgroundImage: MemoryImage(person.avatar),
                                  )
                                : CircleAvatar(
                                    child: Text(person.initials),
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                  ),
                            title: Text(person.displayName ?? ''),
                            trailing: FlatButton(
                              child: Text('Invite'),
                              onPressed: () {
                                _scaffoldKey.currentState
                                    .removeCurrentSnackBar();
                                showSnackbar(
                                    _scaffoldKey, 'Coming real soon ;)');
                              },
                            ),
                            // TODO Send invite on pressing flat button!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                          );
                        },
                      ),
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

class AnimatedSync extends AnimatedWidget {
  VoidCallback callback;
  AnimatedSync({Key key, Animation<double> animation, this.callback})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Transform.rotate(
      angle: animation.value,
      child: IconButton(
          icon: Icon(Icons.sync), // <-- Icon
          onPressed: () => callback()),
    );
  }
}
