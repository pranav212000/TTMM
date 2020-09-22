import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ttmm/models/group.dart';
import 'package:ttmm/models/user.dart';
import 'package:ttmm/shared/constants.dart' as constants;
import 'package:uuid/uuid.dart';

class DatabaseService {
  final String phoneNumber;

  DatabaseService({this.phoneNumber});

  final CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection('groups');

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference contactCollection =
      FirebaseFirestore.instance.collection('contacts');

  // List<Group> _groupListFromSnapshot(QuerySnapshot snapshot) {
  //   return snapshot.docs.map((doc) {
  //     Map<String, dynamic> _data = doc.data();
  //     return Group(
  //         groupId: _data['groupID'] ?? '',
  //         groupName: _data['groupName'] ?? '',
  //         groupMembers: _data['members'] ?? List<String>());
  //   }).toList();
  // }

  Future updateUserData(String uid, String phoneNumber, String name, String url,
      List<String> groups) async {
    return await usersCollection.doc(phoneNumber).set({
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'profileUrl': url,
      'groups': groups
    });
  }

  // Future addContact(String phoneNumber) async{
  //   return
  // }

  Future<UserData> getUserData(String phoneNumber) async {
    DocumentSnapshot snapshot = await usersCollection.doc(phoneNumber).get();
    if (snapshot.exists) {
      Map<String, dynamic> _data = snapshot.data();
      return UserData(
          uid: _data['uid'],
          name: _data['name'],
          groups: _data['groups'],
          phoneNumber: _data['phoneNumber'],
          profileUrl: _data['profileUrl']);
    } else {
      return null;
    }
  }

  Future<bool> checkUserPresent(String phoneNumber) async {
    DocumentSnapshot snapshot = await usersCollection.doc(phoneNumber).get();
    if (snapshot.exists) {
      return true;
    } else
      return false;
  }

  Future addGroup(
      String id, String name, List<UserData> users, String url) async {
    List<String> phoneNumbers = new List<String>();
    List<String> userIds = new List<String>();

    users.forEach((user) {
      phoneNumbers.add(user.phoneNumber);
      userIds.add(user.uid);
    });

    await groupsCollection.doc(id).set({
      constants.groupId: id,
      constants.groupName: name,
      constants.groupIconUrl: url,
      constants.groupMembers: phoneNumbers,
      constants.updateTime: Timestamp.fromDate(DateTime.now()),
      constants.createdTime: Timestamp.fromDate(DateTime.now()),
    }).then((value) => {
          phoneNumbers.forEach((phoneNumber) {
            usersCollection.doc(phoneNumber).update({
              constants.groups: FieldValue.arrayUnion([id])
            });
          })
        });
  }

  Future<List<Group>> getUserGroups(List<dynamic> groupIds) async {
    List<Group> groups = new List<Group>();

    print(groupIds);
    await Future.wait(groupIds.map((groupId) async {
      DocumentSnapshot snapshot = await groupsCollection.doc(groupId).get();
      if (snapshot.exists) {
        Group group = _groupFromSnapshot(snapshot);
        groups.add(group);
      }
    }));

    return groups;
  }

  Group _groupFromSnapshot(DocumentSnapshot doc) {
    return Group(
        groupId: doc.data()[constants.groupId],
        groupName: doc.data()[constants.groupName],
        groupIconUrl: doc.data()[constants.groupIconUrl],
        groupMembers: doc.data()[constants.groupMembers],
        updateTime: doc.data()[constants.updateTime],
        createdTime: doc.data()[constants.createdTime]);
  }

  Stream<UserData> get userData {
    return usersCollection
        .doc(phoneNumber)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot != null) {
      if (snapshot.data() == null)
        print('snapshot data is null');
      else
        return UserData(
            uid: snapshot.data()['uid'],
            name: snapshot.data()['name'],
            groups: snapshot.data()['groups'],
            phoneNumber: snapshot.data()['phoneNumber'],
            profileUrl: snapshot.data()['profileUrl']);
    } else
      print('snapshot is null');

    return null;
  }

  Future<List<UserData>> getUsers(List<dynamic> userPhone) async {
    List<UserData> users = new List<UserData>();

    await Future.wait(userPhone.map((phone) async {
      UserData user = await getUserData(phone).then((user) {
        if (user == null) {
          print('USER RECIEVED IS NULL in getUSers from getUserdata');
        } else {
          users.add(user);
        }
        return user;
      });
    }));

    print('returning users with length ${users.length}');
    // print('users in ')
    return users;
  }

  // Stream<UserData> userData {
  //   return
  // }


















}
