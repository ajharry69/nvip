import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/models/child.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/utils/network_utils.dart';

class ChildrenDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

  Future<Child> registerChild(Child child) async {
    return _networkUtils
        .post(Urls.childRegister,
            body: child.toMap(), headers: await Constants.httpHeaders())
        .then(
      (response) {
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        return Child.fromMap(response[Constants.keyChild]);
      },
    ).catchError((err) => throw Exception(err.toString()));
  }

  Future<Child> updateChild(Child child) async {
    return _networkUtils
        .post(Urls.childUpdate,
            body: child.toMap(), headers: await Constants.httpHeaders())
        .then(
      (response) {
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        return Child.fromMap(response[Constants.keyChild]);
      },
    ).catchError((err) => throw Exception(err.toString()));
  }

  Future<List<Child>> getChildren(
      {String no = Constants.childrenRecNoAll}) async {
    return _networkUtils
        .get(Urls.getChildren(no: no), headers: await Constants.httpHeaders())
        .then(
      (response) {
        var sr = ServerResponse.fromMap(response);

        if (sr.isError) {
          print(sr.debugMessage);
          throw Exception(sr.message);
        }
        List netChildren = response[Constants.keyChildren];
        return netChildren.map((childMap) => Child.fromMap(childMap)).toList();
      },
    ).catchError((err) => throw Exception(err.toString()));
  }
}
