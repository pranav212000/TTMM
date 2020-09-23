import 'package:chopper/chopper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'userdata.g.dart';

@JsonSerializable()
class UserData {
  String uid;
  String name;
  String phoneNumber;
  List<dynamic> groups;
  String profileUrl;

  

  UserData(
      {this.uid, this.name, this.phoneNumber, this.groups, this.profileUrl});

  // Map<String, dynamic> toJson() => {
  //       'uid': this.uid,
  //       'name': this.name,
  //       'phoneNumber': this.phoneNumber,
  //       'groups': this.groups,
  //       'profileUrl': this.profileUrl
  //     };

  // Map toJson() => {
  //       'uid': this.uid,
  //       'name': this.name,
  //       'phoneNumber': this.phoneNumber,
  //       'groups': this.groups,
  //       'profileUrl': this.profileUrl
  //     };

  // UserData.fromJson(Map<String, dynamic> json)
  //     : uid = json['uid'],
  //       name = json['name'],
  //       phoneNumber = json['phoneNumber'],
  //       groups = json['groups'],
  //       profileUrl = json['profileUrl'];

  String getProfileUrl() => this.profileUrl;



  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

      
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
