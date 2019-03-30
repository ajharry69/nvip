import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/db_helper.dart';
import 'package:nvip/models/vaccination_center.dart';
import 'package:sqflite/sqflite.dart';

class CenterCache {
  String _table = CentersTable.tableName;

  Future<int> saveAllCenters(List<VaccineCenter> centers) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    await deleteAllCenters();

    var res = 0;

    centers.forEach((center) async => res = await clientDb.insert(
        _table, center.toMapForCaching(),
        conflictAlgorithm: ConflictAlgorithm.replace));
    return res;
  }

  Future<int> saveCenter(VaccineCenter center) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    await deleteCenter(center);
    return await clientDb.insert(_table, center.toMapForCaching());
  }

  Future<List<VaccineCenter>> getCenters() async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res =
        await clientDb.query(_table, orderBy: "${CentersTable.colCounty} ASC");
    return res
        .map((centerMap) => VaccineCenter.fromCacheMap(centerMap))
        .toList();
  }

  Future<int> updateCenter(VaccineCenter center) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.update(_table, center.toMapForCaching(),
        where: "${CentersTable.colCounty} = ?", whereArgs: [center.county]);
    return res;
  }

  Future<int> deleteCenter(VaccineCenter center) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.delete(_table,
        where: "${CentersTable.colCounty} = ?", whereArgs: [center.county]);
    return res;
  }

  Future<int> deleteAllCenters() async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.delete(_table);
    return res;
  }
}
