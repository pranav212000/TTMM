import 'package:floor/floor.dart';
import 'package:ttmm/floor/entity/group_entity.dart';

@dao
abstract class GroupDao {
  @Query('SELECT * FROM Group')
  Future<List<Group>> getAllGroups();

  @Query('SELECT * FROM Group WHERE groupId = :groupId')
  Future<List<Group>> getGroup(String groupId);

  @insert
  Future<void> insertGroup(Group group);

  @delete
  Future<void> deleteGroup(Group group);

  @Query('DELETE FROM Person')
  Future<void> deleteAllGroups();

  @transaction
  Future<void> replaceGroup(Group group) async {
    await deleteGroup(group);
    await insertGroup(group);
  }
}
