import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/schedules_repo.dart';
import 'package:nvip/models/schedule.dart';
import 'package:nvip/widgets/diseases_filter.dart';
import 'package:nvip/widgets/places_filter.dart';

enum ScheduleCaller { dashboard, list }

class AddScheduleScreen extends StatelessWidget {
  final Schedule schedule;
  final ScheduleCaller caller;

  const AddScheduleScreen({Key key, this.schedule, this.caller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _ScheduleScreenBody(
        schedule: schedule,
        caller: caller,
      );
}

class _ScheduleScreenBody extends StatefulWidget {
  final Schedule schedule;
  final ScheduleCaller caller;

  const _ScheduleScreenBody({Key key, this.schedule, this.caller})
      : super(key: key);

  @override
  __ScheduleScreenBodyState createState() =>
      __ScheduleScreenBodyState(schedule, caller);
}

class __ScheduleScreenBodyState extends State<_ScheduleScreenBody> {
  final List<String> diseaseFilters = List();
  final List<String> placesFilters = List();
  final Schedule schedule;
  final ScheduleCaller caller;
  var _isRequestSent = false;
  static final oneDayDuration = Duration(days: 1);
  final firstStartDate = DateTime.now().add(oneDayDuration);
  final dateFormat = DateFormat(Constants.defaultDateFormat);
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _titleController,
      _startDateController,
      _endDateController,
      _descController;

  __ScheduleScreenBodyState(this.schedule, this.caller);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _descController = TextEditingController();

    _startDateController.text = dateFormat.format(firstStartDate);

    if (schedule != null) {
      _titleController.text = schedule.title;
      _startDateController.text = schedule.startDate;
      _endDateController.text = schedule.endDate;
      _descController.text = schedule.description;
      schedule.diseases.forEach((d) => diseaseFilters.add("$d"));
      schedule.places.forEach((p) => placesFilters.add("$p"));
    }

    _setEndDate(_startDateController.text);
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descController.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () {
          Navigator.pushReplacementNamed(context, Routes.keyHome);
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Constants.backIcon),
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.keyHome);
              },
            ),
            title: Text("Add Immunization Schedule"),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.defaultPadding * 4,
                left: Dimensions.defaultPadding * 4,
                right: Dimensions.defaultPadding * 4,
                bottom: Dimensions.defaultPadding * 2,
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: Dimensions.defaultPadding),
                    child: TextFormField(
                      controller: _titleController,
                      validator: (String title) {
                        if (title.isEmpty) {
                          return 'Title is required';
                        } else if (title.length > 150) {
                          return 'Characters count should be less than 151';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.defaultPadding * 2,
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: _startDateController,
                      enabled: true,
                      autovalidate: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date*',
                        helperText:
                            "date immunization process is to start in YYYY-MM-DD pattern",
                        suffixIcon: IconButton(
                            icon: Icon(Icons.date_range),
                            onPressed: () async {
                              try {
                                String date =
                                    DateFormat(Constants.defaultDateFormat)
                                        .format(
                                  await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _startDateController.text != null
                                                ? DateTime.tryParse(
                                                    _startDateController.text)
                                                : firstStartDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(Duration(days: 365 * 3)),
                                      ) ??
                                      DateTime.tryParse(
                                          _startDateController.text),
                                );

                                setState(() {
                                  _startDateController.text = date;
                                  _setEndDate(date);
                                });
                              } on Exception catch (err) {
                                print(Constants.refinedExceptionMessage(err));
                              }
                            }),
                      ),
                      onFieldSubmitted: (val) {
                        _setEndDate(val);
                      },
                      onSaved: (val) {
                        _setEndDate(val);
                      },
                      validator: (String val) {
                        var errDateRequired =
                            "immunization start date is required";
                        var errVaccineExpired =
                            "immunization start date is past or too soon";

                        try {
                          return Constants.isDateAndFormatCorrect(
                              date: val,
                              emptyDateMessage: errDateRequired,
                              customMessage: errVaccineExpired,
                              isTrue: DateTime.tryParse(val)
                                      .millisecondsSinceEpoch <
                                  DateTime.now().millisecondsSinceEpoch);
                        } on NoSuchMethodError {
                          return Constants.errInvalidDate;
                        } catch (err) {
                          return Constants.refinedExceptionMessage(err);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.defaultPadding * 2,
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: _endDateController,
                      enabled: true,
                      autovalidate: true,
                      decoration: InputDecoration(
                        labelText: 'End Date*',
                        helperText:
                            "date immunization process is to end in YYYY-MM-DD pattern",
                        suffixIcon: IconButton(
                            icon: Icon(Icons.date_range),
                            onPressed: () async {
                              try {
                                var duration = Duration(days: 5);
                                String date =
                                    DateFormat(Constants.defaultDateFormat)
                                        .format(
                                  await showDatePicker(
                                        context: context,
                                        initialDate: _endDateController.text !=
                                                null
                                            ? DateTime.tryParse(
                                                _endDateController.text)
                                            : _startDateController.text != null
                                                ? DateTime.tryParse(
                                                        _startDateController
                                                            .text)
                                                    .add(duration)
                                                : DateTime.now().add(duration),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(Duration(days: 365 * 3)),
                                      ) ??
                                      DateTime.tryParse(
                                          _endDateController.text),
                                );

                                setState(() {
                                  _endDateController.text = date;
                                });
                              } catch (err) {
                                print(Constants.refinedExceptionMessage(err));
                              }
                            }),
                      ),
                      validator: (String val) {
                        var errDateRequired =
                            "immunization end date is required";
                        var errVaccineExpired =
                            "immunization end date is past or too soon";

                        try {
                          var dateMillis =
                              DateTime.tryParse(val).millisecondsSinceEpoch;
                          if (_startDateController.text != null) {
                            return DateTime.tryParse(_startDateController.text)
                                        .millisecondsSinceEpoch >
                                    dateMillis
                                ? "immunization start date cannot come after end date"
                                : null;
                          }

                          return Constants.isDateAndFormatCorrect(
                              date: val,
                              emptyDateMessage: errDateRequired,
                              customMessage: errVaccineExpired,
                              isTrue: dateMillis <=
                                  DateTime.now().millisecondsSinceEpoch);
                        } on NoSuchMethodError {
                          return Constants.errInvalidDate;
                        } catch (err) {
                          return Constants.refinedExceptionMessage(err);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.defaultPadding * 2),
                    child: TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      validator: (String title) {
                        if (title.isEmpty) {
                          return 'Description is required';
                        } else if (title.length > 150) {
                          return 'Characters count should be less than 151';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ),
                  DiseasesFilter(filters: diseaseFilters),
                  PlacesFilter(filters: placesFilters),
                  Container(
                    margin: EdgeInsets.only(bottom: Dimensions.defaultPadding),
                    child: RaisedButton(
                      child: Text(
                        (schedule == null ? 'Submit' : 'Update').toUpperCase(),
                        textScaleFactor: Dimensions.defaultScaleFactor,
                        style: Styles.btnTextStyle,
                      ),
                      onPressed: _isRequestSent
                          ? null
                          : () {
                              if (_formKey.currentState.validate()) {
                                _submitPost();
                              }
                            },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

  void _setEndDate(String date) {
    _endDateController.text = date != null
        ? dateFormat.format(DateTime.tryParse(date).add(Duration(days: 5)))
        : dateFormat.format(DateTime.now().add(Duration(days: 5)));
  }

  void _submitPost() async {
    try {
      String title = _titleController.text.trimRight().trimLeft();
      String description = _descController.text;
      String startDate = _startDateController.text.trimLeft().trimRight();
      String endDate = _endDateController.text.trimLeft().trimRight();

      var result = await Connectivity().checkConnectivity();

      if (result != ConnectivityResult.none) {
        var schedule1 = Schedule(
          title: title,
          description: description,
          startDate: startDate,
          endDate: endDate,
          diseases: diseaseFilters,
          places: placesFilters,
        );

        if (!_isRequestSent) {
          _isRequestSent = true;
          var sr = await (schedule == null
              ? ScheduleDataRepo().addSchedule(schedule1)
              : ScheduleDataRepo().updateSchedule(schedule1));

          Constants.showSnackBar(_scaffoldKey, sr.message);
        }
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (err) {
      var errorMessage = Constants.refinedExceptionMessage(err);
      errorMessage.contains(Constants.tokenErrorType)
          ? Constants.showSignInRequestDialog(ctx: context)
          : Constants.showSnackBar(_scaffoldKey, errorMessage);
    } finally {
      _isRequestSent = false;
    }
  }
}
