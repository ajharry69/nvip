import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/educative_posts_repo.dart';
import 'package:nvip/models/educative_post.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/home/educative/screen_educative_post_add.dart';

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
  final defaultImage = "images/no_image.png";
  final imageHeight = 194.0;
  final defaultPadding = const EdgeInsets.only(
    right: Constants.defaultPadding * 2,
    left: Constants.defaultPadding * 2,
    bottom: Constants.defaultPadding,
  );
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<EducativePost>> _posts;
  User _user;

  __EducativePostsBodyState([this._user]);

  Iterable<Widget> _postsWidget(
      BuildContext context, List<EducativePost> posts) sync* {
    for (var post in posts) {
      yield GestureDetector(
        onTap: () {
          // TODO: Add view functionality...
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
                      tooltip: "Flag as inapropriate",
                      icon: Icon(Icons.flag),
                      onPressed: () {
                        // TODO: Add flag inappropriate post...
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
              post.imageUrl != null
                  ? FadeInImage.assetNetwork(
                      placeholder: defaultImage,
                      image: post.imageUrl,
                      width: double.maxFinite,
                      height: imageHeight,
                      fit: BoxFit.fill,
                    )
                  : Image.asset(
                      defaultImage,
                      width: double.maxFinite,
                      height: imageHeight,
                      fit: BoxFit.fill,
                    ),
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

  @override
  void initState() {
    super.initState();
    _posts = EducativePostDataRepo().getPosts();
  }

  @override
  Widget build(BuildContext context) {
    var isUserAdmin = _user != null && _user.role == Constants.privilegeAdmin;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: FutureBuilder<List<EducativePost>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Constants.noDataWidget(
                context,
                "${Constants.refinedExceptionMessage(snapshot.error)}. "
                "Press the button below to add a new post.");
          } else {
            if (snapshot.hasData) {
              var postList = snapshot.data;
              return SingleChildScrollView(
                reverse: postList.length > 15,
                child: Column(
                  children: _postsWidget(context, postList).toList(),
                ),
              );
            }
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: isUserAdmin
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
