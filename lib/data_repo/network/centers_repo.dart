import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/center_cache.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/models/vaccination_center.dart';
import 'package:nvip/utils/network_utils.dart';

class VaccineCentersDataRepo {
  final NetworkUtils _networkUtils = NetworkUtils();
  final CenterCache centerCache = new CenterCache();

  Future<ServerResponse> addCenter(VaccineCenter center) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.centerAdd,
          body: center.toMap(), headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> updateCenter(VaccineCenter center) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.centerUpdate,
          body: center.toMap(), headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> deleteCenter(VaccineCenter center) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.centerDelete,
          body: center.toMap(), headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<List<VaccineCenter>> getCenters() async {
    try {
      List<VaccineCenter> centerList = await centerCache.getCenters();
      if (centerList == null || centerList.isEmpty) {
        var response = await _networkUtils.get(Urls.getVaccineCenters(),
            headers: await Constants.httpHeaders());
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        List netCenters = response[Constants.keyCenters];
        centerList = netCenters
            .map((centerMap) => VaccineCenter.fromMap(centerMap))
            .toList();
        await centerCache.saveAllCenters(centerList);
      }
      return centerList;
    } on Exception catch (err) {
      throw Exception(err.toString());
    }
  }
}
