import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/db_helper.dart';
import 'package:nvip/models/disease.dart';

class DiseaseCache {
  String _table = DiseasesTable.tableName;

  Future<int> saveDisease(Disease disease) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.insert(_table, disease.toMap());
    return res;
  }

  Future<List<Disease>> getDiseases() async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res =
        await clientDb.query(_table, orderBy: "${DiseasesTable.colName} ASC");
    return res.map((diseaseMap) => Disease.fromMap(diseaseMap)).toList();
  }

  Future<int> updateDisease(Disease disease) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = clientDb.update(_table, disease.toMap(),
        where: "${DiseasesTable.colId} = ?", whereArgs: [disease.id]);
    return res;
  }

  Future<int> deleteDisease(Disease disease) async {
    DbHelper helper = DbHelper();
    var clientDb = await helper.db;

    var res = await clientDb.update(_table, disease.toMap(),
        where: "${DiseasesTable.colId} = ?", whereArgs: [disease.id]);
    return res;
  }
}
