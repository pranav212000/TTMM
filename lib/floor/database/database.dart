// required package imports
import 'dart:async';
import 'dart:typed_data';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:ttmm/floor/dao/event_dao.dart';
import 'package:ttmm/floor/dao/group_dao.dart';
import 'package:ttmm/floor/dao/person_dao.dart';
import 'package:ttmm/floor/entity/event_entity.dart';
import 'package:ttmm/floor/entity/group_entity.dart';
import 'package:ttmm/floor/entity/person_entity.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Person, GroupEntity, EventEntity])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
  GroupDao get groupDao;
  EventDao get eventDao;
}
