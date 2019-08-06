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
        AuthTokenTable.tableName, {AuthTokenTable.colToken: token},
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<String> get authToken async {
    String userToken;
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    List<Map<String, dynamic>> userList =
        await dbClient.query(AuthTokenTable.tableName);
    userList.forEach((token) => userToken = token[AuthTokenTable.colToken]);
    return userList.length == 1 ? userToken : "";
  }

  Future<int> deleteAllUserTokens() async {
    DbHelper helper = DbHelper();
    var dbClient = await helper.db;
    var res = await dbClient.delete(AuthTokenTable.tableName);
    return res;
  }

  /// User's account is checked for verification status iff he's passed the
  /// <code>isSignedIn()</code> check
  Future<bool> isAccountVerified() async =>
      await isSignedIn() && (await currentUser).isVerified;

  /// Returns <code>true</code> iff the user is not null
  Future<bool> isSignedIn() async => await currentUser != null;
}
