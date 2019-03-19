import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/user_repo.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/users/admins/screen_admins.dart';
import 'package:nvip/scenes/users/parents/screen_parents.dart';
import 'package:nvip/scenes/users/providers/screen_providers.dart';

class UsersListScreen extends StatelessWidget {
  final User user;

  const UsersListScreen({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) => _UserListScreenBody(user: this.user);
}

class _UserListScreenBody extends StatefulWidget {
  final User user;

  const _UserListScreenBody({Key key, this.user}) : super(key: key);

  @override
  __UserListScreenBodyState createState() =>
      __UserListScreenBodyState(this.user);
}

class __UserListScreenBodyState extends State<_UserListScreenBody>
    with SingleTickerProviderStateMixin {
  Future<List<User>> _userList;
  final User user;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;

  __UserListScreenBodyState(this.user);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    setState(() {
      _userList = UserDataRepo().getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyHome);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Users"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Admins"),
              Tab(text: "Providers"),
              Tab(text: "Parents"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            AdminsTableScreen(
              userList: getUsersByRole(Constants.privilegeAdmin),
            ),
            ProvidersTableScreen(
              userList: getUsersByRole(Constants.privilegeProvider),
            ),
            ParentsTableScreen(
              userList: getUsersByRole(Constants.privilegeParent),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<User>> getUsersByRole(String role) async {
    try {
      final List<User> adminList = List();
      final List<User> providerList = List();
      final List<User> parentList = List();
      var userList = await _userList;
      for (User user in userList) {
        if (user.role == Constants.privilegeAdmin) {
          adminList.add(user);
        } else if (user.role == Constants.privilegeProvider) {
          providerList.add(user);
        } else {
          parentList.add(user);
        }
      }

      if (role == Constants.privilegeAdmin) {
        return adminList;
      } else if (role == Constants.privilegeProvider) {
        return providerList;
      } else {
        return userList;
      }
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }
}
