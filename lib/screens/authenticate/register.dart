import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttmm/models/userdata.dart';
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
        title: Text('Register'),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                // showSnackbar(_scaffoldKey, 'Signing out');
                AuthService().signout();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              label: Text(
                'Signout',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                  onPressed: () => getImage(),
                  child: _image == null
                      ? CircleAvatar(
                          radius: 70,
                          child: Icon(
                            Icons.add_a_photo,
                            size: 60,
                          ))
                      : CircleAvatar(
                          radius: 70,
                          backgroundImage: Image.file(_image).image,
                        )),
              Container(
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //     color: Colors.tealAccent,),
                //     // borderRadius: BorderRadius.circular(32.0)),
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                    ),

                    enabled: true,
                    hintText: 'Name',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    // errorBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.pink, width: 2),
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                    // focusedErrorBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.pink, width: 2),
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (val) => _name = val,
                  validator: (val) =>
                      val.isEmpty ? 'Please enter your name.' : null,
                ),
              ),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate() && _image != null) {
                    StorageUploadTask storageUploadTask = reference
                        .child("${widget.user.uid}.jpg")
                        .putFile(_image);

                    if (storageUploadTask.isSuccessful ||
                        storageUploadTask.isComplete) {
                      final String url = await reference.getDownloadURL();

                      print('User added');
                      Navigator.pop(context);

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

                      UserData userData = new UserData(
                          uid: widget.user.uid,
                          phoneNumber: widget.user.phoneNumber,
                          name: _name,
                          groups: [],
                          profileUrl: url);

                      print('SENDING THIS : ');
                      print(json.encode(userData));

                      await UserApiService.create()
                          .addUser(userData.toJson())
                          .then((response) => print(response))
                          .catchError((err) => print(err))
                          .whenComplete(() => Navigator.of(context).pop());

                      // DatabaseService(phoneNumber: widget.user.phoneNumber)
                      //     .updateUserData(
                      //         widget.user.uid,
                      //         widget.user.phoneNumber,
                      //         _name,
                      //         url,
                      //         List<String>());

                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(currentUser, widget.user.uid);
                      preferences.setString(
                          currentPhoneNUmber, widget.user.phoneNumber);

                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Home()));
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
                color: Colors.tealAccent,
              ),
              Visibility(
                visible: _loading,
                child: SpinKitRing(
                  color: Colors.green,
                ),
              )
            ],
          )),
    );
  }
}
