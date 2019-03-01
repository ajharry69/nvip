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
  TextEditingController _nameController;
  TextEditingController _descriptionController;

  __DiseaseScreenBodyState(this.callerId, this.disease);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    setState(() {
      _nameController.text = disease?.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
            padding: EdgeInsets.all(Constants.defaultPadding * 4),
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(bottom: Constants.defaultPadding * 2),
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
                padding:
                    const EdgeInsets.only(bottom: Constants.defaultPadding * 2),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    helperText: "brief description of disease",
                  ),
                  validator: (val) => null,
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
      String description = _descriptionController.text;

      var user = await UserCache().currentUser;
      var disease = Disease.serverParams(name, description);
      var sr = await DiseaseDataRepo().addDisease(disease, user.id);
      _onResponseReceived(isError: sr.isError, message: sr.message);
    } on Exception catch (err) {
      _onResponseReceived(
          isError: true, message: Constants.refinedExceptionMessage(err));
    }
  }

  void _onResponseReceived({bool isError = true, String message}) {
    setState(() {
      _isRequestSent = false;
      Constants.showSnackBar(_scaffoldKey, message);
      if (!isError) {
        _nameController.text = '';
        _descriptionController.text = '';
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
