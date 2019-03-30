import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/centers_repo.dart';
import 'package:nvip/data_repo/network/children_repo.dart';
import 'package:nvip/models/child.dart';
import 'package:nvip/models/vaccination_center.dart';

enum RegisterCallerId { dashboard, table, tab, immunization }

class RegisterChildScreen extends StatelessWidget {
  final RegisterCallerId callerId;
  final String birthCertNo;

  const RegisterChildScreen({Key key, this.callerId, this.birthCertNo})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _RegisterChildScreenBody(
        callerId: callerId,
        birthCertNo: birthCertNo,
      );
}

class _RegisterChildScreenBody extends StatefulWidget {
  final RegisterCallerId callerId;
  final String birthCertNo;

  const _RegisterChildScreenBody({Key key, this.callerId, this.birthCertNo})
      : super(key: key);

  @override
  __RegisterChildScreenBodyState createState() =>
      __RegisterChildScreenBodyState(
          callerId: callerId, birthCertNo: birthCertNo);
}

class __RegisterChildScreenBodyState extends State<_RegisterChildScreenBody> {
  final RegisterCallerId callerId;
  final String birthCertNo;
  bool _isRequestSent = false;
  VaccineCenter _selectedCounty;
  String _selectedCenter = "";
  List<VaccineCenter> _countyList = List();
  List<SubCounty> _subCountyList = List();
  static final List<String> _genders = ["Male", "Female"];
  String _selectedGender = _genders[0];
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  TextEditingController _birthCertNoController,
      _sNameController,
      _fNameController,
      _lNameController,
      _dobController,
      _motherIdController,
      _fatherIdController;

  __RegisterChildScreenBodyState({this.callerId, this.birthCertNo});

  void _getCenters() async {
    try {
      var centers = await VaccineCentersDataRepo().getCenters();
      setState(() {
        _countyList = centers;
        if (_countyList.length > 0) {
          var center = _countyList[0];
          _selectedCounty = center;
          _subCountyList = center.subCounties;
          _selectedCenter = center.subCounties[0].name;
        }
      });
    } on Exception catch (err) {
      Constants.showSnackBar(
          _scaffoldKey, Constants.refinedExceptionMessage(err));
    }
  }

  @override
  void initState() {
    super.initState();

    _birthCertNoController = TextEditingController();
    _sNameController = TextEditingController();
    _fNameController = TextEditingController();
    _lNameController = TextEditingController();
    _dobController = TextEditingController();
    _motherIdController = TextEditingController();
    _fatherIdController = TextEditingController();

    _birthCertNoController.text = birthCertNo;
    setState(() {
      _dobController.text =
          DateFormat(Constants.defaultDateFormat).format(DateTime.now());
    });

    _getCenters();
  }

  @override
  void dispose() {
    _birthCertNoController.dispose();
    _sNameController.dispose();
    _fNameController.dispose();
    _lNameController.dispose();
    _dobController.dispose();
    _motherIdController.dispose();
    _fatherIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const padding16dp = Constants.defaultPadding * 2;
    var padding32dp = Constants.defaultPadding * 4;
    return WillPopScope(
      onWillPop: () {
        _onBackPressed(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Register Child"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              _onBackPressed(context);
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              top: Constants.defaultPadding * 3,
              left: padding32dp,
              right: padding32dp,
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: padding16dp),
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    controller: _birthCertNoController,
                    decoration: InputDecoration(
                      labelText: 'Birth Cert No*',
                      helperText: 'birth certificate number of child',
                    ),
                    validator: (String val) {
                      if (val.isEmpty) {
                        return 'birth cerificate number is required';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: padding16dp),
                  child: TextFormField(
                    controller: _sNameController,
                    decoration: InputDecoration(labelText: 'Sir Name'),
                    validator: (String val) => null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: padding16dp),
                  child: TextFormField(
                    controller: _fNameController,
                    decoration: InputDecoration(labelText: 'First Name*'),
                    validator: (String val) {
                      if (val.isEmpty) {
                        return 'first name is required.';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: padding16dp),
                  child: TextFormField(
                    controller: _lNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (String val) => null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: padding16dp,
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: _dobController,
                    enabled: true,
                    autovalidate: true,
                    decoration: InputDecoration(
                      labelText: 'D.O.B*',
                      helperText: "child's Date of Birth in YYYY-MM-DD pattern",
                      suffixIcon: IconButton(
                          icon: Icon(Icons.date_range),
                          onPressed: () async {
                            try {
                              String date =
                                  DateFormat(Constants.defaultDateFormat)
                                      .format(
                                await showDatePicker(
                                      context: context,
                                      initialDate: _dobController.text != null
                                          ? DateTime.tryParse(
                                              _dobController.text)
                                          : DateTime.now(),
                                      firstDate:
                                          DateTime.tryParse("1970-01-01"),
                                      lastDate: DateTime.now(),
                                    ) ??
                                    DateTime.tryParse(_dobController.text),
                              );

                              setState(() {
                                _dobController.text = date;
                              });
                            } on Exception catch (err) {
                              print(Constants.refinedExceptionMessage(err));
                            }
                          }),
                    ),
                    validator: (String val) {
                      try {
                        return Constants.isDateAndFormatCorrect(
                          date: val,
                          emptyDateMessage: "child's Date of Birth is required",
                          customMessage: "invalid D.O.B. Date not reached",
                          isTrue: DateTime.now().millisecondsSinceEpoch <
                              DateTime.tryParse(val).millisecondsSinceEpoch,
                        );
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
                    bottom: padding16dp,
                  ),
                  child: _countyList.length > 0
                      ? DropdownButtonFormField<VaccineCenter>(
                          decoration: InputDecoration(
                            labelText: "C.O.R*",
                            helperText: "County of Residence",
                          ),
                          items: _countyList.map((center) {
                            var name = center.county;
                            return DropdownMenuItem<VaccineCenter>(
                              child: Text(name),
                              value: center,
                            );
                          }).toList(),
                          value: _selectedCounty,
                          onChanged: (selCounty) {
                            setState(() {
                              _subCountyList = selCounty.subCounties;
                              _selectedCounty = selCounty;
                              _selectedCenter = _subCountyList[0].name;
                            });
                          },
                          validator: (val) {
                            if (val == null) {
                              return 'Required*';
                            } else {
                              return null;
                            }
                          },
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: padding16dp,
                  ),
                  child: _subCountyList.length > 0
                      ? DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "S.O.R*",
                            helperText: "Subcounty of Residence",
                          ),
                          items: _subCountyList.map((subCounty) {
                            var name = subCounty.name;
                            return DropdownMenuItem<String>(
                              child: Text(name),
                              value: name,
                            );
                          }).toList(),
                          value: _selectedCenter,
                          onChanged: (String selCenter) {
                            setState(() {
                              _selectedCenter = selCenter;
                            });
                          },
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Required*';
                            } else {
                              return null;
                            }
                          },
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: padding16dp,
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Gender*",
                      helperText: "child's sex a.k.a gender",
                    ),
                    items: _genders.map((gender) {
                      return DropdownMenuItem<String>(
                        child: Text(gender),
                        value: gender,
                      );
                    }).toList(),
                    value: _selectedGender,
                    onChanged: (String selGender) {
                      setState(() {
                        _selectedGender = selGender;
                      });
                    },
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'gender is required';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: padding16dp),
                  child: TextFormField(
                    controller: _motherIdController,
                    decoration: InputDecoration(
                      labelText: 'Mother ID No.*',
                      helperText: "National ID Number of child's mother",
                    ),
                    validator: (String val) {
                      if (val.isEmpty) {
                        return "mother's ID Number is required";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: padding16dp),
                  child: TextFormField(
                    controller: _fatherIdController,
                    decoration: InputDecoration(
                      labelText: 'Father ID No.',
                      helperText: "National ID Number of child's father",
                    ),
                    validator: (_) => null,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: padding16dp,
                  ),
                  child: RaisedButton(
                    child: Text(
                      'Register'.toUpperCase(),
                      textScaleFactor: Constants.defaultScaleFactor,
                      style: Styles.btnTextStyle,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                _registerChild(context);
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

  void _registerChild(BuildContext context) async {
    String birthCert = _birthCertNoController.text;
    String sName = _sNameController.text;
    String fName = _fNameController.text;
    String lName = _lNameController.text;
    String dob = _dobController.text;
    String aor = _selectedCenter;
    String gender = _selectedGender.toUpperCase();
    String motherId = _motherIdController.text;
    String fatherId = _fatherIdController.text;

    var child = Child.serverParams(
        birthCert, sName, fName, lName, gender, dob, aor, fatherId, motherId);

    try {
      var result = await Connectivity().checkConnectivity();
      if (result != ConnectivityResult.none) {
        if (!_isRequestSent) {
          _isRequestSent = true;
          await ChildrenDataRepo().registerChild(child);

          _resetPage(isError: false, message: "Child Registered Successfully");
        }
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (err) {
      _resetPage(
          isError: true, message: Constants.refinedExceptionMessage(err));
    } finally {
      _isRequestSent = false;
    }
  }

  void _resetPage({bool isError, String message}) {
    setState(() {
      _isRequestSent = false;
      message.contains(Constants.tokenErrorType)
          ? Constants.showSignInRequestDialog(ctx: context)
          : Constants.showSnackBar(_scaffoldKey, message);
      if (!isError) {
        _birthCertNoController.text = '';
        _sNameController.text = '';
        _fNameController.text = '';
        _lNameController.text = '';
        _dobController.text =
            DateFormat(Constants.defaultDateFormat).format(DateTime.now());
        _motherIdController.text = '';
        _fatherIdController.text = '';
      }
    });
  }

  void _onBackPressed(BuildContext context) {
    if (callerId == RegisterCallerId.table) {
      Navigator.pushReplacementNamed(context, Routes.keyChildrenTable);
    } else if (callerId == RegisterCallerId.immunization) {
      Navigator.pushReplacementNamed(context, Routes.keyImmunizationAdd);
    } else {
      Navigator.pushReplacementNamed(context, Routes.keyHome);
    }
  }
}
