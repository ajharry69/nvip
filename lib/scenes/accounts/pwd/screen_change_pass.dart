import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/auth/auth_listener.dart';
import 'package:nvip/auth/auth_presenter.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/scenes/accounts/pwd/screen_reset_pass.dart';

class ChangePasswordScreen extends StatelessWidget {
  final String _email;
  final String _opType;

  ChangePasswordScreen(this._opType, this._email, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _ChangePasswordScreenBody(_opType, _email);
}

class _ChangePasswordScreenBody extends StatefulWidget {
  final String _email;
  final String _opType;

  _ChangePasswordScreenBody(this._opType, this._email);

  @override
  __ChangePasswordScreenBodyState createState() =>
      __ChangePasswordScreenBodyState(_opType, _email);
}

class __ChangePasswordScreenBodyState extends State<_ChangePasswordScreenBody>
    implements AuthContract, AuthStateListener {
  bool _isRequestSent = false;
  bool _isOPObscure = true;
  bool _isNPObscure = true;
  String _email = '';
  String _opType = '';
  UserCache _userCache = UserCache();
  AuthPresenter _authPresenter;
  AuthStateProvider _authStateProvider;
  Connectivity _connectivity;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _oldPassController = TextEditingController();
  var _newPassController = TextEditingController();

  __ChangePasswordScreenBodyState(this._opType, this._email);

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();
    _authPresenter = AuthPresenter(this);
    _authStateProvider = AuthStateProvider();
    _authStateProvider.subscribe(this);
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
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
          title: Text("Change Password"),
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
            padding: const EdgeInsets.all(Dimensions.defaultPadding * 4),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.defaultPadding,
                    top: Dimensions.defaultPadding * 2,
                  ),
                  child: Text(
                    "Hello $_email, please fill in the filleds provided below to "
                        "change your password.",
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: Dimensions.defaultPadding),
                  child: TextFormField(
                    controller: _oldPassController,
                    obscureText: _isOPObscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Old Password',
                      filled: true,
                      suffixIcon: IconButton(
                        icon: _isOPObscure
                            ? Icon(
                                Icons.visibility,
                              )
                            : Icon(
                                Icons.visibility_off,
                              ),
                        onPressed: () {
                          setState(() => _isOPObscure
                              ? _isOPObscure = false
                              : _isOPObscure = true);
                        },
                      ),
                    ),
                    validator: (String pass) {
                      if (pass.isEmpty) {
                        return 'Old password is required';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.defaultPadding * 2),
                  child: TextFormField(
                    controller: _newPassController,
                    obscureText: _isNPObscure,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      filled: true,
                      suffixIcon: IconButton(
                        icon: _isNPObscure
                            ? Icon(
                                Icons.visibility,
                              )
                            : Icon(
                                Icons.visibility_off,
                              ),
                        onPressed: () {
                          setState(() => _isNPObscure
                              ? _isNPObscure = false
                              : _isNPObscure = true);
                        },
                      ),
                    ),
                    validator: (String pass) {
                      if (pass.isEmpty) {
                        return 'new password is required';
                      } else if (pass.length < 8) {
                        return 'password too short. At least 8 characters needed.';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: Dimensions.defaultPadding),
                  child: RaisedButton(
                    child: Text(
                      'Change'.toUpperCase(),
                      textScaleFactor: Dimensions.defaultScaleFactor,
                      style: Styles.btnTextStyle,
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

  void _submitPasswordResetRequest(BuildContext context) async {
    String op = _oldPassController.text;
    String np = _newPassController.text;
    String opRefined =
        _opType == Constants.prTypeReset ? op.replaceAll(' ', '') : op;

    try {
      var result = await _connectivity.checkConnectivity();

      if (_email.isNotEmpty) {
        if (result != ConnectivityResult.none) {
          if (!_isRequestSent) {
            _isRequestSent = true;
            _authPresenter.changePassword(_opType, _email, opRefined, np);
          }
        } else {
          Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
              isNetworkConnected: false);
        }
      } else {
        Constants.showSnackBar(_scaffoldKey, 'invalid email address.');
      }
    } on Exception catch (e) {
      Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
          isNetworkConnected: false);
      print(Constants.refinedExceptionMessage(e));
    }
  }

  void _onBackPressed(BuildContext context) {
    Future(() {
      Navigator.pushReplacementNamed(context, Routes.keyResetPass);
      _authStateProvider.unsubscribe(this);
    }).catchError((err) => print(Constants.refinedExceptionMessage(err)));
  }

  @override
  void onAuthStateChanged(AuthState state) {
    Future(() {
      Constants.onAuthStateChanged(context, state);
      _authStateProvider.unsubscribe(this);
    }).catchError((err) => print(Constants.refinedExceptionMessage(err)));
  }

  @override
  void onSignInFailed(String error) {
    _onServerResponseReceived();

    _opType == Constants.prTypeChange
        ? Constants.showSnackBar(
            _scaffoldKey,
            error,
            showActionButton: true,
            actionLabel: "Forgot Password?",
            action: () {
              Future(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PasswordResetScreen(_email),
                  ),
                );
                _authStateProvider.unsubscribe(this);
              }).catchError(
                  (err) => print(Constants.refinedExceptionMessage(err)));
            },
          )
        : Constants.showSnackBar(_scaffoldKey, error);
  }

  @override
  void onSignInSuccess(String authToken) async {
    try {
      await _userCache.saveUserToken(authToken);
      _onServerResponseReceived();
      _authStateProvider.initState();
    } on Exception catch (e) {
      onSignInFailed(Constants.refinedExceptionMessage(e));
    }
  }

  void _onServerResponseReceived() {
    setState(() {
      _isRequestSent = false;
    });
  }
}
