import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/userdata.dart';
import 'package:ttmm/navigator.dart';
import 'package:ttmm/screens/home/home.dart';

import 'package:ttmm/services/auth.dart';
import 'package:ttmm/services/database.dart';
import 'package:ttmm/services/user_api_service.dart';
import 'package:ttmm/shared/constants.dart';

class Register extends StatefulWidget {
  final firebaseAuth.User user;
  Register({this.user});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _name;
  String _upi;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _image;
  Image image;
  final picker = ImagePicker();
  bool _loading = false;

  Future getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 85);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final StorageReference reference =
        _storage.ref().child('userProfileImages/');

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Register',
          ),
        ),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                AuthService()
                    .signout()
                    .then((value) => showSnackbar(_scaffoldKey, 'Signing out'));
              },
              icon: Icon(
                Icons.exit_to_app,
              ),
              label: Text(
                'Signout',
              ))
        ],
      ),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 160),
                  child: FlatButton(
                      onPressed: () => getImage(),
                      child: _image == null
                          ? Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(140)),
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 70,
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 80,
                              backgroundImage: Image.file(_image).image,
                            )),
                ),
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50, top: 40),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      primaryColor: Colors.orange,
                      accentColor: Colors.orange,
                    ),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                        enabled: true,
                        hintText: 'Name',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      onChanged: (val) => _name = val,
                      validator: (val) =>
                          val.isEmpty ? 'Please enter your name.' : null,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  padding: EdgeInsets.only(top: 10),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      primaryColor: Colors.orange,
                      accentColor: Colors.orange,
                    ),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.payment,
                        ),
                        enabled: true,
                        hintText: 'UPI ID (optional)',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      onChanged: (val) => _upi = val,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: RaisedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (_formKey.currentState.validate() &&
                                _image != null) {
                              StorageUploadTask storageUploadTask = reference
                                  .child("${widget.user.uid}.jpg")
                                  .putFile(_image);

                              if (storageUploadTask.isSuccessful ||
                                  storageUploadTask.isComplete) {
                                final String url =
                                    await reference.getDownloadURL();

                                print('User added');
                                Navigator.pop(context);

                                print("The download URL is " + url);
                              } else if (storageUploadTask.isInProgress) {
                                storageUploadTask.events.listen((event) {
                                  double percentage = 100 *
                                      (event.snapshot.bytesTransferred
                                              .toDouble() /
                                          event.snapshot.totalByteCount
                                              .toDouble());

                                  setState(() {
                                    _loading = true;
                                  });
                                  print("THe percentage " +
                                      percentage.toString());
                                });

                                StorageTaskSnapshot storageTaskSnapshot =
                                    await storageUploadTask.onComplete;
                                final String url = await storageTaskSnapshot.ref
                                    .getDownloadURL();

                                //Here you can get the download URL when the task has been completed.
                                print("Download URL " + url.toString());

                                UserData userData = new UserData(
                                    uid: widget.user.uid,
                                    phoneNumber: widget.user.phoneNumber,
                                    name: _name,
                                    groups: [],
                                    upiId: _upi,
                                    profileUrl: url);

                                print('SENDING THIS : ');
                                print(json.encode(userData));

                                await UserApiService.create()
                                    .addUser(userData.toJson())
                                    .then((response) => print(response))
                                    .catchError((err) => print(err))
                                    .whenComplete(
                                        () => Navigator.of(context).pop());

                                // DatabaseService(phoneNumber: widget.user.phoneNumber)
                                //     .updateUserData(
                                //         widget.user.uid,
                                //         widget.user.phoneNumber,
                                //         _name,
                                //         url,
                                //         List<String>());

                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                preferences.setString(
                                    currentUser, widget.user.uid);
                                preferences.setString(currentPhoneNUmber,
                                    widget.user.phoneNumber);

                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => NavigatorPage()));
                              } else {
                                //Catch any cases here that might come up like canceled, interrupted
                                print('Task not completed');
                              }
                            } else if (_image == null) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text('Please select a profile pic'),
                              ));
                            }
                          },
                    child: Text('Submit'),
                    // color: Colors.tealAccent,
                  ),
                ),
                Visibility(
                  visible: _loading,
                  child: SpinKitRing(
                    color: Colors.orange,
                  ),
                )
              ],
            ),
          )),
    );
  }
}
