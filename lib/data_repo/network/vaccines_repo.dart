import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/models/vaccine.dart';
import 'package:nvip/utils/network_utils.dart';

class VaccineDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

  Future<ServerResponse> addVaccine(Vaccine vaccine) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.vaccineAdd,
          body: vaccine.toMap(), headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> updateVaccine(Vaccine vaccine) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.vaccineUpdate,
          body: vaccine.toMap(), headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<List<Vaccine>> getVaccines() async {
    return _networkUtils
        .get(Urls.getVaccines(), headers: await Constants.httpHeaders())
        .then(
      (response) {
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        List netVaccines = response[Constants.keyVaccines];
        return netVaccines
            .map((vaccineMap) => Vaccine.fromMap(vaccineMap))
            .toList();
      },
    ).catchError((err) => throw Exception(err.toString()));
  }
}
