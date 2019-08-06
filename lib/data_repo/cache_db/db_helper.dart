import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper.internal();

  DbHelper.internal();

  factory DbHelper() => _instance;

  Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
//    io.Directory docsDir = await getApplicationDocumentsDirectory();
//    String path = join(docsDir.path, CacheDatabase.dbName);
    Database dbNVIP = await openDatabase(
      join(await getDatabasesPath(), CacheDatabase.dbName),
      version: CacheDatabase.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return dbNVIP;
  }

  /// Executed upon database creation
  Future<void> _onCreate(Database db, int version) async {
    db.transaction((txn) async {
      await txn.execute(SQLQueries.createAuthTokenTable);
      await txn.execute(SQLQueries.createUserRolesTable);
      await txn.execute(SQLQueries.createCentersTable);
      await txn.execute(SQLQueries.createDiseasesTable);

      await txn.insert(UserRolesTable.tableName,
          {UserRolesTable.colName: Constants.privilegeAdmin},
          conflictAlgorithm: ConflictAlgorithm.abort);
      await db.insert(UserRolesTable.tableName,
          {UserRolesTable.colName: Constants.privilegeProvider},
          conflictAlgorithm: ConflictAlgorithm.abort);
      await db.insert(UserRolesTable.tableName,
          {UserRolesTable.colName: Constants.privilegeParent},
          conflictAlgorithm: ConflictAlgorithm.abort);
    });

    print("Tables created.");
  }

  /// Executed upon database upgrade (version change)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    db.transaction((txn) async {
      await txn.execute(SQLQueries.dropAuthTokenTable);
      await txn.execute(SQLQueries.dropUserRolesTable);
      await txn.execute(SQLQueries.dropCentersTable);
      await txn.execute(SQLQueries.dropDiseasesTable);
    });

    print("Tables deleted.");
    await _onCreate(db, newVersion);
  }
}
