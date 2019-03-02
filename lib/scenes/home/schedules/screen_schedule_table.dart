import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_add.dart';

class SchedulesTableScreen extends StatelessWidget {
  final User _user;

  SchedulesTableScreen([this._user]);

  @override
  Widget build(BuildContext context) {
    return _SchedulesTableBody(_user);
  }
}

class _SchedulesTableBody extends StatefulWidget {
  final User _user;

  _SchedulesTableBody([this._user]);

  @override
  _SchedulesTableBodyState createState() => _SchedulesTableBodyState(_user);
}

class _SchedulesTableBodyState extends State<_SchedulesTableBody> {
  User _user;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  _SchedulesTableBodyState([this._user]);

  @override
  Widget build(BuildContext context) {
    var isUserAdmin = _user != null && _user.role == Constants.privilegeAdmin;
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Text("Immunization Schedules will appear here"),
      ),
      floatingActionButton: isUserAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => AddScheduleScreen()));
              },
              child: Icon(Icons.add),
              tooltip: "Add an immunization schedule",
            )
          : null,
    );
  }
}
