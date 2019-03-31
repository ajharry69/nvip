import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/data_repo/network/diseases_repo.dart';
import 'package:nvip/models/disease.dart';

enum AddDiseaseCaller { dashboard, immunization, table, home }

class AddDiseaseScreen extends StatelessWidget {
  final AddDiseaseCaller callerId;
  final Disease disease;

  const AddDiseaseScreen({Key key, this.callerId, this.disease})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _DiseaseScreenBody(
        callerId: callerId,
        disease: disease,
      );
}

class _DiseaseScreenBody extends StatefulWidget {
  final AddDiseaseCaller callerId;
  final Disease disease;

  const _DiseaseScreenBody({Key key, this.callerId, this.disease})
      : super(key: key);

  @override
  __DiseaseScreenBodyState createState() =>
      __DiseaseScreenBodyState(callerId, disease);
}

class __DiseaseScreenBodyState extends State<_DiseaseScreenBody> {
  final AddDiseaseCaller callerId;
  final Disease disease;
  bool _isRequestSent = false;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  TextEditingController _nameController,
      _vaccineController,
      _spreadByController,
      _symptomsController,
      _complicationsController;

  __DiseaseScreenBodyState(this.callerId, this.disease);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _vaccineController = TextEditingController();
    _spreadByController = TextEditingController();
    _symptomsController = TextEditingController();
    _complicationsController = TextEditingController();

    setState(() {
      _nameController.text = disease?.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vaccineController.dispose();
    _spreadByController.dispose();
    _symptomsController.dispose();
    _complicationsController.dispose();
    super.dispose();
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
          title: Text("Add Disease"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () => _onBackPressed(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(Dimensions.defaultPadding * 4),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.defaultPadding * 2),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name*",
                    helperText: "name of vaccine preventable disease",
                  ),
                  validator: (val) {
                    if (val.isEmpty) {
                      return "disease name is required";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.defaultPadding * 2),
                child: TextFormField(
                  controller: _vaccineController,
                  decoration: InputDecoration(
                    labelText: "Vaccine*",
                    helperText: "name of vaccine for preventing disease",
                  ),
                  validator: (val) {
                    if (val.isEmpty) {
                      return "vaccine name is required";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.defaultPadding * 2),
                child: TextFormField(
                  controller: _spreadByController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Spread By*",
                    helperText:
                        "way disease is spread (separated by comma ',')",
                  ),
                  validator: (val) {
                    if (val.isEmpty) {
                      return "disease spreading methods is required";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.defaultPadding * 2),
                child: TextFormField(
                  controller: _symptomsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Symptoms*",
                    helperText:
                        "signs and symptoms of disease (separated by comma ',')",
                  ),
                  validator: (val) {
                    if (val.isEmpty) {
                      return "disease symptoms is required";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.defaultPadding * 2),
                child: TextFormField(
                  controller: _complicationsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Complications",
                    helperText:
                        "complications brought by the disease (separated by comma ',')",
                  ),
                  validator: (val) => null,
                ),
              ),
              RaisedButton(
                child: Text(
                  "Submit".toUpperCase(),
                  textScaleFactor: Dimensions.defaultScaleFactor,
                  style: Styles.btnTextStyle,
                ),
                onPressed: _isRequestSent
                    ? null
                    : () {
                        setState(() {
                          if (_formKey.currentState.validate()) {
                            _submitDisease();
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

  void _submitDisease() async {
    try {
      String name = _nameController.text;
      String vaccine = _vaccineController.text;
      List<String> spreadBy =
          Constants.getCompactedCSV(_spreadByController.text).split(',');
      List<String> symptoms =
          Constants.getCompactedCSV(_symptomsController.text).split(',');
      List<String> complications =
          Constants.getCompactedCSV(_complicationsController.text).split(',');

      var user = await UserCache().currentUser;
      var disease = Disease(
          name: name,
          vaccine: vaccine,
          spreadBy: spreadBy,
          symptoms: symptoms,
          complications: complications);
      await DiseaseDataRepo()
          .addDisease(disease, user.id); // TODO: Add to return result
      _onResponseReceived(isError: false, message: "Successfully added");
    } on Exception catch (err) {
      _onResponseReceived(
          isError: true, message: Constants.refinedExceptionMessage(err));
    }
  }

  void _onResponseReceived({bool isError = true, String message}) {
    setState(() {
      _isRequestSent = false;
      message.contains(Constants.tokenErrorType)
          ? Constants.showSignInRequestDialog(ctx: context)
          : Constants.showSnackBar(_scaffoldKey, message);
      if (!isError) {
        _nameController.text = '';
        _vaccineController.text = '';
        _spreadByController.text = '';
        _symptomsController.text = '';
        _complicationsController.text = '';
      }
    });
  }

  void _onBackPressed(BuildContext context) {
    if (callerId == AddDiseaseCaller.table) {
      Navigator.pushReplacementNamed(context, Routes.keyDiseasesTable);
    } else if (callerId == AddDiseaseCaller.immunization) {
      Navigator.pushReplacementNamed(context, Routes.keyImmunizationAdd);
    } else {
      Navigator.pushReplacementNamed(context, Routes.keyHome);
    }
  }
}
