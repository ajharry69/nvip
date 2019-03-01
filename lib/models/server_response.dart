import 'package:nvip/constants.dart';

class ServerResponse {
  bool _isError = true;
  String _message;
  dynamic _debugMessage;

  ServerResponse({bool isError = true, String message, dynamic debugMessage}) {
    this._isError = isError;
    this._message = message;
    this._debugMessage = debugMessage;
  }

  ServerResponse.fromMap(dynamic responseMap) {
    this._isError = responseMap[Constants.keyIsError];
    this._message = responseMap[Constants.keyMessage];
    this._debugMessage = responseMap[Constants.keyDebugMsg];
  }

  dynamic get debugMessage => this._debugMessage;

  String get message => this._message;

  bool get isError => this._isError;
}
