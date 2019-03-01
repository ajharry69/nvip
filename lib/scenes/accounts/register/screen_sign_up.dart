import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/auth/auth_listener.dart';
import 'package:nvip/auth/auth_presenter.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/models/user.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _SignUpScreenBody();
}

class _SignUpScreenBody extends StatefulWidget {
  @override
  __SignUpScreenBodyState createState() => __SignUpScreenBodyState();
}

class __SignUpScreenBodyState extends State<_SignUpScreenBody>
    implements AuthContract, AuthStateListener {
  bool _isRequestSent = false;
  bool _isPassObscure = true;
  UserCache _userCache = UserCache();
  AuthPresenter _authPresenter;
  AuthStateProvider _authStateProvider;
  Connectivity _connectivity;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _sNameController = TextEditingController();
  var _fNameController = TextEditingController();
  var _lNameController = TextEditingController();
  var _idNoController = TextEditingController();
  var _emailController = TextEditingController();
  var _passController = TextEditingController();

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
    _sNameController.dispose();
    _fNameController.dispose();
    _lNameController.dispose();
    _idNoController.dispose();
    _emailController.dispose();
    _passController.dispose();
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
          title: Text('Sign Up'),
          centerTitle: true,
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
            padding: EdgeInsets.only(
              top: Constants.defaultPadding * 4,
              left: Constants.defaultPadding * 4,
              right: Constants.defaultPadding * 4,
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    controller: _sNameController,
                    decoration:
                        InputDecoration(labelText: 'Sir Name', filled: true),
                    validator: (String val) => null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    controller: _fNameController,
                    decoration:
                        InputDecoration(labelText: 'First Name*', filled: true),
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
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    controller: _lNameController,
                    decoration:
                        InputDecoration(labelText: 'Last Name', filled: true),
                    validator: (String val) => null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    controller: _idNoController,
                    decoration: InputDecoration(
                      labelText: 'ID Number*',
                      helperText: 'input national ID number',
                      filled: true,
                    ),
                    validator: (String val) {
                      if (val.isEmpty) {
                        return 'ID Number is required';
                      } else if (val.contains(' ')) {
                        return "Invalid ID Number. Spaces not allowed";
                      } else if (val.contains('-')) {
                        return "Invalid character '-'. Only numbers required";
                      } else if (val.contains('.')) {
                        return "Invalid character '.'. Only numbers required";
                      } else if (val.contains(',')) {
                        return "Invalid character ','. Only numbers required";
                      } else if (int.tryParse(val) == null) {
                        return "Invalid ID Number. Only numbers required";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration:
                        InputDecoration(labelText: 'Email*', filled: true),
                    validator: (String val) {
                      if (!val.contains('@')) {
                        return 'invalid email address';
                      } else if (!val.contains('.', val.indexOf('@'))) {
                        return 'invalid email address';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: Constants.defaultPadding * 2),
                  child: TextFormField(
                    controller: _passController,
                    obscureText: _isPassObscure,
                    decoration: InputDecoration(
                      labelText: 'Password*',
                      filled: true,
                      suffixIcon: IconButton(
                        icon: _isPassObscure
                            ? Icon(
                                Icons.visibility,
                              )
                            : Icon(
                                Icons.visibility_off,
                              ),
                        onPressed: () {
                          setState(() => _isPassObscure
                              ? _isPassObscure = false
                              : _isPassObscure = true);
                        },
                      ),
                    ),
                    validator: (String val) {
                      if (val.length < 8) {
                        return 'Password too short. At least 8 characters required';
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: Constants.defaultPadding,
                  ),
                  child: RaisedButton(
                    child: Text(
                      'Sign Up'.toUpperCase(),
                      textScaleFactor: Constants.defaultScaleFactor,
                      style: Styles.btnTextStyle,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                _doCreateAccount(context);
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

  void _doCreateAccount(BuildContext context) async {
    try {
      ConnectivityResult result = await _connectivity.checkConnectivity();

      if (result != ConnectivityResult.none) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Account Verification'),
              content: Text(
                "To make sure these account details are yours, ${Constants.appName} "
                    "will send you (${_emailController.text}) an email with a "
                    "6-digit verification code. Use it the next page to verify your account.",
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'.toUpperCase()),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Okay'.toUpperCase()),
                  onPressed: () {
                    setState(() {
                      _onRequestSubmission(context);
                    });
                  },
                )
              ],
            );
          },
        );
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (e) {
      Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
          isNetworkConnected: false);
      print(Constants.refinedExceptionMessage(e));
    }
  }

  void _onRequestSubmission(BuildContext context) async {
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        Navigator.pop(context);
        _createUserAccount(context);
      } else {
        Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
            isNetworkConnected: false);
      }
    } on Exception catch (e) {
      Constants.showSnackBar(_scaffoldKey, Constants.connectionLost,
          isNetworkConnected: false);
      print(Constants.refinedExceptionMessage(e));
    }
  }

  void _createUserAccount(BuildContext context) {
    String idNo = _idNoController.text;
    String sName = _sNameController.text;
    String fName = _fNameController.text;
    String lName = _lNameController.text;
    String email = _emailController.text;
    String role = Constants.privilegeParent;
    String password = _passController.text;

    if (!_isRequestSent) {
      _isRequestSent = true;

      User _user = User.serverParams(idNo, sName, fName, lName, email, role);
      _authPresenter.signUp(_user, password);
    }
  }

  void _onBackPressed(BuildContext context) {
    Future(() {
      Constants.moveToSignInScreen(context);
      _authStateProvider.unsubscribe(this);
    }).catchError((err) => print(Constants.refinedExceptionMessage(err)));
  }

  void __onServerResponseReceived({bool isResponseSuccess = false}) {
    setState(() {
      _isRequestSent = false;
      if (isResponseSuccess) {
        _idNoController.text = '';
        _sNameController.text = '';
        _fNameController.text = '';
        _lNameController.text = '';
        _emailController.text = '';
        _passController.text = '';
      }
    });
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
    __onServerResponseReceived();
    error
            .toLowerCase()
            .contains("Email or ID number already in use".toLowerCase())
        ? Constants.showSnackBar(
            _scaffoldKey,
            error,
            showActionButton: true,
            actionLabel: "Sign In",
            action: () {
              _onBackPressed(context);
            },
          )
        : Constants.showSnackBar(_scaffoldKey, error);
  }

  @override
  void onSignInSuccess(User user) async {
    try {
      await _userCache.saveUser(user);
      __onServerResponseReceived(isResponseSuccess: true);
      _authStateProvider.initState();
    } on Exception catch (e) {
      onSignInFailed(Constants.refinedExceptionMessage(e));
    }
  }
}
