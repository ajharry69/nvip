import 'dart:async';

import 'package:nvip/constants.dart';
import 'package:nvip/models/educative_post.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/utils/network_utils.dart';

class EducativePostDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

  Future<ServerResponse> addPost(EducativePost post) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(Urls.educativeAdd,
          body: post.toMap(), headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> updatePost(EducativePost post) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(
          Urls.educativeUpdate,
          body: post.toMap(),
          headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<ServerResponse> deletePost(EducativePost post) async {
    try {
      return ServerResponse.fromMap(await _networkUtils.post(
          Urls.educativeDelete,
          body: post.toMap(),
          headers: await Constants.httpHeaders()));
    } on Exception catch (err) {
      throw Exception(err);
    }
  }

  Future<List<EducativePost>> getPosts() async {
    try {
      var response = await _networkUtils.get(Urls.getAllEducativePosts(),
          headers: await Constants.httpHeaders());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      List netPosts = response[Constants.keyEducativePosts];
      return netPosts.map((postMap) => EducativePost.fromMap(postMap)).toList();
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<List<EducativePost>> flagOrUnflagPost(PostFlag post) async {
    try {
      var response = await _networkUtils.post(Urls.educativeFlagPost,
          headers: await Constants.httpHeaders(), body: post.toMap());
      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      List netPosts = response[Constants.keyEducativePosts];
      return netPosts.map((postMap) => EducativePost.fromMap(postMap)).toList();
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }
}
