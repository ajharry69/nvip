import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/disease_cache.dart';
import 'package:nvip/models/disease.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/utils/network_utils.dart';

class DiseaseDataRepo {
  final NetworkUtils _networkUtils = NetworkUtils();
  final DiseaseCache _diseaseCache = DiseaseCache();

  Future<List<Disease>> addDisease(Disease disease, String userId) async {
    try {
      var response = await _networkUtils.post(Urls.diseaseAdd,
          body: disease.toMap(), headers: await Constants.httpHeaders());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      List<Disease> diseaseList = _getDiseaseListFromServer(response);

      await _diseaseCache.cacheDiseaseList(diseaseList);

      return diseaseList;
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<List<Disease>> updateDisease(Disease disease) async {
    try {
      var response = await _networkUtils.post(Urls.diseaseUpdate,
          body: disease.toMap(), headers: await Constants.httpHeaders());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      List<Disease> diseaseList = _getDiseaseListFromServer(response);

      await _diseaseCache.cacheDiseaseList(diseaseList);

      return diseaseList;
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<List<Disease>> getDiseases() async {
    try {
      List<Disease> diseaseList = await _diseaseCache.getDiseases();

      if (diseaseList == null || diseaseList.isEmpty) {
        var response = await _networkUtils.get(Urls.getDiseases(),
            headers: await Constants.httpHeaders());
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        diseaseList = _getDiseaseListFromServer(response);

        await _diseaseCache.cacheDiseaseList(diseaseList);
      }

      return diseaseList;
    } on Exception catch (err) {
      throw Exception(err.toString());
    }
  }

  List<Disease> _getDiseaseListFromServer(response) {
    List netDiseases = response[Constants.keyDiseases];
    return netDiseases
        .map((diseaseMap) => Disease.fromMap(diseaseMap))
        .toList();
  }
}
