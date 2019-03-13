import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/schedules_repo.dart';
import 'package:nvip/models/schedule.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_add.dart';
import 'package:nvip/widgets/disease_tags.dart';
import 'package:nvip/widgets/places_tags.dart';

enum _CardMenuItems { update, delete }
enum SortBy { title, startDate, endDate, datePosted }
enum SortOrder { ascending, descending }

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

class _SchedulesTableBodyState extends State<_SchedulesTableBody>
    with AutomaticKeepAliveClientMixin<_SchedulesTableBody> {
  User _user;
  static const padding16dp = Constants.defaultPadding * 2;
  static const tagTitleTextStyle = TextStyle(
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
  );
  var _isRequestSent = false;
  SortBy _sortBy = SortBy.datePosted;
  SortOrder _sortOrder = SortOrder.ascending;
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
              return Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          iconSize: 20,
                          highlightColor: Colors.transparent,
                          tooltip: "Sort",
                          icon: Icon(
                            Icons.sort,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () =>
                              _showSortDialog(context, scheduleList),
                        ),
                        IconButton(
                          iconSize: 20,
                          highlightColor: Colors.transparent,
                          disabledColor: Colors.grey.shade500,
                          tooltip: "Add to calender",
                          icon: Icon(
                            Icons.calendar_today,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 20,
                          highlightColor: Colors.transparent,
                          disabledColor: Colors.grey.shade500,
                          tooltip: "Delete all",
                          icon: Icon(
                            Icons.delete,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 15,
                    child: ListView(
                      padding: EdgeInsets.only(top: 0.0),
                      reverse: scheduleList.length > 15,
                      children:
                          _schedulesWidget(context, scheduleList).toList(),
                    ),
                  ),
                ],
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
                    MaterialPageRoute(
                        builder: (_) => AddScheduleScreen(
                              caller: ScheduleCaller.list,
                            )));
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
//      var datePosted = schedule.datePosted;
      var diseases = schedule.diseases;
      var places = schedule.places;

      yield Card(
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
              title: Text(title, style: Theme.of(context).textTheme.title),
              subtitle: Text(
                "$startDate - $endDate (${DateTime.tryParse(endDate).difference(DateTime.tryParse(startDate)).inDays} days)",
              ),
              trailing: PopupMenuButton<_CardMenuItems>(
                onSelected: (value) {
                  switch (value) {
                    case _CardMenuItems.update:
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddScheduleScreen(
                                    schedule: schedule,
                                    caller: ScheduleCaller.list,
                                  )));
                      break;
                    case _CardMenuItems.delete:
                      Constants.showDeleteDialog(
                        context: context,
                        dialogContent: "Sure you want to delete this post?",
                        doDelete: () async {
                          try {
                            ConnectivityResult cr =
                                await _connectivity.checkConnectivity();
                            if (cr != ConnectivityResult.none) {
                              if (!_isRequestSent) {
                                _isRequestSent = true;
                                var sr = await scheduleDataRepo
                                    .deleteSchedule(schedule);
                                Navigator.of(context).pop();
                                Constants.showSnackBar(
                                    _scaffoldKey, sr.message);
                                setState(() {}); // Refresh page after deleting
                              }
                            } else {
                              Constants.showSnackBar(
                                  _scaffoldKey, Constants.connectionLost,
                                  isNetworkConnected: false);
                            }
                          } on Exception catch (err) {
                            Constants.showSnackBar(_scaffoldKey,
                                Constants.refinedExceptionMessage(err));
                          } finally {
                            _isRequestSent = false;
                          }
                        },
                      );
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
                right: padding16dp,
                left: padding16dp,
              ),
              child: Text("$description"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: padding16dp,
                left: padding16dp,
              ),
              child: Divider(
                color: Colors.grey.shade600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: padding16dp,
                left: padding16dp,
              ),
              child: Text(
                "Diseases",
                style: tagTitleTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: padding16dp,
                left: padding16dp,
              ),
              child: DiseasesChipTags(diseases: diseases),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: padding16dp,
                left: padding16dp,
              ),
              child: Text(
                "Places",
                style: tagTitleTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: padding16dp,
                left: padding16dp,
                bottom: Constants.defaultPadding,
              ),
              child: PlacesChipTags(centers: places),
            ),
          ],
        ),
      );
    }
  }

  void _showSortDialog(BuildContext context, List<Schedule> schedules) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              FlatButton(
                child: Text("Sort"),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _sort<String>(
                      schedules: schedules,
                      getField: (Schedule s) {
                        switch (_sortBy) {
                          case SortBy.title:
                            return s.title;
                          case SortBy.datePosted:
                            return s.datePosted;
                          case SortBy.startDate:
                            return s.startDate;
                          case SortBy.endDate:
                            return s.endDate;
                        }
                      },
                      isAscending: _sortOrder == SortOrder.ascending,
                    );
                  });
                },
              ),
            ],
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RadioListTile<SortBy>(
                    title: Text("Title"),
                    value: SortBy.title,
                    groupValue: _sortBy,
                    onChanged: (sb) {
                      setState(() {
                        _sortBy = sb;
                      });
                    },
                  ),
                  RadioListTile<SortBy>(
                    title: Text("Date posted"),
                    value: SortBy.datePosted,
                    groupValue: _sortBy,
                    onChanged: (sb) {
                      setState(() {
                        _sortBy = sb;
                      });
                    },
                  ),
                  RadioListTile<SortBy>(
                    title: Text("Start date"),
                    value: SortBy.startDate,
                    groupValue: _sortBy,
                    onChanged: (sb) {
                      setState(() {
                        _sortBy = sb;
                      });
                    },
                  ),
                  RadioListTile<SortBy>(
                    title: Text("End date"),
                    value: SortBy.endDate,
                    groupValue: _sortBy,
                    onChanged: (sb) {
                      setState(() {
                        _sortBy = sb;
                      });
                    },
                  ),
                  Row(
                    children: <Widget>[
                      RadioListTile<SortOrder>(
                        title: Text("Ascending"),
                        value: SortOrder.ascending,
                        groupValue: _sortOrder,
                        onChanged: (so) {
                          setState(() {
                            _sortOrder = so;
                          });
                        },
                      ),
                      RadioListTile<SortOrder>(
                        title: Text("Descending"),
                        value: SortOrder.descending,
                        groupValue: _sortOrder,
                        onChanged: (so) {
                          setState(() {
                            _sortOrder = so;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _sort<T>(
      {List<Schedule> schedules,
      Comparable<T> getField(Schedule s),
      bool isAscending}) {
    schedules.sort((s1, s2) {
      if (!isAscending) {
        final Schedule s3 = s1;
        s1 = s2;
        s2 = s3;
      }

      final Comparable<T> aVal = getField(s1);
      final Comparable<T> bVal = getField(s2);
      return Comparable.compare(aVal, bVal);
    });
  }
}
