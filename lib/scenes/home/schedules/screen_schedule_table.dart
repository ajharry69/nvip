import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/schedules_repo.dart';
import 'package:nvip/models/immunization_schedule.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_add.dart';
import 'package:nvip/widgets/disease_tags.dart';
import 'package:nvip/widgets/places_tags.dart';

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
  var _isRequestSent = false;
  final Connectivity _connectivity = Connectivity();
  final ScheduleDataRepo scheduleDataRepo = ScheduleDataRepo();
  Future<List<Schedule>> _schedules;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  _SchedulesTableBodyState([this._user]);

  @override
  void initState() {
    super.initState();
    _schedules = scheduleDataRepo.getSchedules();
  }

  @override
  Widget build(BuildContext context) {
    var isUserAdmin = _user != null && _user.role == Constants.privilegeAdmin;
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<List<Schedule>>(
        future: _schedules,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Constants.noDataWidget(
              context,
              "${Constants.refinedExceptionMessage(snapshot.error)}. "
                  "Press the button below to add a new post.",
            );
          } else {
            if (snapshot.hasData) {
              var scheduleList = snapshot.data;
              return SingleChildScrollView(
                reverse: scheduleList.length > 15,
                child: Column(
                  children: _schedulesWidget(context, scheduleList).toList(),
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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => AddScheduleScreen()));
              },
              child: Icon(Icons.add),
              tooltip: "Add an immunization schedule",
            )
          : null,
    );
  }

  Iterable<Widget> _schedulesWidget(
      BuildContext context, List<Schedule> schedules) sync* {
    for (var schedule in schedules) {
      var title = schedule.title;
      var description = schedule.description;
      var startDate = schedule.startDate;
      var endDate = schedule.endDate;
      var datePosted = schedule.datePosted;
      var diseases = schedule.diseases;
      var places = schedule.places;

      yield Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(title, style: Theme.of(context).textTheme.title),
              subtitle: Text(
                "$startDate - $endDate (${DateTime.tryParse(endDate).difference(DateTime.tryParse(startDate)).inDays} days)",
              ),
              trailing: PopupMenuButton<_CardMenuItems>(
                onSelected: (value) {
                  switch (value) {
                    case _CardMenuItems.update:
                      // TODO: Show update
                      break;
                    case _CardMenuItems.delete:
                      _doDelete(context, schedule);
                      break;
                  }
                },
                itemBuilder: (ctx) => <PopupMenuEntry<_CardMenuItems>>[
                      PopupMenuItem<_CardMenuItems>(
                        value: _CardMenuItems.update,
                        child: ListTile(
                          title: Text("Update"),
                        ),
                      ),
                      PopupMenuItem<_CardMenuItems>(
                        value: _CardMenuItems.delete,
                        child: ListTile(
                          title: Text("Delete"),
                        ),
                      ),
                    ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: Constants.defaultPadding,
                left: Constants.defaultPadding,
              ),
              child: Text("$description"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: Constants.defaultPadding * 2,
                left: Constants.defaultPadding * 2,
              ),
              child: Divider(
                color: Colors.grey.shade600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: Constants.defaultPadding,
                left: Constants.defaultPadding,
              ),
              child: Text("Diseases"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: Constants.defaultPadding,
                left: Constants.defaultPadding,
              ),
              child: DiseasesChipTags(diseases: diseases),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: Constants.defaultPadding,
                left: Constants.defaultPadding,
              ),
              child: Text("Places"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: Constants.defaultPadding,
                left: Constants.defaultPadding,
              ),
              child: PlacesChipTags(centers: places),
            ),
          ],
        ),
      );
    }
  }

  void _doDelete(BuildContext context, Schedule schedule) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text(
              "Confirm!",
              style: Theme.of(ctx).textTheme.title,
            ),
            content: Text("Sure you want to delete this schedule?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              FlatButton(
                child: Text("Delete"),
                onPressed: () async {
                  try {
                    ConnectivityResult cr =
                        await _connectivity.checkConnectivity();
                    if (cr != ConnectivityResult.none) {
                      var sr = await scheduleDataRepo.deleteSchedule(schedule);
                      Navigator.of(ctx).pop();
                      Constants.showSnackBar(_scaffoldKey, sr.message);
                      setState(() {}); // Refresh page after deleting
                    } else {
                      Constants.showSnackBar(
                          _scaffoldKey, Constants.connectionLost,
                          isNetworkConnected: false);
                    }
                  } on Exception catch (err) {
                    Constants.showSnackBar(
                        _scaffoldKey, Constants.refinedExceptionMessage(err));
                  } finally {
                    _isRequestSent = false;
                  }
                },
              )
            ],
          ),
    );
  }
}

enum _CardMenuItems { update, delete }
