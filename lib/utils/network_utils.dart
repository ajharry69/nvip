import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nvip/constants.dart';
import 'package:nvip/exceptions/unauthorized_request.dart';
import 'package:nvip/models/server_response.dart';

class NetworkUtils {
  static NetworkUtils _instance = NetworkUtils.internal();

  NetworkUtils.internal();

  factory NetworkUtils() => _instance;

  final JsonDecoder _jsonDecoder = JsonDecoder();

  Future<dynamic> get(String url, {Map<String, String> headers}) {
    return http
        .get(url, headers: headers)
        .then(
          (http.Response response) => Future(
                () {
                  var responseBody = response.body;
                  var status = response.statusCode;

                  print("Response: $responseBody"); // TODO: Delete...

                  if (status != 200 && json == null) {
                    throw Exception(
                      "Error while fetching data. Please try again.",
                    );
                  }

                  var parsedResponse = _jsonDecoder.convert(responseBody);
                  var sr = ServerResponse.fromMap(parsedResponse);
                  if (sr.debugMessage
                      .toString()
                      .toLowerCase()
                      .contains("401: Token".toLowerCase()))
                    throw UnauthorizedRequestException();

                  return parsedResponse;
                },
              ).catchError((err) => throw Exception(err)),
        )
        .timeout(Duration(seconds: Constants.initialTimeout),
            onTimeout: () =>
                throw Exception("Request time out. Please try again."))
        .catchError(
            (err) => throw Exception(Constants.refinedExceptionMessage(err)));
  }

  Future<dynamic> post(String url,
      {Map<String, String> headers, body, Encoding encoding}) {
    return http
        .post(url, headers: headers, body: body, encoding: encoding)
        .then(
          (http.Response response) => Future(
                () {
                  var responseBody = response.body;
                  var status = response.statusCode;

                  print("Response: $responseBody"); // TODO: Delete...

                  if (status != 200 && json == null) {
                    throw Exception(
                      "Error while fetching data. Please try again.",
                    );
                  }

                  var parsedResponse = _jsonDecoder.convert(responseBody);
                  var sr = ServerResponse.fromMap(parsedResponse);
                  if (sr.debugMessage
                      .toString()
                      .toLowerCase()
                      .contains("401: Token".toLowerCase()))
                    throw UnauthorizedRequestException();

                  return parsedResponse;
                },
              ).catchError((err) => throw Exception(err)),
        )
        .timeout(Duration(seconds: Constants.initialTimeout),
            onTimeout: () =>
                throw Exception("Request time out. Please try again."))
        .catchError((err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    });
  }
}
