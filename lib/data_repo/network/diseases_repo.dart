import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/models/disease.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/utils/network_utils.dart';

class DiseaseDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

  Future<ServerResponse> addDisease(Disease disease, String userId) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.diseaseAdd,
          body: disease.toMapAdd(userId),
          headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> updateDisease(Disease disease) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.diseaseUpdate,
          body: disease.toMap(), headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<List<Disease>> getDiseases() async {
    return _networkUtils
        .get(Urls.getDiseases(), headers: await Constants.httpHeaders())
        .then(
      (response) {
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        List netDiseases = response[Constants.keyDiseases];
        return netDiseases
            .map((diseaseMap) => Disease.fromMap(diseaseMap))
            .toList();
      },
    ).catchError((err) => throw Exception(err.toString()));
  }
}
