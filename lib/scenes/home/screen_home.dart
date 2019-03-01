import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum _HomeMenuItems { Logout, Exit }

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
  User _user;
  UserCache _userCache;
  Connectivity _connectivity;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _userCache = UserCache();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
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
              } else if (itemValue == _HomeMenuItems.Exit) {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//                SystemNavigator.pop();
              } else {
                Constants.showSnackBar(_scaffoldKey, "Unknown item");
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_HomeMenuItems>>[
                  PopupMenuItem<_HomeMenuItems>(
                    value: _HomeMenuItems.Logout,
                    child: ListTile(
                      title: Text("Signout"),
                    ),
                  ),
                  PopupMenuItem<_HomeMenuItems>(
                    value: _HomeMenuItems.Exit,
                    child: ListTile(
                      title: Text("Exit"),
                    ),
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
      drawer: _buildDrawer(context),
      body: _tabController != null
          ? TabBarView(
              controller: _tabController,
              children: [
                EducativePostsScreen(_user),
                SchedulesTableScreen(_user),
                MyChildrenScreen(_user),
              ],
            )
          : null,
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    var isAdmin = _user?.role == Constants.privilegeAdmin;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).accentColor),
        child: ListView(
          children: <Widget>[
            _buildDrawerHeader(),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.white,
              ),
              title: Text(
                "Account Profile",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.keyProfile);
              },
            ),
            isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.list,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Immunizations",
                      style: TextStyle(color: Colors.white),
                    ),
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
                    leading: Icon(
                      Icons.pie_chart,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Charts",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, Routes.keyCharts);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Users",
                      style: TextStyle(color: Colors.white),
                    ),
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
                    leading: Icon(
                      Icons.child_care,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Children",
                      style: TextStyle(color: Colors.white),
                    ),
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
                    leading: Icon(
                      Icons.table_chart,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Vaccines",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyVaccinesTable);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.place,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Centers",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                          context, Routes.keyPovsTable);
                    },
                  )
                : Container(),
            isAdmin
                ? ListTile(
                    leading: Icon(
                      Icons.hdr_weak,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Diseases",
                      style: TextStyle(color: Colors.white),
                    ),
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
    String name = "${_user?.sName} ${_user?.fName} ${_user?.lName}";
    String email = _user?.email;
    return DrawerHeader(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 30.0,
              child: Icon(Icons.person),
              backgroundColor: Colors.white70,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: Constants.defaultPadding * 2,
                bottom: Constants.defaultPadding,
              ),
              child: Text(
                _user != null ? name : Constants.drawerHeaderName,
                style: TextStyle(fontSize: 16.0, color: Colors.white70),
              ),
            ),
            Text(
              _user != null ? email : Constants.drawerHeaderEmail,
              style: TextStyle(fontSize: 12.0, color: Colors.white70),
            )
          ],
        ),
      ),
      decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
    );
  }

  Future _signOut(BuildContext context) async {
    try {
      var pref = await SharedPreferences.getInstance();
      await pref.setBool(PreferenceKeys.keySkipSignIn, false);

      var result = await _connectivity.checkConnectivity();

      if (result != ConnectivityResult.none) {
        await UserDataRepo().signOut(_user);
        await _userCache.deleteAllUsers();
        await _userCache.deleteAllUserTokens();
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
      Navigator.pushReplacementNamed(context, Routes.keySignIn);
    } on Exception catch (err) {
      Constants.showSnackBar(
          _scaffoldKey, Constants.refinedExceptionMessage(err));
      Navigator.pushReplacementNamed(context, Routes.keySignIn);
    }
  }
}
