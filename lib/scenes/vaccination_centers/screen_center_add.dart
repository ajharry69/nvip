import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/centers_repo.dart';
import 'package:nvip/models/vaccination_center.dart';

enum AddCenterCallerId { dashboard, immunization, table, tab }

class AddVaccinationCenterScreen extends StatelessWidget {
  final AddCenterCallerId callerId;
  final VaccineCenter center;

  const AddVaccinationCenterScreen({Key key, this.callerId, this.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _CenterScreenBody(
        callerId: callerId,
        center: center,
      );
}

class _CenterScreenBody extends StatefulWidget {
  final AddCenterCallerId callerId;
  final VaccineCenter center;

  const _CenterScreenBody({Key key, this.callerId, this.center})
      : super(key: key);

  @override
  __CenterScreenBodyState createState() =>
      __CenterScreenBodyState(callerId, center);
}

class __CenterScreenBodyState extends State<_CenterScreenBody> {
  final AddCenterCallerId callerId;
  final VaccineCenter center;
  bool _isRequestSent = false;
  VaccineCentersDataRepo _centersDataRepo;
  Connectivity _connectivity;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;

  __CenterScreenBodyState(this.callerId, this.center);

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _nameController = TextEditingController();
    _centersDataRepo = VaccineCentersDataRepo();

    setState(() {
      _nameController.text = center ?? center.name;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _onBackPressed(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Add Vaccination Center"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () => _onBackPressed(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(Constants.defaultPadding * 4),
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(bottom: Constants.defaultPadding * 2),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    helperText: "name of vaccination center",
                  ),
                  validator: (val) {
                    if (val.isEmpty) {
                      return "center name is required";
                    }
                    return null;
                  },
                ),
              ),
              RaisedButton(
                child: Text(
                  "Submit".toUpperCase(),
                  textScaleFactor: Constants.defaultScaleFactor,
                  style: Styles.btnTextStyle,
                ),
                onPressed: _isRequestSent
                    ? null
                    : () {
                        setState(() {
                          if (_formKey.currentState.validate()) {
                            _submitCenter();
                          }
                        });
                      },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitCenter() async {
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        var center = VaccineCenter.serverParams(_nameController.text);
        if (!_isRequestSent) {
          _isRequestSent = true;
          var sr = await _centersDataRepo.addCenter(center);
          _onResponseReceived(isError: sr.isError, message: sr.message);
        }
      } else {
        Constants.showSnackBar(_scaffoldKey, "", isNetworkConnected: false);
      }
    } on Exception catch (err) {
      _onResponseReceived(message: Constants.refinedExceptionMessage(err));
    }
  }

  void _onResponseReceived({bool isError = true, String message}) {
    setState(() {
      _isRequestSent = false;
      Constants.showSnackBar(_scaffoldKey, message);
      if (!isError) {
        _nameController.text = '';
      }
    });
  }

  void _onBackPressed(BuildContext context) {
    if (callerId == AddCenterCallerId.table) {
      Navigator.pushReplacementNamed(context, Routes.keyPovsTable);
    } else if (callerId == AddCenterCallerId.immunization) {
      Navigator.pushReplacementNamed(context, Routes.keyImmunizationAdd);
    } else {
      Navigator.pushReplacementNamed(context, Routes.keyHome);
    }
  }
}
