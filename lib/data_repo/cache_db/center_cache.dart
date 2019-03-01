import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/db_helper.dart';
import 'package:nvip/models/vaccination_center.dart';

class CenterCache {
  String _table = CentersTable.tableName;

  Future<int> saveCenters(List<VaccineCenter> centers) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    await deleteAllCenters();

    var res = 0;

    centers.forEach(
        (center) async => res = await clientDb.insert(_table, center.toMap()));
    return res;
  }

  Future<List<VaccineCenter>> getCenters() async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res =
        await clientDb.query(_table, orderBy: "${CentersTable.colName} ASC");
    return res.map((centerMap) => VaccineCenter.fromMap(centerMap)).toList();
  }

  Future<int> updateCenter(VaccineCenter center) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.update(_table, center.toMap(),
        where: "${CentersTable.colId} = ?", whereArgs: [center.id]);
    return res;
  }

  Future<int> deleteCenter(VaccineCenter center) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.delete(_table,
        where: "${CentersTable.colId} = ?", whereArgs: [center.id]);
    return res;
  }

  Future<int> deleteAllCenters() async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.delete(_table);
    return res;
  }
}
