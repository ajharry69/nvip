import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nvip/auth/auth_listener.dart';
import 'package:nvip/auth/auth_presenter.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/models/user.dart';

class VerifyAccountScreen extends StatelessWidget {
  VerifyAccountScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => _VerifyAccountScreenBody();
}

class _VerifyAccountScreenBody extends StatefulWidget {
  _VerifyAccountScreenBody();

  @override
  __VerifyAccountScreenBodyState createState() =>
      __VerifyAccountScreenBodyState();
}

class __VerifyAccountScreenBodyState extends State<_VerifyAccountScreenBody>
    implements AuthContract, AuthStateListener {
  bool _isRequestSent = false;
  String _email;
  UserCache _userCache = UserCache();
  AuthPresenter _authPresenter;
  AuthStateProvider _authStateProvider;

  var _vButtonKey = UniqueKey();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  Connectivity _connectivity;
  var _t1Controller = TextEditingController();
  var _t2Controller = TextEditingController();
  var _t3Controller = TextEditingController();
  var _t4Controller = TextEditingController();
  var _t5Controller = TextEditingController();
  var _t6Controller = TextEditingController();

  FocusNode _t1FocusNode,
      _t2FocusNode,
      _t3FocusNode,
      _t4FocusNode,
      _t5FocusNode,
      _t6FocusNode;

  __VerifyAccountScreenBodyState();

  @override
  void initState() {
    super.initState();

    _userCache.currentUser.then((user) {
      _email = user.email;
    });

    _connectivity = Connectivity();
    _authPresenter = AuthPresenter(this);
    _authStateProvider = AuthStateProvider();
    _authStateProvider.subscribe(this);

    _t1FocusNode = FocusNode();
    _t2FocusNode = FocusNode();
    _t3FocusNode = FocusNode();
    _t4FocusNode = FocusNode();
    _t5FocusNode = FocusNode();
    _t6FocusNode = FocusNode();
  }

  @override
  void dispose() {
    _t1FocusNode.dispose();
    _t2FocusNode.dispose();
    _t3FocusNode.dispose();
    _t4FocusNode.dispose();
    _t5FocusNode.dispose();
    _t6FocusNode.dispose();

    _t1Controller.dispose();
    _t2Controller.dispose();
    _t3Controller.dispose();
    _t4Controller.dispose();
    _t5Controller.dispose();
    _t6Controller.dispose();
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
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _onBackPressed(context);
              }),
          title: Text("Verify Account"),
        ),
        body: Container(
          padding: EdgeInsets.all(Constants.defaultPadding * 4),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: Constants.defaultPadding,
                  bottom: Constants.defaultPadding,
                ),
                child: Text(
                  'Your account $_email is NOT yet verified. Please input '
                      'verification code sent to your account email below to proceed.',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: Constants.defaultPadding),
                child: midSection(context),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: Constants.defaultPadding,
                  bottom: Constants.defaultPadding * 2,
                ),
                child: RaisedButton(
                    key: _vButtonKey,
                    child: Text(
                      'Verify'.toUpperCase(),
                      style: Styles.btnTextStyle,
                      textScaleFactor: Constants.defaultScaleFactor,
                    ),
                    onPressed: _isRequestSent
                        ? null
                        : () {
                            setState(() {
                              _verifyAccount(context);
                            });
                          }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget midSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        vCodeTextField(
          context,
          controller: _t1Controller,
          cFocusNode: _t1FocusNode,
          tFocusNode: _t2FocusNode,
        ),
        vCodeTextField(
          context,
          controller: _t2Controller,
          cFocusNode: _t2FocusNode,
          tFocusNode: _t3FocusNode,
        ),
        vCodeTextField(
          context,
          controller: _t3Controller,
          cFocusNode: _t3FocusNode,
          tFocusNode: _t4FocusNode,
        ),
        vCodeTextField(
          context,
          controller: _t4Controller,
          cFocusNode: _t4FocusNode,
          tFocusNode: _t5FocusNode,
        ),
        vCodeTextField(
          context,
          controller: _t5Controller,
          cFocusNode: _t5FocusNode,
          tFocusNode: _t6FocusNode,
        ),
        vCodeTextField(
          context,
          isLast: true,
          controller: _t6Controller,
          cFocusNode: _t6FocusNode,
        ),
      ],
    );
  }

  Widget vCodeTextField(
    BuildContext context, {
    bool isLast = false,
    Key key,
    TextEditingController controller,
    FocusNode cFocusNode,
    FocusNode tFocusNode,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(Constants.defaultPadding / 4),
        child: TextField(
          key: key,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          autofocus: true,
          focusNode: cFocusNode,
          controller: controller,
          maxLength: 1,
          style: TextStyle(fontSize: 18.0, color: Colors.black),
          decoration: InputDecoration(
              hintText: '0', counterStyle: TextStyle(color: Colors.white)),
          onChanged: (String c) {
            if (!isLast) {
              if (c.length == 1) {
                FocusScope.of(context).requestFocus(tFocusNode);
              } else {
                FocusScope.of(context).requestFocus(cFocusNode);
              }
            } else {
              if (c.length == 1) {
                setState(() {
                  _verifyAccount(context);
                });
              }
            }
          },
        ),
      ),
    );
  }

  void _verifyAccount(BuildContext context) async {
    String c1 = _t1Controller.text;
    String c2 = _t2Controller.text;
    String c3 = _t3Controller.text;
    String c4 = _t4Controller.text;
    String c5 = _t5Controller.text;
    String c6 = _t6Controller.text;

    String vCode = '$c1$c2$c3$c4$c5$c6';

    try {
      var result = await _connectivity.checkConnectivity();

      if (result != ConnectivityResult.none) {
        if (vCode.length == 6) {
          try {
            User _user = await _userCache.currentUser;
            if (_user != null) {
              if (!_isRequestSent) {
                _isRequestSent = true;
                _authPresenter.verifyAccount(_user.id, vCode);
              }
            }
          } on Exception catch (e) {
            onSignInFailed(Constants.refinedExceptionMessage(e));
          }
        } else {
          Constants.showSnackBar(_scaffoldKey, 'Invalid verification code!');
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

  void _onBackPressed(BuildContext context) {
    Future(() {
      Constants.moveToSignInScreen(context);
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
    Constants.showSnackBar(_scaffoldKey, error);
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
      _t1Controller.text = '';
      _t2Controller.text = '';
      _t3Controller.text = '';
      _t4Controller.text = '';
      _t5Controller.text = '';
      _t6Controller.text = '';
      FocusScope.of(context).requestFocus(_t1FocusNode);
    });
  }
}
