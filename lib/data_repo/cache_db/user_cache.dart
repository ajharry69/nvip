import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/db_helper.dart';
import 'package:nvip/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserCache {
  String _table = UserTable.tableName;

  Future<int> saveUser(User user) async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;

    await deleteAllUsers();

    var res = await dbClient.insert(_table, user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<User> get currentUser async {
    User user;
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    List<Map<String, dynamic>> userList = await dbClient.query(_table);
    userList.forEach((userMap) => user = User.fromMap(userMap));
    return userList.length == 1 ? user : null;
  }

  Future<bool> isAccountVerified() async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    var userList = await dbClient
        .query(_table, where: "${UserTable.colVerified} = ?", whereArgs: [1]);

    return userList.length == 1;
  }

  Future<bool> isSignedIn() async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    var userList = await dbClient.query(_table);

    return userList.length == 1;
  }

  Future<int> updateUser(User user) async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;

    var res = await dbClient.update(_table, user.toMap(),
        where: "${UserTable.colId} = ?", whereArgs: [user.id]);

    return res;
  }

  Future<int> deleteUser(User user) async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    var res = await dbClient
        .delete(_table, where: "${UserTable.colId} = ?", whereArgs: [user.id]);
    return res;
  }

  Future<int> deleteAllUsers() async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    var res = await dbClient.delete(_table);
    return res;
  }

  Future<int> saveUserToken(String token) async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;

    await deleteAllUserTokens();

    var res = await dbClient.insert(
        UserTokenTable.tableName, {UserTokenTable.colToken: token},
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<String> get authToken async {
    String userToken;
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    List<Map<String, dynamic>> userList =
        await dbClient.query(UserTokenTable.tableName);
    userList.forEach((token) => userToken = token[UserTokenTable.colToken]);
    return userList.length == 1 ? userToken : "";
  }

  Future<int> deleteAllUserTokens() async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    var res = await dbClient.delete(UserTokenTable.tableName);
    return res;
  }
}
