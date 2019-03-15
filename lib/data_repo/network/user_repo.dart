import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/utils/network_utils.dart';

class UserDataRepo {
  static final String _keyId = 'uuid';
  static final String _keyVCode = 'vCode';
  static final String _keyUsername = 'username';
  static final String _keyEmail = 'email';
  static final String _keyPassword = 'password';
  static final String _keyTempPassword = 'tempPass';
  static final String _keyNewPassword = 'newPass';
  static final String _keyDeviceId = 'deviceId';
  static final String _keyPROpType = 'op';

  NetworkUtils _networkUtils = NetworkUtils();

  Future<String> signUp(User user, String password) async {
    try {
      var response = await _networkUtils.post(Urls.userSignUp,
          body: user.toMapForSignUp(password));

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      String token = response[Constants.keyToken];
      return token;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<String> signIn(
      String username, String password, String deviceId) async {
    try {
      var response = await _networkUtils.post(Urls.userSignIn, body: {
        _keyUsername: username,
        _keyPassword: password,
        _keyDeviceId: deviceId
      });

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      String token = response[Constants.keyToken];
      return token;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<String> updateProfile(User user, String image) async {
    try {
      var response = await _networkUtils.post(Urls.userUpdateProfile,
          body: user.toMapForProfileUpdate(image: image),
          headers: await Constants.httpHeaders());

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      String token = response[Constants.keyToken];
      return token;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<String> verifyAccount(
      String userId, String vCode, String deviceId) async {
    try {
      var response = await _networkUtils.post(Urls.userVerifyAccount,
          body: {_keyId: userId, _keyVCode: vCode, _keyDeviceId: deviceId},
          headers: await Constants.httpHeaders());

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      String token = response[Constants.keyToken];
      return token;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<String> changePassword(String opType, String email, String tempPass,
      String newPass, String deviceId) async {
    try {
      var response = await _networkUtils.post(Urls.userResetPass, body: {
        _keyPROpType: opType,
        _keyEmail: email,
        _keyTempPassword: tempPass,
        _keyNewPassword: newPass,
        _keyDeviceId: deviceId
      });

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      String token = response[Constants.keyToken];
      return token;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<List<User>> getUsers() async {
    try {
      var response = await _networkUtils.get(Urls.getUsers(),
          headers: await Constants.httpHeaders());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      List list = response[Constants.keyUsers];
      return list.map((userMap) => User.fromMap(userMap)).toList();
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<bool> signOut(User user) async {
    try {
      var response = await _networkUtils.post(Urls.userSignOut,
          body: {_keyId: user != null ? user.id : ""},
          headers: await Constants.httpHeaders());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      return true;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<bool> updateDeviceId(
      [String userId = "", String deviceId = ""]) async {
    try {
      var response = await _networkUtils.post(Urls.userUpdateDeviceId,
          body: {_keyId: userId, _keyDeviceId: deviceId},
          headers: await Constants.httpHeaders());

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      return true;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<bool> removeUser(String userId) async {
    try {
      var response = await _networkUtils.post(Urls.userRemove,
          body: {_keyId: userId}, headers: await Constants.httpHeaders());

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }
      return true;
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<ServerResponse> requestPasswordReset(String email) async {
    try {
      var response = await _networkUtils
          .post(Urls.mailSendTempPass, body: {RestKeys.keyEmail: email});
      return ServerResponse.fromMap(response);
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }
}
