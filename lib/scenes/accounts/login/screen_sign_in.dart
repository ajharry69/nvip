import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:nvip/auth/auth_listener.dart';
import 'package:nvip/auth/auth_presenter.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _SignInScreenBody();
}

class _SignInScreenBody extends StatefulWidget {
  @override
  __SignInScreenBodyState createState() => __SignInScreenBodyState();
}

class __SignInScreenBodyState extends State<_SignInScreenBody>
    implements AuthContract, AuthStateListener {
  var _isPassObscure = true;
  var _isRequestSent = false;
  var errMsg02;

  UserCache _userCache = UserCache();
  AuthPresenter _authPresenter;
  AuthStateProvider _authStateProvider;
  Connectivity _connectivity;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _usernameController = TextEditingController();
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
    _usernameController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Sign In'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(
          top: Constants.defaultPadding * 4,
          left: Constants.defaultPadding * 4,
          right: Constants.defaultPadding * 4,
          bottom: Constants.defaultPadding * 2,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: _topSection(),
              ),
              Expanded(
                flex: 1,
                child: _bottomSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topSection() {
    var showError = errMsg02 != null && errMsg02 != "";
    return Column(
      children: <Widget>[
        showError
            ? Container(
                padding:
                    const EdgeInsets.only(bottom: Constants.defaultPadding * 2),
                child: Text(
                  showError ? errMsg02 : "",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent),
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(
            bottom: Constants.defaultPadding * 2,
          ),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: _usernameController,
            decoration: InputDecoration(
                labelText: 'Username*',
                helperText: 'email or ID Number used while creating account',
                filled: true),
            validator: (String val) {
              if (val.isEmpty) {
                return 'email address or ID Number required';
              } else {
                return null;
              }
            },
          ),
        ),
        TextFormField(
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
                setState(
                  () => _isPassObscure
                      ? _isPassObscure = false
                      : _isPassObscure = true,
                );
              },
            ),
          ),
          validator: (String val) {
            if (val.isEmpty) {
              return 'password is required';
            } else {
              return null;
            }
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            shape: BeveledRectangleBorder(),
            child: Text(
              'Forgot password?',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              Future(() {
                Navigator.pushReplacementNamed(context, Routes.keyResetPass);
                _authStateProvider.unsubscribe(this);
              }).catchError(
                  (err) => print(Constants.refinedExceptionMessage(err)));
            },
          ),
        ),
        Container(
          width: double.maxFinite,
          child: RaisedButton(
            child: Text(
              'Sign In'.toUpperCase(),
              textScaleFactor: Constants.defaultScaleFactor,
              style: Styles.btnTextStyle,
            ),
            onPressed: _isRequestSent
                ? null
                : () {
                    setState(() {
                      SystemChannels.textInput
                          .invokeMethod(Constants.hideKbMethod);
                      if (_formKey.currentState.validate()) {
                        _signInUser(context);
                      }
                    });
                  },
          ),
        ),
      ],
    );
  }

  Widget _bottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: OutlineButton(
            borderSide: BorderSide(color: Theme.of(context).accentColor),
            child: Text('Create Account'.toUpperCase(), maxLines: 1),
            onPressed: () {
              Future(() {
                Navigator.pushReplacementNamed(context, Routes.keySignUp);
                _authStateProvider.unsubscribe(this);
              }).catchError(
                  (err) => print(Constants.refinedExceptionMessage(err)));
            },
          ),
        ),
        Container(width: Constants.defaultPadding),
        Expanded(
          child: RaisedButton(
            child: Text(
              'Skip'.toUpperCase(),
              style: Styles.btnTextStyle,
              maxLines: 1,
            ),
            onPressed: () async {
              Future(() async {
                var pref = await SharedPreferences.getInstance();
                await pref.setBool(PreferenceKeys.keySkipSignIn, true);
                Navigator.pushReplacementNamed(context, Routes.keyHome);
                _authStateProvider.unsubscribe(this);
              }).catchError(
                  (err) => print(Constants.refinedExceptionMessage(err)));
            },
          ),
        )
      ],
    );
  }

  void _signInUser(BuildContext context) async {
    String username = _usernameController.text.replaceAll(' ', '');
    String password = _passController.text;

    try {
      var result = await _connectivity.checkConnectivity();

      if (result != ConnectivityResult.none) {
        if (!_isRequestSent) {
          _isRequestSent = true;
          _authPresenter.signIn(username, password);
        }
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

  @override
  void onAuthStateChanged(AuthState state) {
    Future(() {
      Constants.onAuthStateChanged(context, state, isSignInScreen: true);
      _authStateProvider.unsubscribe(this);
    }).catchError((err) => print(Constants.refinedExceptionMessage(err)));
  }

  @override
  void onSignInFailed(String error) {
    __onServerResponseReceived();

    var errMsg = error;
    if (error.contains("#")) {
      var components = error.split("#");
      errMsg = components.first;
      setState(() {
        errMsg02 = components.last;
      });
    } else {
      setState(() {
        errMsg02 = null;
      });
    }

    error.toLowerCase().contains('Account deactivated'.toLowerCase())
        ? Constants.showSnackBar(
            _scaffoldKey,
            errMsg,
            showActionButton: true,
            actionLabel: "Contact Admin",
            action: () {
              Future(() {
                if (Platform.isAndroid) {
                  AppAvailability.launchApp("com.google.android.gm");
                }
              }).catchError((err) => Constants.showSnackBar(
                  _scaffoldKey, "Gmail Application not found."));
            },
          )
        : Constants.showSnackBar(_scaffoldKey, errMsg);
  }

  @override
  void onSignInSuccess(String authToken) async {
    try {
      await _userCache.saveUserToken(authToken);
      __onServerResponseReceived(isResponseSuccess: true);
      _authStateProvider.initState();
    } on Exception catch (e) {
      onSignInFailed(Constants.refinedExceptionMessage(e));
    }
  }

  void __onServerResponseReceived({bool isResponseSuccess = false}) {
    setState(() {
      _isRequestSent = false;
      if (isResponseSuccess) {
        _usernameController.text = '';
        _passController.text = '';
      }
    });
  }
}
