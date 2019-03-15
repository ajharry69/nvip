import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/user_repo.dart';
import 'package:nvip/models/user.dart';

abstract class AuthContract {
  void onSignInSuccess(String authToken);

  void onSignInFailed(String error);
}

class AuthPresenter {
  String deviceId = Constants.defaultDeviceToken;
  AuthContract _authContract;
  UserDataRepo _userDataRepo = UserDataRepo();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  AuthPresenter(this._authContract) {
    _firebaseMessaging.getToken().then(
      (token) {
        Future(() {
          deviceId = token;
        }).catchError((err) => throw Exception(err));
      },
      onError: (err) => throw Exception(err),
    ).catchError((err) => print(
        "Token Retrieval Error: ${Constants.refinedExceptionMessage(err)}"));
  }

  void signUp(User user, String password) async {
    try {
      _authContract.onSignInSuccess(await _userDataRepo.signUp(user, password));
    } on Exception catch (e) {
      _authContract.onSignInFailed(Constants.refinedExceptionMessage(e));
    }
  }

  void signIn(String username, String password) async {
    try {
      _authContract.onSignInSuccess(
        await _userDataRepo.signIn(username, password, deviceId),
      );
    } on Exception catch (e) {
      _authContract.onSignInFailed(Constants.refinedExceptionMessage(e));
    }
  }

  void verifyAccount(String userId, String vCode) async {
    try {
      _authContract.onSignInSuccess(
        await _userDataRepo.verifyAccount(userId, vCode, deviceId),
      );
    } on Exception catch (e) {
      _authContract.onSignInFailed(Constants.refinedExceptionMessage(e));
    }
  }

  void changePassword(
      String opType, String email, String tempPass, String newPass) async {
    try {
      _authContract.onSignInSuccess(
        await _userDataRepo.changePassword(
            opType, email, tempPass, newPass, deviceId),
      );
    } on Exception catch (e) {
      _authContract.onSignInFailed(Constants.refinedExceptionMessage(e));
    }
  }
}
