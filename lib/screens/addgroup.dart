import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/group_api_service.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';
import 'package:uuid/uuid.dart';

class AddGroup extends StatefulWidget {
  final List<String> selectedNumbers;

  AddGroup(this.selectedNumbers);

  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  List<UserData> _users;
  bool _loading = true;
  String _phoneNumber;
  File _image;
  Image image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String groupName = '';

  final StorageReference reference =
      FirebaseStorage.instance.ref().child('groupIcons/');
  // Future getUserPhone() async {

  // }

  Future<void> getUsersData(List<String> selectedContacts) async {
    List<UserData> users = new List<UserData>();

    String phoneNumber;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    phoneNumber = preferences.getString(currentPhoneNUmber);
    setState(() {
      _phoneNumber = phoneNumber;
    });

    if (!selectedContacts.contains(phoneNumber))
      selectedContacts.insert(0, phoneNumber);

    Future.wait(selectedContacts.map((number) async {
      // UserData userData = await DatabaseService().getUserData(number);

      Response response = await UserApiService.create().getUser(number);
      UserData userData = UserData.fromJson(response.body);

      if (userData != null) {
        print('User data not null');
        print(userData.profileUrl);
        // print(userData.getProfileUrl());
        if (userData.phoneNumber == _phoneNumber)
          users.insert(0, userData);
        else
          users.add(userData);
      } else
        print('User data null for $number');
    })).then((value) {
      setState(() {
        print('Called set State _users');
        _loading = false;
        _users = users;
      });
    });
  }

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 85);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    // getUserPhone();

    getUsersData(widget.selectedNumbers);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add Group'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            String uid = Uuid().v1();
            if (_image != null) {
              StorageUploadTask storageUploadTask =
                  reference.child("$uid.jpg").putFile(_image);

              if (storageUploadTask.isSuccessful ||
                  storageUploadTask.isComplete) {
                final String url = await reference.getDownloadURL();

                print('User added');
                print("The download URL is " + url);
              } else if (storageUploadTask.isInProgress) {
                storageUploadTask.events.listen((event) {
                  double percentage = 100 *
                      (event.snapshot.bytesTransferred.toDouble() /
                          event.snapshot.totalByteCount.toDouble());

                  setState(() {
                    _loading = true;
                  });
                  print("THe percentage " + percentage.toString());
                });

                StorageTaskSnapshot storageTaskSnapshot =
                    await storageUploadTask.onComplete;
                final String url =
                    await storageTaskSnapshot.ref.getDownloadURL();

                //Here you can get the download URL when the task has been completed.
                print("Download URL " + url.toString());

                List<String> phoneNumbers = new List<String>();

                _users.forEach((user) {
                  phoneNumbers.add(user.phoneNumber);
                });

                // for (UserData user in _users) {}

                print(phoneNumbers);

                Group group = new Group(
                    groupId: uid,
                    groupName: groupName,
                    groupMembers: phoneNumbers,
                    groupIconUrl: url);

                Response response = await GroupApiService.create()
                    .addGroup(group.toJson())
                    .catchError((error) => print(error));
                if (response.statusCode == 200) {
                  print(response.body);
                  showSnackbar(_scaffoldKey, 'Group Added');
                } else {
                  showSnackbar(_scaffoldKey,
                      'Could not add group, please try again later!!');
                }

                Navigator.of(context).popUntil((route) => route.isFirst);

                // DatabaseService()
                //     .addGroup(uid, groupName, _users, url)
                //     .then((value) {
                //   print('Group Added');
                //   Navigator.of(context).popUntil((route) => route.isFirst);
                // });

                print('Group Added');
              } else {
                //Catch any cases here that might come up like canceled, interrupted
                print('Task not completed');
              }
            } else {
              List<String> phoneNumbers = new List<String>();

              _users.forEach((user) {
                phoneNumbers.add(user.phoneNumber);
              });

              // for (UserData user in _users) {}

              print(phoneNumbers);

              Group group = new Group(
                groupId: uid,
                groupName: groupName,
                groupMembers: phoneNumbers,
              );
              Response response = await GroupApiService.create()
                  .addGroup(group.toJson())
                  .catchError((error) => print(error));
              if (response.statusCode == 200) {
                print(response.body);
                showSnackbar(_scaffoldKey, 'Group Added');
              } else {
                showSnackbar(_scaffoldKey,
                    'Could not add group, please try again later!!');
              }

              Navigator.of(context).pop('OK');
            }
          }
        },
        child: Icon(Icons.chevron_right),
        tooltip: 'Next',
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  elevation: 10,
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipOval(
                            child: Material(
                              color: Colors.blue, // button color
                              child: InkWell(
                                splashColor: Colors.red, // inkwell color
                                child: SizedBox(
                                    width: 45,
                                    height: 45,
                                    child: _image == null
                                        ? Icon(
                                            Icons.add_a_photo,
                                            color: Colors.white,
                                          )
                                        : Image.file(_image)),
                                onTap: () => getImage(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onChanged: (val) => groupName = val,
                              validator: (val) => val.isEmpty
                                  ? 'Please enter a group name'
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Group Name',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider(
                //   thickness: 2,
                // ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: widget.selectedNumbers == null
                        ? Center(child: CircularProgressIndicator())
                        : List.generate(widget.selectedNumbers.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    // backgroundImage: Image.asset('assets/images/profile_placeholder.jpg').image,
                                    backgroundImage: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/profile_placeholder.jpg',
                                            image: _users
                                                .elementAt(index)
                                                .getProfileUrl())
                                        .image,
                                  ),
                                  _users.elementAt(index).phoneNumber ==
                                          _phoneNumber
                                      ? Text('You')
                                      : Text(_users.elementAt(index).name),
                                ],
                              ),
                            );
                          }),
                  ),
                ),
              ],
            ),
    );
  }
}
