import 'package:floor/floor.dart';
import 'package:ttmm/floor/entity/group_entity.dart';

@dao
abstract class GroupDao {
  @Query('SELECT * FROM Group')
  Future<List<GroupEntity>> getAllGroups();

  @Query('SELECT * FROM Group WHERE groupId = :groupId')
  Future<List<GroupEntity>> getGroup(String groupId);

  @insert
  Future<void> insertGroup(GroupEntity group);

  @delete
  Future<void> deleteGroup(GroupEntity group);

  @Query('DELETE FROM Person')
  Future<void> deleteAllGroups();

  @transaction
  Future<void> replaceGroup(GroupEntity group) async {
    await deleteGroup(group);
    await insertGroup(group);
  }
}
