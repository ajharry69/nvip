import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/models/immunization.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/utils/network_utils.dart';

class ImmunizationDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

  Future<ServerResponse> addImmunization(Immunization immunization) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(
          Urls.immunizationAdd,
          body: immunization.toMap(),
          headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> updateImmunization(Immunization immunization) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(
          Urls.immunizationUpdate,
          body: immunization.toMap(),
          headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> deleteImmunization(Immunization immunization) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(
          Urls.immunizationDelete,
          body: immunization.toMap(),
          headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<List<Immunization>> getImmunizations(
      [String no = Constants.immunizationRecNoAll]) async {
    return _networkUtils
        .get(
            Urls.getImmunizations(
                userId: (await UserCache().currentUser).id, no: no),
            headers: await Constants.httpHeaders())
        .then(
      (response) {
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        List netImmunizations = response[Constants.keyImmunizations];
        return netImmunizations
            .map((immunizationMap) => Immunization.fromMap(immunizationMap))
            .toList();
      },
    ).catchError((err) => throw Exception(err.toString()));
  }
}
