// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PersonDao _personDaoInstance;

  GroupDao _groupDaoInstance;

  EventDao _eventDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Person` (`phoneNumber` TEXT, `avatar` BLOB, `displayName` TEXT, `initials` TEXT, `isRegistered` INTEGER, PRIMARY KEY (`phoneNumber`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `GroupEntity` (`groupId` TEXT, `groupName` TEXT, `groupIconUrl` TEXT, `updatedAt` TEXT, `createdAt` TEXT, PRIMARY KEY (`groupId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `event` (`eventId` TEXT, `groupId` TEXT, `eventName` TEXT, `transactionId` TEXT, `createdAt` TEXT, `updatedAt` TEXT, FOREIGN KEY (`groupId`) REFERENCES `GroupEntity` (`groupId`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`eventId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PersonDao get personDao {
    return _personDaoInstance ??= _$PersonDao(database, changeListener);
  }

  @override
  GroupDao get groupDao {
    return _groupDaoInstance ??= _$GroupDao(database, changeListener);
  }

  @override
  EventDao get eventDao {
    return _eventDaoInstance ??= _$EventDao(database, changeListener);
  }
}

class _$PersonDao extends PersonDao {
  _$PersonDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _personInsertionAdapter = InsertionAdapter(
            database,
            'Person',
            (Person item) => <String, dynamic>{
                  'phoneNumber': item.phoneNumber,
                  'avatar': item.avatar,
                  'displayName': item.displayName,
                  'initials': item.initials,
                  'isRegistered': item.isRegistered == null
                      ? null
                      : (item.isRegistered ? 1 : 0)
                },
            changeListener),
        _personDeletionAdapter = DeletionAdapter(
            database,
            'Person',
            ['phoneNumber'],
            (Person item) => <String, dynamic>{
                  'phoneNumber': item.phoneNumber,
                  'avatar': item.avatar,
                  'displayName': item.displayName,
                  'initials': item.initials,
                  'isRegistered': item.isRegistered == null
                      ? null
                      : (item.isRegistered ? 1 : 0)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Person> _personInsertionAdapter;

  final DeletionAdapter<Person> _personDeletionAdapter;

  @override
  Future<List<Person>> findAllPersons() async {
    return _queryAdapter.queryList('SELECT * FROM Person',
        mapper: (Map<String, dynamic> row) => Person(
            row['phoneNumber'] as String,
            row['displayName'] as String,
            row['initials'] as String,
            row['avatar'] as Uint8List,
            row['isRegistered'] == null
                ? null
                : (row['isRegistered'] as int) != 0));
  }

  @override
  Stream<Person> findPerson(String phoneNumber) {
    return _queryAdapter.queryStream(
        'SELECT * FROM Person WHERE phoneNumber = ?',
        arguments: <dynamic>[phoneNumber],
        queryableName: 'Person',
        isView: false,
        mapper: (Map<String, dynamic> row) => Person(
            row['phoneNumber'] as String,
            row['displayName'] as String,
            row['initials'] as String,
            row['avatar'] as Uint8List,
            row['isRegistered'] == null
                ? null
                : (row['isRegistered'] as int) != 0));
  }

  @override
  Future<List<Person>> registeredPeople() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Person WHERE isRegistered = 1 ORDER BY displayName ASC',
        mapper: (Map<String, dynamic> row) => Person(
            row['phoneNumber'] as String,
            row['displayName'] as String,
            row['initials'] as String,
            row['avatar'] as Uint8List,
            row['isRegistered'] == null
                ? null
                : (row['isRegistered'] as int) != 0));
  }

  @override
  Future<List<Person>> unregisteredPeople() async {
    return _queryAdapter.queryList(
        'SELECT * FROM Person WHERE isRegistered = 0 ORDER BY displayName ASC',
        mapper: (Map<String, dynamic> row) => Person(
            row['phoneNumber'] as String,
            row['displayName'] as String,
            row['initials'] as String,
            row['avatar'] as Uint8List,
            row['isRegistered'] == null
                ? null
                : (row['isRegistered'] as int) != 0));
  }

  @override
  Future<void> deleteAllPersons() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Person');
  }

  @override
  Future<void> insertPerson(Person person) async {
    await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePerson(Person person) async {
    await _personDeletionAdapter.delete(person);
  }

  @override
  Future<void> replacePerson(Person person) async {
    if (database is sqflite.Transaction) {
      await super.replacePerson(person);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.personDao.replacePerson(person);
      });
    }
  }
}

class _$GroupDao extends GroupDao {
  _$GroupDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _groupEntityInsertionAdapter = InsertionAdapter(
            database,
            'GroupEntity',
            (GroupEntity item) => <String, dynamic>{
                  'groupId': item.groupId,
                  'groupName': item.groupName,
                  'groupIconUrl': item.groupIconUrl,
                  'updatedAt': item.updatedAt,
                  'createdAt': item.createdAt
                }),
        _groupEntityDeletionAdapter = DeletionAdapter(
            database,
            'GroupEntity',
            ['groupId'],
            (GroupEntity item) => <String, dynamic>{
                  'groupId': item.groupId,
                  'groupName': item.groupName,
                  'groupIconUrl': item.groupIconUrl,
                  'updatedAt': item.updatedAt,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GroupEntity> _groupEntityInsertionAdapter;

  final DeletionAdapter<GroupEntity> _groupEntityDeletionAdapter;

  @override
  Future<List<GroupEntity>> getAllGroups() async {
    return _queryAdapter.queryList('SELECT * FROM Group',
        mapper: (Map<String, dynamic> row) => GroupEntity(
            groupId: row['groupId'] as String,
            groupName: row['groupName'] as String,
            updatedAt: row['updatedAt'] as String,
            createdAt: row['createdAt'] as String,
            groupIconUrl: row['groupIconUrl'] as String));
  }

  @override
  Future<List<GroupEntity>> getGroup(String groupId) async {
    return _queryAdapter.queryList('SELECT * FROM Group WHERE groupId = ?',
        arguments: <dynamic>[groupId],
        mapper: (Map<String, dynamic> row) => GroupEntity(
            groupId: row['groupId'] as String,
            groupName: row['groupName'] as String,
            updatedAt: row['updatedAt'] as String,
            createdAt: row['createdAt'] as String,
            groupIconUrl: row['groupIconUrl'] as String));
  }

  @override
  Future<void> deleteAllGroups() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Person');
  }

  @override
  Future<void> insertGroup(GroupEntity group) async {
    await _groupEntityInsertionAdapter.insert(group, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteGroup(GroupEntity group) async {
    await _groupEntityDeletionAdapter.delete(group);
  }

  @override
  Future<void> replaceGroup(GroupEntity group) async {
    if (database is sqflite.Transaction) {
      await super.replaceGroup(group);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.groupDao.replaceGroup(group);
      });
    }
  }
}

class _$EventDao extends EventDao {
  _$EventDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _eventEntityInsertionAdapter = InsertionAdapter(
            database,
            'event',
            (EventEntity item) => <String, dynamic>{
                  'eventId': item.eventId,
                  'groupId': item.groupId,
                  'eventName': item.eventName,
                  'transactionId': item.transactionId,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                }),
        _eventEntityDeletionAdapter = DeletionAdapter(
            database,
            'event',
            ['eventId'],
            (EventEntity item) => <String, dynamic>{
                  'eventId': item.eventId,
                  'groupId': item.groupId,
                  'eventName': item.eventName,
                  'transactionId': item.transactionId,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EventEntity> _eventEntityInsertionAdapter;

  final DeletionAdapter<EventEntity> _eventEntityDeletionAdapter;

  @override
  Future<List<EventEntity>> getAllEvents(String groupId) async {
    return _queryAdapter.queryList('SELECT * FROM Event WHERE groupId = ?',
        arguments: <dynamic>[groupId],
        mapper: (Map<String, dynamic> row) => EventEntity(
            eventId: row['eventId'] as String,
            groupId: row['groupId'] as String,
            eventName: row['eventName'] as String,
            transactionId: row['transactionId'] as String,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String));
  }

  @override
  Future<void> deleteAllEvents() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Event');
  }

  @override
  Future<void> insertEvent(EventEntity eventEntity) async {
    await _eventEntityInsertionAdapter.insert(
        eventEntity, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEvent(EventEntity eventEntity) async {
    await _eventEntityDeletionAdapter.delete(eventEntity);
  }

  @override
  Future<void> replaceEvent(EventEntity eventEntity) async {
    if (database is sqflite.Transaction) {
      await super.replaceEvent(eventEntity);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.eventDao.replaceEvent(eventEntity);
      });
    }
  }
}
