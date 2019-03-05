import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/user_repo.dart';
import 'package:nvip/scenes/accounts/pwd/screen_change_pass.dart';

class PasswordResetScreen extends StatelessWidget {
  final String _email;

  PasswordResetScreen([this._email = ""]);

  @override
  Widget build(BuildContext context) => _ResetPasswordScreenBody(_email);
}

class _ResetPasswordScreenBody extends StatefulWidget {
  final String _email;

  _ResetPasswordScreenBody([this._email]);

  @override
  __ResetPasswordScreenBodyState createState() =>
      __ResetPasswordScreenBodyState(_email);
}

class __ResetPasswordScreenBodyState extends State<_ResetPasswordScreenBody> {
  bool _isRequestSent = false;
  final String _email;
  Connectivity _connectivity;
  UserDataRepo _userDataRepo = UserDataRepo();
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _emailController;

  __ResetPasswordScreenBodyState([this._email]);

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();
    _emailController = TextEditingController();
    _emailController.text = _email;
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          title: Text("Forgot Password"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _onBackPressed(context);
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding * 4),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Constants.defaultPadding,
                    top: Constants.defaultPadding * 2,
                  ),
                  child: Text(
                    "An email with a password reset instructions will be sent"
                        " to the email address you will provide below. "
                        "Please make sure it's a valid email address.",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                    ),
                    validator: (String email) {
                      if (email.isEmpty) {
                        return 'email is required';
                      } else if (!email.contains('@')) {
                        return 'invalid email address';
                      } else if (!email.contains('.', email.indexOf('@'))) {
                        return 'invalid email address';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: Constants.defaultPadding),
                  child: RaisedButton(
                    child: Text(
                      'Submit'.toUpperCase(),
                      style: Styles.btnTextStyle,
                      textScaleFactor: Constants.defaultScaleFactor,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                _submitPasswordResetRequest(context);
                              }
                            });
                          },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    Future(() {
      Navigator.pushReplacementNamed(context, Routes.keySignIn);
    }).catchError((err) => print(Constants.refinedExceptionMessage(err)));
  }

  void _submitPasswordResetRequest(BuildContext context) async {
    String email = _emailController.text;

    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        if (!_isRequestSent) {
          _isRequestSent = true;
          var sr = await _userDataRepo.requestPasswordReset(email);
          _onServerResponseReceived();
          var message = sr.message;
          if (!sr.isError) {
            Future(() {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => AlertDialog(
                      title: Text("Password Sent!"),
                      content: Text(message),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Future(() {
                              Navigator.of(context).pop();
                            }).catchError((err) =>
                                print(Constants.refinedExceptionMessage(err)));
                          },
                        ),
                        FlatButton(
                          child: Text("Proceed"),
                          onPressed: () {
                            Future(() {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangePasswordScreen(
                                      Constants.prTypeReset, email),
                                ),
                              );
                            }).catchError((err) =>
                                print(Constants.refinedExceptionMessage(err)));
                          },
                        )
                      ],
                    ),
              );
            });
          } else {
            if (message
                .toLowerCase()
                .contains("email address not registered")) {
              Constants.showSnackBar(
                _scaffoldKey,
                message,
                showActionButton: true,
                actionLabel: "Register".toUpperCase(),
                action: () {
                  Future(() {
                    Navigator.pushReplacementNamed(context, Routes.keySignUp);
                  });
                },
              );
            } else {
              throw Exception(message);
            }
          }
        }
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (e) {
      _onServerResponseReceived();
      Constants.showSnackBar(
          _scaffoldKey, Constants.refinedExceptionMessage(e));
    }
  }

  void _onServerResponseReceived() {
    setState(() {
      _isRequestSent = false;
    });
  }
}
