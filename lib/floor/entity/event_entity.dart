import 'package:floor/floor.dart';
import 'package:ttmm/floor/entity/group_entity.dart';

@Entity(tableName: 'event', foreignKeys: [
  ForeignKey(
      childColumns: ['groupId'],
      parentColumns: ['groupId'],
      entity: GroupEntity)
])
class EventEntity {
  @PrimaryKey()
  final String eventId;
  final String groupId;
  final String eventName;
  final String transactionId;
  final String createdAt;
  final String updatedAt;

  EventEntity(
      {this.eventId,
      this.groupId,
      this.eventName,
      this.transactionId,
      this.createdAt,
      this.updatedAt});
}
