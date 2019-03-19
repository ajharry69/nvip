import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/educative_posts_repo.dart';
import 'package:nvip/models/educative_post.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/home/educative/screen_educative_post_add.dart';
import 'package:nvip/scenes/home/educative/screen_educative_post_details.dart';
import 'package:nvip/widgets/data_fetch_error_widget.dart';
import 'package:nvip/widgets/post_image_widget.dart';
import 'package:nvip/widgets/token_error_widget.dart';

enum _CardMenuItems { update, delete }

class EducativePostsScreen extends StatelessWidget {
  final User _user;

  EducativePostsScreen([this._user]);

  @override
  Widget build(BuildContext context) => _EducativePostsBody(_user);
}

class _EducativePostsBody extends StatefulWidget {
  final User _user;

  _EducativePostsBody([this._user]);

  @override
  __EducativePostsBodyState createState() => __EducativePostsBodyState(_user);
}

class __EducativePostsBodyState extends State<_EducativePostsBody>
    with AutomaticKeepAliveClientMixin<_EducativePostsBody> {
  var _isRequestSent = false;
  final _connectivity = Connectivity();
  EducativePostDataRepo _educativePostDataRepo;
  final accountError =
      "You need to have an ${Constants.appName} account and signed in to flag"
      " a post. Would you like to sign in or create an ${Constants.appName}"
      " account?";
  final defaultPadding = const EdgeInsets.only(
    right: Constants.defaultPadding * 2,
    left: Constants.defaultPadding * 2,
    bottom: Constants.defaultPadding,
  );
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<EducativePost>> _posts;
  User _user;

  __EducativePostsBodyState([this._user]);

  Iterable<Widget> _postsWidget(BuildContext context, List<EducativePost> posts,
      bool isPrivileged) sync* {
    for (var post in posts) {
      var isFlaggedInappropriate =
          _user != null && post.flaggers.contains(_user.id);
      yield GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => EducativePostDetailsScreen(
                        post: post,
                        user: _user,
                      )));
        },
        child: Card(
          margin: const EdgeInsets.only(
            top: Constants.defaultPadding / 2,
            right: Constants.defaultPadding,
            left: Constants.defaultPadding,
            bottom: Constants.defaultPadding / 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade500,
                  child: loadNetworkImage(post.ownerImageUrl),
                ),
                title: Text(post.ownerName),
                subtitle: Text(post.datePosted),
                trailing: Wrap(
                  alignment: WrapAlignment.end,
                  runAlignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: <Widget>[
                    IconButton(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4.0),
                      tooltip: isFlaggedInappropriate
                          ? "Flag as apropriate"
                          : "Flag as inapropriate",
                      icon: Icon(Icons.flag,
                          color: isFlaggedInappropriate
                              ? Colors.redAccent
                              : Colors.grey.shade600),
                      onPressed: _isRequestSent
                          ? null
                          : () {
                              setState(() {
                                flagOrUnflagPost(post);
                              });
                            },
                    ),
                    PopupMenuButton<_CardMenuItems>(
                      onSelected: (value) {
                        switch (value) {
                          case _CardMenuItems.update:
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEducativePostScreen(
                                        educativePost: post,
                                      ),
                                ));
                            break;
                          case _CardMenuItems.delete:
                            deletePost(isPrivileged, context, post);
                            break;
                        }
                      },
                      itemBuilder: (ctx) => <PopupMenuEntry<_CardMenuItems>>[
                            PopupMenuItem<_CardMenuItems>(
                              value: _CardMenuItems.update,
                              child: Text("Update"),
                            ),
                            PopupMenuItem<_CardMenuItems>(
                              value: _CardMenuItems.delete,
                              child: Text("Delete"),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
              CustomFadeInImageView(imageUrl: post.imageUrl),
              Padding(
                padding:
                    defaultPadding.copyWith(top: Constants.defaultPadding * 2),
                child: Text(
                  post.title,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.title.merge(TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      )),
                ),
              ),
              Padding(
                padding: defaultPadding,
                child: Text(
                  post.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future deletePost(
      bool isPrivileged, BuildContext context, EducativePost post) async {
    if (isPrivileged) {
      Constants.showDeleteDialog(
        context: context,
        dialogContent: "Sure you want to delete this post?",
        doDelete: () async {
          try {
            ConnectivityResult cr = await _connectivity.checkConnectivity();
            if (cr != ConnectivityResult.none) {
              if (!_isRequestSent) {
                _isRequestSent = true;
                var sr = await _educativePostDataRepo.deletePost(post);
                Navigator.of(context).pop();
                Constants.showSnackBar(_scaffoldKey, sr.message);
                setState(() {}); // Refresh page after deleting
              }
            } else {
              Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
                  isNetworkConnected: false);
            }
          } on Exception catch (err) {
            Constants.showSnackBar(
                _scaffoldKey, Constants.refinedExceptionMessage(err));
          } finally {
            _isRequestSent = false;
          }
        },
      );
    } else {
      _user == null
          ? signInRequest()
          : Constants.showSnackBar(_scaffoldKey,
              "Administrative privileges are required to delete a post");
    }
  }

  @override
  void initState() {
    super.initState();
    _educativePostDataRepo = EducativePostDataRepo();
    _posts = _educativePostDataRepo.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    var isUserAdmin = _user != null && _user.role == Constants.privilegeAdmin;
    var isUserProvider =
        _user != null && _user.role == Constants.privilegeProvider;
    var isPrivileged = isUserAdmin || isUserProvider;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: FutureBuilder<List<EducativePost>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            var errorMessage =
                "${Constants.refinedExceptionMessage(snapshot.error)}. "
                "Press the button below to add a new post.";

            var isTokenError =
                snapshot.error.toString().contains(Constants.tokenErrorType);

            return isTokenError
                ? TokenErrorWidget()
                : DataFetchErrorWidget(message: errorMessage);
          } else {
            if (snapshot.hasData) {
              var postList = snapshot.data;
//              return ListView(
//                reverse: true,
//                padding: const EdgeInsets.only(top: 0.0),
//                children:
//                    _postsWidget(context, postList, isPrivileged).toList(),
//              );
              return SingleChildScrollView(
                reverse: false,
                child: Column(
                  children:
                      _postsWidget(context, postList, isPrivileged).toList(),
                ),
              );
            }
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: isPrivileged
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AddEducativePostScreen()),
                );
              },
              child: Icon(Icons.add),
              tooltip: "Add an educative post",
            )
          : null,
    );
  }

  void flagOrUnflagPost(EducativePost post) async {
    try {
      if (_user != null) {
        ConnectivityResult cr = await _connectivity.checkConnectivity();
        if (cr != ConnectivityResult.none) {
          if (!_isRequestSent) {
            _isRequestSent = true;

            setState(() {
              _posts = _educativePostDataRepo
                  .flagOrUnflagPost(PostFlag.withNamedParams(postId: post.id));
            }); // Refresh page after deleting
          }
        } else {
          Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
              isNetworkConnected: false);
        }
      } else {
        signInRequest();
      }
    } on Exception catch (err) {
      Constants.showSnackBar(
          _scaffoldKey, Constants.refinedExceptionMessage(err));
    } finally {
      _isRequestSent = false;
    }
  }

  void signInRequest() {
    Constants.showSignInRequestDialog(
        ctx: context,
        message: accountError,
        denialButtonText: "No",
        acceptanceButtonText: "Yes");
  }

  Widget loadNetworkImage(String url) {
    try {
      if (url.isEmpty || url == null) throw Exception("Image URL missing");
      return FadeInImage.assetNetwork(
        placeholder: "images/avator.png",
        image: url,
      );
    } on Exception catch (_) {
      return Icon(
        Icons.person,
        color: Colors.white,
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
