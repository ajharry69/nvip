import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/data_repo/network/user_repo.dart';
import 'package:nvip/models/article.dart';
import 'package:nvip/models/child.dart';
import 'package:nvip/models/schedule.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/children/screen_children_table.dart';
import 'package:nvip/scenes/home/articles/screen_articles_list.dart';
import 'package:nvip/scenes/home/children/screen_my_children.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_table.dart';
import 'package:nvip/scenes/immunizations/screen_immunizations_table.dart';
import 'package:nvip/scenes/users/screen_users.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _HomeMenuItems { Logout, Settings }

class HomeScreen extends StatelessWidget {
  final String title;
  final Future<List<Schedule>> scheduleList;
  final Future<List<Child>> childrenList;
  final Future<List<Article>> articleList;
  final int positionInTab;

  const HomeScreen({
    Key key,
    this.scheduleList,
    this.childrenList,
    this.articleList,
    this.positionInTab = 0,
    this.title = Constants.appName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _HomeScreenBody(
        title: this.title,
        scheduleList: this.scheduleList,
        childrenList: this.childrenList,
        articleList: this.articleList,
        positionInTab: this.positionInTab,
      );
}

class _HomeScreenBody extends StatefulWidget {
  final String title;
  final Future<List<Schedule>> scheduleList;
  final Future<List<Child>> childrenList;
  final Future<List<Article>> articleList;
  final int positionInTab;

  _HomeScreenBody(
      {Key key,
      this.title,
      this.scheduleList,
      this.childrenList,
      this.articleList,
      this.positionInTab})
      : super(key: key);

  @override
  State createState() => _HomeScreenBodyState(
        title: this.title,
        scheduleList: this.scheduleList,
        childrenList: this.childrenList,
        articleList: this.articleList,
        positionInTab: this.positionInTab,
      );
}

class _HomeScreenBodyState extends State<_HomeScreenBody>
    with SingleTickerProviderStateMixin {
  final String title;
  final Future<List<Schedule>> scheduleList;
  final Future<List<Child>> childrenList;
  final Future<List<Article>> articleList;
  final int positionInTab;
  static int currentTabIndex = 0;

  final Color blueShade800 = Colors.blue.shade800;
  User _user;
  UserCache _userCache;
  Connectivity _connectivity;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  ScrollController _scrollController;

  List<Widget> get tabs => [
        Tab(
          icon: Icon(Icons.record_voice_over),
          text: Constants.tabTitleArticles,
        ),
        Tab(
          icon: Icon(Icons.schedule),
          text: Constants.tabTitleSchedule,
        ),
        Tab(
          icon: Icon(Icons.child_care),
          text: Constants.tabTitleChildren,
        ),
      ];

  _HomeScreenBodyState(
      {this.title,
      this.scheduleList,
      this.childrenList,
      this.articleList,
      this.positionInTab});

  Future<void> _getUserFromCache(UserCache _userCache) async {
    try {
      var user = await _userCache.currentUser;

      setState(() {
        _user = user;
        _tabController = TabController(
            initialIndex: _HomeScreenBodyState.currentTabIndex,
            length: tabs.length,
            vsync: this);
        _tabController.addListener(tabSelectListener);
      });
    } on Exception catch (err) {
      print(Constants.refinedExceptionMessage(err));
    }
  }

  void tabSelectListener() {
    if (_tabController != null) {
      _HomeScreenBodyState.currentTabIndex = _tabController.index;
    }
  }

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _userCache = UserCache();
    _scrollController = ScrollController();
    _getUserFromCache(_userCache);
  }

  @override
  void dispose() {
    if (!_tabController.indexIsChanging) {
      _tabController.removeListener(tabSelectListener);
      _tabController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        drawer: _buildDrawer(context),
        body: buildScaffoldContent(),
      );

  Widget buildScaffoldContent() => NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, isInnerBoxScrolled) {
          var isSignedIn = _user != null;
          return <Widget>[
            SliverAppBar(
              title: Text(
                widget.title,
                textScaleFactor: Dimensions.defaultScaleFactor,
                style: TextStyle(
//                  fontFamily: "Kalam",
                  letterSpacing: 5.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              pinned: true,
              floating: true,
              forceElevated: isInnerBoxScrolled,
              actions: <Widget>[
                IconButton(
                  icon: Icon(isSignedIn ? Icons.exit_to_app : Icons.person_add),
                  tooltip: isSignedIn ? "Signout" : "Sign In / Create Account",
                  onPressed: () {
                    _signOut(context);
                  },
                ),
                PopupMenuButton<_HomeMenuItems>(
                  onSelected: (itemValue) {
                    if (itemValue == _HomeMenuItems.Logout) {
                      _signOut(context);
                    } else if (itemValue == _HomeMenuItems.Settings) {
//                        SystemChannels.platform
//                            .invokeMethod('SystemNavigator.pop');
                    } else {
                      Constants.showSnackBar(_scaffoldKey, "Unknown item");
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<_HomeMenuItems>>[
                        PopupMenuItem<_HomeMenuItems>(
                          value: _HomeMenuItems.Settings,
                          child: ListTile(title: Text("Settings")),
                        ),
                      ],
                )
              ],
              bottom: _tabController != null
                  ? TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      tabs: tabs,
                    )
                  : null,
            ),
          ];
        },
        body: _tabController != null
            ? TabBarView(
                controller: _tabController,
                children: [
                  ArticlesScreen(
                    user: this._user,
                    articlesList: this.articleList,
                    positionInTab: 0,
                  ),
                  SchedulesTableScreen(
                    user: this._user,
                    scheduleList: this.scheduleList,
                    positionInTab: 1,
                  ),
                  MyChildrenScreen(
                    user: this._user,
                    children: this.childrenList,
                    positionInTab: 2,
                  ),
                ],
              )
            : Container(),
      );

  Drawer _buildDrawer(BuildContext context) {
    var userRole = _user?.role;
    var isAdmin = userRole == Constants.privilegeAdmin;
    var isProvider = userRole == Constants.privilegeProvider;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: blueShade800),
        child: ListView(
          children: <Widget>[
            _buildDrawerHeader(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Account Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.keyProfile);
              },
            ),
            isAdmin || isProvider
                ? ListTile(
                    leading: Icon(Icons.list),
                    title: Text("Immunizations Records"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImmunizationsTableScreen(
                                  user: _user,
                                ),
                          ));
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.pie_chart),
                    title: Text("Charts & Reports"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, Routes.keyCharts);
                    },
                  )
                : Container(),
            isAdmin || isProvider
                ? ListTile(
                    leading: Icon(Icons.child_care),
                    title: Text("Children Records"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChildrenTableScreen(
                                    user: _user,
                                  )));
                    },
                  )
                : Container(),
            isAdmin || isProvider
                ? ListTile(
                    leading: Icon(Icons.table_chart),
                    title: Text("Vaccines Records"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyVaccinesTable);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.hdr_weak),
                    title: Text("V-P Diseases Records"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyDiseasesTable);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.people),
                    title: Text("Users Records"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UsersListScreen(
                                  user: _user,
                                )),
                      );
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.place),
                    title: Text("Centers Records"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyPovsTable);
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  DrawerHeader _buildDrawerHeader() {
    String name = "${_user?.sName} ${_user?.fName} ${_user?.lName}"
        .trimLeft()
        .trimRight();
    String email = _user?.email;
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade800,
            Colors.lightBlueAccent,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: CircleAvatar(
              radius: 30.0,
              child: Icon(Icons.person),
              backgroundColor: Theme.of(context).primaryColorLight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.defaultPadding),
            child: Text(
              _user != null ? name : Constants.drawerHeaderName,
              style: TextStyle(
//                fontFamily: "Kalam",
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
              maxLines: 1,
            ),
          ),
          Text(
            _user != null ? email : Constants.drawerHeaderEmail,
            style: TextStyle(
//              fontFamily: "Kalam",
              fontWeight: FontWeight.w400,
              letterSpacing: 2.5,
            ),
          )
        ],
      ),
    );
  }

  Future _signOut(BuildContext context) async {
    try {
      var pref = await SharedPreferences.getInstance();
      await pref.setBool(PreferenceKeys.keySkipSignIn, false);

      var result = await _connectivity.checkConnectivity();

      if (result != ConnectivityResult.none) {
        await UserDataRepo().signOut(_user);
        await _userCache.deleteAllUserTokens();
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (err) {
      Constants.showSnackBar(
          _scaffoldKey, Constants.refinedExceptionMessage(err));
    } finally {
      Navigator.pushReplacementNamed(context, Routes.keySignIn);
    }
  }
}
