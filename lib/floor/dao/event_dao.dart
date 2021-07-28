// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:ttmm/floor/entity/event_entity.dart';

@dao
abstract class EventDao {
  @Query('SELECT * FROM Event WHERE groupId = :groupId')
  Future<List<EventEntity>> getAllEvents(String groupId);

  @insert
  Future<void> insertEvent(EventEntity eventEntity);

  @delete
  Future<void> deleteEvent(EventEntity eventEntity);

  @Query('DELETE FROM Event')
  Future<void> deleteAllEvents();

  @transaction
  Future<void> replaceEvent(EventEntity eventEntity) async {
    // await deleteEvent(eventEntity);
    // await insertEvent(eventEntity);
  }
}
