import 'dart:typed_data';

import 'package:floor/floor.dart';

@entity
class Person {
  @primaryKey
  final String phoneNumber;
  final Uint8List avatar;
  final String displayName;
  final String initials;
  final bool isRegistered;
  Person(this.phoneNumber, this.displayName, this.initials, this.avatar,
      this.isRegistered);
}
