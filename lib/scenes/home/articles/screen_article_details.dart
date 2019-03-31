import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/educative_posts_repo.dart';
import 'package:nvip/models/article.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/home/screen_home.dart';
import 'package:nvip/widgets/post_image_widget.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article post;
  final User user;

  const ArticleDetailsScreen({Key key, this.post, this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _ArticleDetailsScreenBody(
        post: post,
        user: user,
      );
}

class _ArticleDetailsScreenBody extends StatefulWidget {
  final Article post;
  final User user;

  const _ArticleDetailsScreenBody({Key key, this.post, this.user})
      : super(key: key);

  @override
  _ArticleDetailsScreenBodyState createState() =>
      _ArticleDetailsScreenBodyState(user, post);
}

class _ArticleDetailsScreenBodyState extends State<_ArticleDetailsScreenBody> {
  bool _isRequestSent = false;
  EducativePostDataRepo _educativePostDataRepo;
  final accountError =
      "You need to have an ${Constants.appName} account and signed in to flag"
      " a post. Would you like to sign in or create an ${Constants.appName}"
      " account?";
  final defaultPadding = const EdgeInsets.only(
    right: Dimensions.defaultPadding * 2,
    left: Dimensions.defaultPadding * 2,
    bottom: Dimensions.defaultPadding,
  );
  Article post;
  final User _user;
  final _connectivity = Connectivity();
  final GlobalKey _scaffoldKey = new GlobalKey<ScaffoldState>();

  _ArticleDetailsScreenBodyState(this._user, this.post);

  @override
  void initState() {
    super.initState();
    _educativePostDataRepo = EducativePostDataRepo();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var luminance = theme.iconTheme.color.computeLuminance();
    var isBackGroundDark = luminance <= 0.5;
    var isFlaggedInappropriate =
        _user != null && post.flaggers.contains(_user.id);
    var isUserAdmin = _user != null && _user.role == Constants.privilegeAdmin;
    var isUserProvider =
        _user != null && _user.role == Constants.privilegeProvider;
    var isPrivileged = isUserAdmin || isUserProvider;
    var textTheme = theme.textTheme;
    return WillPopScope(
      onWillPop: () {
        // On Back pressed
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
          headerSliverBuilder: (context, isInnerBoxScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 230.0,
                title: Text(
                  post.title,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: textTheme.title.merge(TextStyle(
                      color: isBackGroundDark
                          ? Colors.white
                          : Colors.grey.shade800,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700)),
                ),
                flexibleSpace: FlexibleSpaceBar(
                    background: CustomFadeInImageView(imageUrl: post.imageUrl)),
                leading: IconButton(
                  tooltip: "Back",
                  icon: Icon(
                    Icons.arrow_back,
                    color:
                        isBackGroundDark ? Colors.white : Colors.grey.shade800,
                  ),
                  onPressed: () {
                    // On back pressed
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    alignment: Alignment.center,
                    tooltip: isFlaggedInappropriate
                        ? "Flag as apropriate"
                        : "Flag as inapropriate",
                    icon: Icon(Icons.flag,
                        color: isFlaggedInappropriate
                            ? Colors.redAccent
                            : isBackGroundDark
                                ? Colors.white
                                : Colors.grey.shade800),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              flagOrUnflagPost();
                            });
                          },
                  ),
                  IconButton(
                    alignment: Alignment.center,
                    tooltip: "Delete post",
                    icon: Icon(
                      Icons.delete,
                      color: isBackGroundDark
                          ? Colors.white
                          : Colors.grey.shade800,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              deletePost(isPrivileged);
                            });
                          },
                  ),
                ],
              )
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: defaultPadding.copyWith(
                      top: Dimensions.defaultPadding * 2),
                  child: Text(
                    post.title,
                    textAlign: TextAlign.start,
                    style: textTheme.display1.merge(
                      TextStyle(
                        fontFamily: "Roboto",
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: defaultPadding,
                  child: Text(
                    post.description,
                    textAlign: TextAlign.justify,
                    style: textTheme.body2.merge(TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void flagOrUnflagPost() async {
    try {
      if (_user != null) {
        ConnectivityResult cr = await _connectivity.checkConnectivity();
        if (cr != ConnectivityResult.none) {
          if (!_isRequestSent) {
            _isRequestSent = true;

            List<Article> _posts = await _educativePostDataRepo
                .flagOrUnflagPost(PostFlag.withNamedParams(postId: post.id));

            for (var p in _posts) {
              if (p.id == post.id) {
                setState(() {
                  post = p; // Refresh page after flagging post
                });
                break;
              }
            }
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

  void deletePost(bool isPrivileged) async {
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
                await _educativePostDataRepo.deletePost(post);
                Navigator.of(context).pop();
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

  void signInRequest() {
    Constants.showSignInRequestDialog(
        ctx: context,
        message: accountError,
        denialButtonText: "No",
        acceptanceButtonText: "Yes");
  }
}
