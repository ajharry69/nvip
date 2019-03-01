import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/diseases_repo.dart';
import 'package:nvip/data_repo/network/vaccines_repo.dart';
import 'package:nvip/models/disease.dart';
import 'package:nvip/models/vaccine.dart';

enum VaccineCallerId { dashboard, table }

enum PageOperation { add, update }

class AddVaccineScreen extends StatelessWidget {
  final Vaccine vaccine;
  final VaccineCallerId callerId;
  final PageOperation pageOp;

  const AddVaccineScreen({Key key, this.vaccine, this.callerId, this.pageOp})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _VaccineScreenBody(
        vaccine: vaccine,
        callerId: callerId,
        pageOp: pageOp,
      );
}

class _VaccineScreenBody extends StatefulWidget {
  final Vaccine vaccine;
  final VaccineCallerId callerId;
  final PageOperation pageOp;

  const _VaccineScreenBody({Key key, this.vaccine, this.callerId, this.pageOp})
      : super(key: key);

  @override
  __VaccineScreenBodyState createState() =>
      __VaccineScreenBodyState(vaccine, callerId, pageOp);
}

class __VaccineScreenBodyState extends State<_VaccineScreenBody> {
  var _isRequestSent = false;

  static final defaultExpDate = DateTime.now().add(Duration(days: 2));
  final defaultExpiryDate =
      DateFormat(Constants.defaultDateFormat).format(defaultExpDate);
  final defaultDate =
      DateFormat(Constants.defaultDateFormat).format(DateTime.now());
  final Vaccine vaccine;
  final VaccineCallerId callerId;
  final PageOperation pageOp;
  List<Disease> _diseaseList = List();

  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  TextEditingController _vIdNoTextController,
      _batchNoTextController,
      _nameTextController,
      _manufacturerTextController,
      _manDateTextController,
      _expDateTextController,
      _diseaseTextController,
      _descriptionTextController;

  __VaccineScreenBodyState(this.vaccine, this.callerId, this.pageOp);

  @override
  void initState() {
    super.initState();

    _vIdNoTextController = TextEditingController();
    _batchNoTextController = TextEditingController();
    _nameTextController = TextEditingController();
    _manufacturerTextController = TextEditingController();
    _manDateTextController = TextEditingController();
    _expDateTextController = TextEditingController();
    _diseaseTextController = TextEditingController();
    _descriptionTextController = TextEditingController();

    setState(() {
      _expDateTextController.text = defaultExpiryDate;
      _manDateTextController.text = defaultDate;
    });

    DiseaseDataRepo().getDiseases().then((diseases) {
      Future(() {
        setState(() {
          _diseaseList = diseases;
          if (_diseaseList.length > 0) {
            _diseaseTextController.text = _diseaseList[0].name;
          }
        });
      }).catchError((err) => throw Exception(err));
    }).catchError((err) => Constants.showSnackBar(
        _scaffoldKey, Constants.refinedExceptionMessage(err)));
  }

  @override
  void dispose() {
    super.dispose();
    _vIdNoTextController.dispose();
    _batchNoTextController.dispose();
    _nameTextController.dispose();
    _manufacturerTextController.dispose();
    _manDateTextController.dispose();
    _expDateTextController.dispose();
    _diseaseTextController.dispose();
    _descriptionTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyVaccinesTable);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Add Vaccine"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyVaccinesTable);
            },
          ),
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
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: TextFormField(
                    controller: _vIdNoTextController,
                    decoration: InputDecoration(
                      labelText: "Vaccine ID*",
                      helperText: "unique vaccine identifier",
                    ),
                    validator: (val) {
                      if (val.isEmpty) return "vaccine ID is required";
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: TextFormField(
                    controller: _batchNoTextController,
                    decoration: InputDecoration(
                      labelText: "Batch No.*",
                      helperText: "vaccine batch number",
                    ),
                    validator: (val) {
                      if (val.isEmpty)
                        return "vaccine batch number is required";
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: TextFormField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      labelText: "Name*",
                      helperText: "name of vaccine",
                    ),
                    validator: (val) {
                      if (val.isEmpty) return "vaccine name is required";
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: TextFormField(
                    controller: _manufacturerTextController,
                    decoration: InputDecoration(
                      labelText: "Manufacturer*",
                      helperText: "name of vaccine manufacturer",
                    ),
                    validator: (val) {
                      if (val.isEmpty)
                        return "vaccine manufacturer is required";
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: _manDateTextController,
                    enabled: true,
                    autovalidate: true,
                    decoration: InputDecoration(
                      labelText: 'Manufacature Date*',
                      helperText:
                          "vaccine manufacture date in YYYY-MM-DD pattern",
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
                                          _manDateTextController.text != null
                                              ? DateTime.tryParse(
                                                  _manDateTextController.text)
                                              : DateTime.now(),
                                      firstDate:
                                          DateTime.tryParse("2010-01-01"),
                                      lastDate: DateTime.now(),
                                    ) ??
                                    DateTime.tryParse(
                                        _manDateTextController.text),
                              );

                              setState(() {
                                _manDateTextController.text = date;
                              });
                            } on Exception catch (err) {
                              print(Constants.refinedExceptionMessage(err));
                            }
                          }),
                    ),
                    validator: (String val) {
                      var errDateRequired =
                          "vaccine manufacture date is required";
                      var errVaccineExpired =
                          "Invalid vaccine manufacture date! Date not reached";

                      try {
                        return Constants.isDateAndFormatCorrect(
                            date: val,
                            emptyDateMessage: errDateRequired,
                            customMessage: errVaccineExpired,
                            isTrue:
                                DateTime.tryParse(val).millisecondsSinceEpoch >
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
                    controller: _expDateTextController,
                    enabled: true,
                    autovalidate: true,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date*',
                      helperText: "vaccine expiry date in YYYY-MM-DD pattern",
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
                                          _expDateTextController.text != null
                                              ? DateTime.tryParse(
                                                  _expDateTextController.text)
                                              : defaultExpiryDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365 * 5)),
                                    ) ??
                                    DateTime.tryParse(
                                        _expDateTextController.text),
                              );

                              setState(() {
                                _expDateTextController.text = date;
                              });
                            } catch (err) {
                              print(Constants.refinedExceptionMessage(err));
                            }
                          }),
                    ),
                    validator: (String val) {
                      var errDateRequired = "vaccine expiry date is required";
                      var errVaccineExpired = "Vaccine is almost or is expired";

                      try {
                        return Constants.isDateAndFormatCorrect(
                            date: val,
                            emptyDateMessage: errDateRequired,
                            customMessage: errVaccineExpired,
                            isTrue:
                                DateTime.tryParse(val).millisecondsSinceEpoch <=
                                    DateTime.now().millisecondsSinceEpoch);
                      } on NoSuchMethodError {
                        return Constants.errInvalidDate;
                      } catch (err) {
                        return Constants.refinedExceptionMessage(err);
                      }
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: _diseaseList.length > 0
                      ? DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Target Disease*",
                            helperText: "disease vaccine is meant to immunize",
                          ),
                          items: _diseaseList.map((disease) {
                            var d = disease.name;
                            return DropdownMenuItem<String>(
                              child: Text(d),
                              value: d,
                            );
                          }).toList(),
                          value: _diseaseTextController.text,
                          onChanged: (String selDisease) {
                            setState(() {
                              _diseaseTextController.text = selDisease;
                            });
                          },
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'target disease is required';
                            } else {
                              return null;
                            }
                          },
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: TextFormField(
                    controller: _descriptionTextController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Description",
                      helperText: "Short description of vaccine",
                    ),
                    validator: (_) => null,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: Constants.defaultPadding * 2,
                  ),
                  child: RaisedButton(
                    child: Text(
                      'Submit'.toUpperCase(),
                      textScaleFactor: Constants.defaultScaleFactor,
                      style: Styles.btnTextStyle,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                _submitVaccine(context);
                              }
                            });
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _submitVaccine(BuildContext context) async {
    String _uIdNo = _vIdNoTextController.text;
    String _batchNo = _batchNoTextController.text;
    String _name = _nameTextController.text;
    String _targetDisease = _diseaseTextController.text;
    String _manufacturer = _manufacturerTextController.text;
    String _manufactureDate = _manDateTextController.text;
    String _expiryDate = _expDateTextController.text;
    String _description = _descriptionTextController.text;
    Vaccine vaccine = Vaccine.serverParams(
        _uIdNo,
        _batchNo,
        _name,
        _targetDisease,
        _manufacturer,
        _manufactureDate,
        _expiryDate,
        _description);
    try {
      var result = await Connectivity().checkConnectivity();
      if (result != ConnectivityResult.none) {
        var sr = await VaccineDataRepo().addVaccine(vaccine);

        _resetPage(isError: false, message: sr.message);
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (err) {
      _resetPage(
          isError: true, message: Constants.refinedExceptionMessage(err));
    }
  }

  void _resetPage({bool isError, String message}) {
    setState(() {
      _isRequestSent = false;
      Constants.showSnackBar(_scaffoldKey, message);
      if (!isError) {
        _vIdNoTextController.text = '';
        _batchNoTextController.text = '';
        _nameTextController.text = '';
        _manufacturerTextController.text = '';
        _manDateTextController.text = defaultDate;
        _expDateTextController.text = defaultExpiryDate;
        _descriptionTextController.text = '';
      }
    });
  }
}
