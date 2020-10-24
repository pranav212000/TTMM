// dao/person_dao.dart

import 'package:floor/floor.dart';
import 'package:ttmm/floor/entity/person_entity.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Future<List<Person>> findAllPersons();

  @Query('SELECT * FROM Person WHERE phoneNumber = :phoneNumber')
  Stream<Person> findPerson(String phoneNumber);

  @Query('SELECT * FROM Person WHERE isRegistered = 1 ORDER BY displayName ASC')
  Future<List<Person>> registeredPeople();

  @Query('SELECT * FROM Person WHERE isRegistered = 0 ORDER BY displayName ASC')
  Future<List<Person>> unregisteredPeople();

  @insert
  Future<void> insertPerson(Person person);

  @delete
  Future<void> deletePerson(Person person);

  @Query('DELETE FROM Person')
  Future<void> deleteAllPersons();

  @transaction
  Future<void> replacePerson(Person person) async {
    await deletePerson(person);
    await insertPerson(person);
  }
}
