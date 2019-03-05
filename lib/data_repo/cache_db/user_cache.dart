import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/db_helper.dart';
import 'package:nvip/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserCache {
  Future<User> get currentUser async =>
      Constants.getUserFromToken(await authToken);

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

  Future<bool> isAccountVerified() async =>
      await isSignedIn() && (await currentUser).isVerified;

  Future<bool> isSignedIn() async => await currentUser != null;
}
