import 'dart:async';
import 'dart:io' as io;

import 'package:nvip/constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    io.Directory docsDir = await getApplicationDocumentsDirectory();
    String path = join(docsDir.path, Constants.dbName);
    Database dbNVIP = await openDatabase(
      path,
      version: Constants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return dbNVIP;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(SQLQueries.createUserTokenTable);
    await db.execute(SQLQueries.createUserRolesTable);

    await db.insert(UserRolesTable.tableName,
        {UserRolesTable.colName: Constants.privilegeAdmin},
        conflictAlgorithm: ConflictAlgorithm.abort);
    await db.insert(UserRolesTable.tableName,
        {UserRolesTable.colName: Constants.privilegeProvider},
        conflictAlgorithm: ConflictAlgorithm.abort);
    await db.insert(UserRolesTable.tableName,
        {UserRolesTable.colName: Constants.privilegeParent},
        conflictAlgorithm: ConflictAlgorithm.abort);

    print("Tables created.");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute(SQLQueries.dropUserRolesTable);

    print("Tables deleted.");
    await _onCreate(db, newVersion);
  }
}
