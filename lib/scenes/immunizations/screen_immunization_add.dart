import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/data_repo/network/centers_repo.dart';
import 'package:nvip/data_repo/network/diseases_repo.dart';
import 'package:nvip/data_repo/network/immunization_repo.dart';
import 'package:nvip/models/disease.dart';
import 'package:nvip/models/immunization.dart';
import 'package:nvip/models/vaccination_center.dart';
import 'package:nvip/scenes/children/screen_child_register.dart';
import 'package:nvip/scenes/diseases/screen_disease_add.dart';
import 'package:nvip/scenes/vaccination_centers/screen_center_add.dart';

class AddImmunizationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _ImmunizationScreenBody();
}

class _ImmunizationScreenBody extends StatefulWidget {
  @override
  __ImmunizationScreenBodyState createState() =>
      __ImmunizationScreenBodyState();
}

class __ImmunizationScreenBodyState extends State<_ImmunizationScreenBody> {
  bool _isRequestSent = false;
  String _selectedDisease = "";
  VaccineCenter _selectedCounty;
  String _selectedCenter = "";
  List<VaccineCenter> _countyList = List();
  List<SubCounty> _subCountyList = List();
  List<Disease> _diseaseList = List();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  TextEditingController _birthCertController;
  TextEditingController _vaccineBatchController;
  TextEditingController _notesController;

  void _getCentersAndDiseases() async {
    try {
      var counties = await VaccineCentersDataRepo().getCenters();
      var diseases = await DiseaseDataRepo().getDiseases();
      setState(() {
        _countyList = counties;
        if (_countyList.length > 0) {
          var county = _countyList[0];
          _selectedCounty = county;
          _subCountyList = county.subCounties;
          _selectedCenter = county.subCounties[0].name;
        }
        _diseaseList = diseases;
        if (_diseaseList.length > 0) {
          _selectedDisease = _diseaseList[0].name;
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
    _birthCertController = TextEditingController();
    _vaccineBatchController = TextEditingController();
    _notesController = TextEditingController();

    _getCentersAndDiseases();
  }

  @override
  void dispose() {
    _birthCertController.dispose();
    _vaccineBatchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const padding16dp = Dimensions.defaultPadding * 2;
    return WillPopScope(
      onWillPop: () =>
          Navigator.pushReplacementNamed(context, Routes.keyImmunizationsTable),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Add Immunization"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, Routes.keyImmunizationsTable);
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(
              top: Dimensions.defaultPadding * 3,
              left: Dimensions.defaultPadding * 4,
              right: Dimensions.defaultPadding * 4,
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    bottom: padding16dp,
                  ),
                  child: TextFormField(
                    controller: _birthCertController,
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                      labelText: "Birth Cert No.*",
                      helperText:
                          "birth certificate number used to register the child",
                    ),
                    validator: (val) {
                      if (val.isEmpty) {
                        return "birth certificate is required";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: padding16dp,
                  ),
                  child: TextFormField(
                    controller: _vaccineBatchController,
                    decoration: InputDecoration(
                      labelText: "Vaccine ID*",
                      helperText: "vaccine identification code",
                    ),
                    validator: (val) {
                      if (val.isEmpty) {
                        return "vaccine ID is required";
                      } else {
                        return null;
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
                            labelText: "C.O.V*",
                            helperText: "select county of vaccination",
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
                            labelText: "S.O.V*",
                            helperText: "Subcounty of Vaccination",
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
                  child: _diseaseList.length > 0
                      ? DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Disease*",
                            helperText:
                                "select 'disease' immunization is to prevent",
                          ),
                          items: _diseaseList.map((disease) {
                            var name = disease.name;
                            return DropdownMenuItem<String>(
                              child: Text("$name (${disease.vaccine})"),
                              value: name,
                            );
                          }).toList(),
                          value: _selectedDisease,
                          onChanged: (String selDisease) {
                            setState(() {
                              _selectedDisease = selDisease;
                            });
                          },
                          validator: (val) {
                            if (val.isEmpty) {
                              return "disease name is required";
                            } else {
                              return null;
                            }
                          },
                        )
                      : null,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: padding16dp,
                  ),
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    textAlign: TextAlign.justify,
                    decoration: InputDecoration(
                      labelText: "Notes",
                      helperText: "additional information to accompany record",
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
                      'Submit'.toUpperCase(),
                      textScaleFactor: Dimensions.defaultScaleFactor,
                      style: Styles.btnTextStyle,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                _doPostImmunizationRecord(context);
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

  void _doPostImmunizationRecord(BuildContext context) async {
    String birthCert = _birthCertController.text;
    String vaccineBatch = _vaccineBatchController.text;
    String diseaseName = _selectedDisease;
    String pov = _selectedCenter;
    String notes = _notesController.text;

    try {
      var result = await Connectivity().checkConnectivity();
      if (result != ConnectivityResult.none) {
        if (!_isRequestSent) {
          _isRequestSent = true;
          var user = await UserCache().currentUser;
          var immunization = Immunization.serverParams(
              birthCert, vaccineBatch, diseaseName, pov, user.id, notes);
          var sr = await ImmunizationDataRepo().addImmunization(immunization);

          _resetPage(isError: sr.isError, message: sr.message);
        }
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

      if (message
          .toLowerCase()
          .contains("Child not registered".toLowerCase())) {
        Constants.showSnackBar(
          _scaffoldKey,
          message,
          showActionButton: true,
          actionLabel: "Register",
          action: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => RegisterChildScreen(
                          callerId: RegisterCallerId.immunization,
                          birthCertNo: _birthCertController.text,
                        )));
          },
        );
      } else if (message
          .toLowerCase()
          .contains("Disease not recognised".toLowerCase())) {
        Constants.showSnackBar(
          _scaffoldKey,
          message,
          showActionButton: true,
          actionLabel: "Add Disease",
          action: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => AddDiseaseScreen(
                          callerId: AddDiseaseCaller.immunization,
                          disease: Disease(name: _selectedDisease),
                        )));
          },
        );
      } else if (message
          .toLowerCase()
          .contains("Vaccination center not recognised".toLowerCase())) {
        Constants.showSnackBar(
          _scaffoldKey,
          message,
          showActionButton: true,
          actionLabel: "Add Center",
          action: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => AddVaccinationCenterScreen(
                          callerId: AddCenterCallerId.immunization,
                          center: VaccineCenter(
                              subCounty: _selectedCenter,
                              county: _selectedCounty.county),
                        )));
          },
        );
      } else {
        message.contains(Constants.tokenErrorType)
            ? Constants.showSignInRequestDialog(ctx: context)
            : Constants.showSnackBar(_scaffoldKey, message);
      }
      if (!isError) {
        _birthCertController.text = '';
        _vaccineBatchController.text = '';
        _notesController.text = '';
      }
    });
  }
}
