import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/models/vaccination_center.dart';
import 'package:nvip/utils/network_utils.dart';

class VaccineCentersDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

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
    return _networkUtils
        .get(Urls.getVaccineCenters(), headers: await Constants.httpHeaders())
        .then(
      (response) {
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        List netCenters = response[Constants.keyCenters];
        return netCenters
            .map((centerMap) => VaccineCenter.fromMap(centerMap))
            .toList();
      },
    ).catchError((err) => throw Exception(err.toString()));
  }
}
