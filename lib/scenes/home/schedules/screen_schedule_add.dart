import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/widgets/diseases_filter.dart';
import 'package:nvip/widgets/places_filter.dart';

class AddScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _ScheduleScreenBody();
}

class _ScheduleScreenBody extends StatefulWidget {
  @override
  __ScheduleScreenBodyState createState() => __ScheduleScreenBodyState();
}

class __ScheduleScreenBodyState extends State<_ScheduleScreenBody> {
  final dateFormat = DateFormat(Constants.defaultDateFormat);
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _titleController,
      _startDateController,
      _endDateController,
      _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _descController = TextEditingController();

    _startDateController.text = dateFormat.format(DateTime.now());
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
                top: Constants.defaultPadding * 4,
                left: Constants.defaultPadding * 4,
                right: Constants.defaultPadding * 4,
                bottom: Constants.defaultPadding * 2,
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: Constants.defaultPadding),
                    child: TextFormField(
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
                      bottom: Constants.defaultPadding * 2,
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
                                                : DateTime.now(),
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
                      bottom: Constants.defaultPadding * 2,
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
                        bottom: Constants.defaultPadding * 2),
                    child: TextFormField(
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
                  DiseasesFilter(),
                  PlacesFilter(),
                  Container(
                    margin: EdgeInsets.only(bottom: Constants.defaultPadding),
                    child: RaisedButton(
                      child: Text(
                        'Submit'.toUpperCase(),
                        textScaleFactor: Constants.defaultScaleFactor,
                        style: Styles.btnTextStyle,
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          submitPost();
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

  void submitPost() {
    var filters = Constants.diseaseFilters;
    print(filters);
    print(jsonEncode(filters));
    print(jsonDecode(jsonEncode(filters)));
    print(jsonEncode(filters).substring(0, 5));
  }
}
