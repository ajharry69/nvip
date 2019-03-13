import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/models/schedule.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/utils/network_utils.dart';

class ScheduleDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

  Future<ServerResponse> addSchedule(Schedule schedule) async {
    try {
      var response = await _networkUtils.post(Urls.scheduleAdd,
          headers: await Constants.httpHeaders(), body: schedule.toMap());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      return sr;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<ServerResponse> updateSchedule(Schedule schedule) async {
    try {
      var response = await _networkUtils.post(Urls.scheduleUpdate,
          headers: await Constants.httpHeaders(), body: schedule.toMap());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      return sr;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<ServerResponse> deleteSchedule(Schedule schedule) async {
    try {
      var response = await _networkUtils.post(Urls.scheduleDelete,
          headers: await Constants.httpHeaders(), body: schedule.toMap());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      return sr;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<List<Schedule>> getSchedules() async {
    try {
      var response = await _networkUtils.get(Urls.getAllSchedules(),
          headers: await Constants.httpHeaders());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      List networkSchedules = response[Constants.keySchedules];
      return networkSchedules
          .map((scheduleMap) => Schedule.fromMap(scheduleMap))
          .toList();
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }
}
