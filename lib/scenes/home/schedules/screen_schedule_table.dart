import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/schedules_repo.dart';
import 'package:nvip/models/schedule.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/home/schedules/screen_schedule_add.dart';
import 'package:nvip/widgets/data_fetch_error_widget.dart';
import 'package:nvip/widgets/disease_tags.dart';
import 'package:nvip/widgets/places_tags.dart';
import 'package:nvip/widgets/token_error_widget.dart';

enum _CardMenuItems { update, delete }
enum SortBy { title, startDate, endDate, datePosted }
enum SortOrder { ascending, descending }

class SchedulesTableScreen extends StatelessWidget {
  final Future<List<Schedule>> scheduleList;
  final User user;
  final int positionInTab;

  const SchedulesTableScreen(
      {Key key, this.scheduleList, this.user, this.positionInTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _SchedulesTableBody(
        positionInTab: this.positionInTab,
        user: this.user,
        scheduleList: this.scheduleList,
      );
}

class _SchedulesTableBody extends StatefulWidget {
  final Future<List<Schedule>> scheduleList;
  final User user;
  final int positionInTab;

  const _SchedulesTableBody(
      {Key key, this.scheduleList, this.user, this.positionInTab})
      : super(key: key);

  @override
  _SchedulesTableBodyState createState() => _SchedulesTableBodyState(
      positionInTab: this.positionInTab,
      user: this.user,
      scheduleList: this.scheduleList);
}

class _SchedulesTableBodyState extends State<_SchedulesTableBody>
    with AutomaticKeepAliveClientMixin<_SchedulesTableBody> {
  final Future<List<Schedule>> scheduleList;
  final User user;
  final int positionInTab;

  static const padding16dp = Dimensions.defaultPadding * 2;
  static const tagTitleTextStyle = TextStyle(
    fontFamily: "Roboto",
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
  );
  static SortBy _sortBy = SortBy.datePosted;
  static SortOrder _sortOrder = SortOrder.ascending;
  var _isRequestSent = false;
  var _isSortOrderAscSelected = true;
  var _isSortOrderDescSelected = false;
  final Connectivity _connectivity = Connectivity();
  final ScheduleDataRepo scheduleDataRepo = ScheduleDataRepo();
  Future<List<Schedule>> _schedules;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  _SchedulesTableBodyState({this.scheduleList, this.positionInTab, this.user});

  @override
  void initState() {
    super.initState();
    _schedules = scheduleDataRepo.getSchedules();
  }

  @override
  Widget build(BuildContext context) {
    var isUserAdmin = user != null && user.role == Constants.privilegeAdmin;
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<List<Schedule>>(
        future: _schedules,
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
              var scheduleList = snapshot.data;
              return Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: padding16dp),
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
                              Icons.event_available,
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
        heroTag: "fab:home:schedule",
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

      const padding16dp = Dimensions.defaultPadding / 2;
      yield Card(
        margin: const EdgeInsets.only(
          top: padding16dp,
          right: Dimensions.defaultPadding,
          left: Dimensions.defaultPadding,
          bottom: padding16dp,
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
                bottom: Dimensions.defaultPadding,
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
                child: Text("Cancel".toUpperCase()),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              FlatButton(
                child: Text("Sort".toUpperCase()),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Sort By",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  RadioListTile<SortBy>(
                    title: Text("Title"),
                    isThreeLine: false,
                    selected: _sortBy == SortBy.title,
                    value: SortBy.title,
                    groupValue: _sortBy,
                    onChanged: _handleSortByValueChange,
                  ),
                  RadioListTile<SortBy>(
                    title: Text("Date posted"),
                    value: SortBy.datePosted,
                    isThreeLine: false,
                    selected: _sortBy == SortBy.datePosted,
                    groupValue: _sortBy,
                    onChanged: _handleSortByValueChange,
                  ),
                  RadioListTile<SortBy>(
                    title: Text("Start date"),
                    isThreeLine: false,
                    selected: _sortBy == SortBy.startDate,
                    value: SortBy.startDate,
                    groupValue: _sortBy,
                    onChanged: _handleSortByValueChange,
                  ),
                  RadioListTile<SortBy>(
                    title: Text("End date"),
                    isThreeLine: false,
                    selected: _sortBy == SortBy.endDate,
                    value: SortBy.endDate,
                    groupValue: _sortBy,
                    onChanged: _handleSortByValueChange,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Sort Order",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Wrap(
                    children: <Widget>[
                      RadioListTile<SortOrder>(
                        title: Text("Ascending"),
                        isThreeLine: false,
                        selected: _isSortOrderAscSelected,
                        value: SortOrder.ascending,
                        groupValue: _sortOrder,
                        onChanged: _handleSortOrderValueChange,
                      ),
                      RadioListTile<SortOrder>(
                        title: Text("Descending"),
                        isThreeLine: false,
                        selected: _isSortOrderDescSelected,
                        value: SortOrder.descending,
                        groupValue: _sortOrder,
                        onChanged: _handleSortOrderValueChange,
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

  void _handleSortByValueChange(SortBy value) {
    setState(() {
      _sortBy = value;

      switch (value) {
        case SortBy.datePosted:
          break;
        case SortBy.endDate:
          break;
        case SortBy.startDate:
          break;
        case SortBy.title:
          break;
      }
    });
  }

  void _handleSortOrderValueChange(SortOrder value) {
    setState(() {
      _sortOrder = value;

      switch (value) {
        case SortOrder.ascending:
          _isSortOrderAscSelected = true;
          _isSortOrderDescSelected = false;
          break;
        case SortOrder.descending:
          _isSortOrderDescSelected = true;
          _isSortOrderAscSelected = false;
          break;
      }
    });
  }

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
