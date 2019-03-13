import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/data_repo/network/user_repo.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/children/screen_children_table.dart';
import 'package:nvip/scenes/home/children/screen_my_children.dart';
import 'package:nvip/scenes/home/educative/screen_educative_posts.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_table.dart';
import 'package:nvip/scenes/immunizations/screen_immunizations_table.dart';
import 'package:nvip/scenes/users/screen_users.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _HomeMenuItems { Logout, Settings }

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _HomePage(title: Constants.appName);
}

class _HomePage extends StatefulWidget {
  final String title;

  _HomePage({Key key, this.title}) : super(key: key);

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage>
    with SingleTickerProviderStateMixin {
  final Color blueShade700 = Colors.blue.shade700;
  User _user;
  UserCache _userCache;
  Connectivity _connectivity;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _userCache = UserCache();
    _scrollController = ScrollController();
    _userCache.currentUser.then((user) {
      setState(() {
        _user = user;
        _tabController = TabController(length: 3, vsync: this);
      });
    }).catchError((err) => print(Constants.refinedExceptionMessage(err)));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: buildScaffoldContent(),
    );
  }

  Widget buildScaffoldContent() {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, isInnerBoxScrolled) {
        return <Widget>[
          SliverAppBar(
            title: Text(widget.title),
            pinned: true,
            floating: true,
            forceElevated: isInnerBoxScrolled,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                tooltip: "Signout",
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
                    tabs: [
                      Tab(
                        icon: Icon(Icons.record_voice_over),
                        text: Constants.tabTitleEducative,
                      ),
                      Tab(
                        icon: Icon(Icons.schedule),
                        text: Constants.tabTitleSchedule,
                      ),
                      Tab(
                        icon: Icon(Icons.child_care),
                        text: Constants.tabTitleChildren,
                      ),
                    ],
                  )
                : null,
          ),
        ];
      },
      body: _tabController != null
          ? TabBarView(
              controller: _tabController,
              children: [
                EducativePostsScreen(_user),
                SchedulesTableScreen(_user),
                MyChildrenScreen(_user),
              ],
            )
          : Container(),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    var isAdmin = _user?.role == Constants.privilegeAdmin;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: blueShade700),
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
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.list),
                    title: Text("Immunizations"),
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
                    title: Text("Charts"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, Routes.keyCharts);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.people),
                    title: Text("Users"),
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
                    leading: Icon(Icons.child_care),
                    title: Text("Children"),
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
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.table_chart),
                    title: Text("Vaccines"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyVaccinesTable);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.place),
                    title: Text("Centers"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyPovsTable);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(Icons.hdr_weak),
                    title: Text("Diseases"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyDiseasesTable);
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
            padding: const EdgeInsets.only(top: Constants.defaultPadding),
            child: Text(
              _user != null ? name : Constants.drawerHeaderName,
              style: TextStyle(
                fontFamily: "Kalam",
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
              maxLines: 1,
            ),
          ),
          Text(
            _user != null ? email : Constants.drawerHeaderEmail,
            style: TextStyle(
              fontFamily: "Kalam",
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
