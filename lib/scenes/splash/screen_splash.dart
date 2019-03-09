import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nvip/auth/auth_listener.dart';
import 'package:nvip/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SplashScreenBody(),
    );
  }
}

class _SplashScreenBody extends StatefulWidget {
  @override
  __SplashScreenBodyState createState() => __SplashScreenBodyState();
}

class __SplashScreenBodyState extends State<_SplashScreenBody>
    implements AuthStateListener {
  AuthStateProvider _authStateProvider;

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod(Constants.hideKbMethod);
    _authStateProvider = AuthStateProvider();
    SharedPreferences.getInstance()
        .then(
          (pref) => Future(
                () {
                  if (pref.getKeys().contains(PreferenceKeys.keySkipSignIn)) {
                    var skipSignIn = pref.getBool(PreferenceKeys.keySkipSignIn);

                    if (skipSignIn) {
                      Navigator.pushReplacementNamed(context, Routes.keyHome);
                    } else {
                      _authStateProvider.subscribe(this);
                    }
                  } else {
                    _authStateProvider.subscribe(this);
                  }
                },
              ),
        )
        .catchError((err) => _authStateProvider.subscribe(this));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColorDark;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: primaryColor),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.local_hospital,
                        color: Colors.greenAccent,
                        size: 50.0,
                      ),
                      radius: 50.0,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: Constants.defaultPadding * 3),
                      child: Text(
                        Constants.appName,
                        style: TextStyle(
                          fontSize: 40.0,
                          fontFamily: "Felipa",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(Constants.defaultPadding * 3),
                    child: Text(
                      'Copyright ${DateTime.now().year}. ${Constants.appName}, '
                          'All Rights Reserved.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  void onAuthStateChanged(AuthState state) {
    Future(() {
      Constants.onAuthStateChanged(context, state,
          authStateProvider: _authStateProvider,
          authStateListener: this,
          isSplashScreen: true);
      _authStateProvider.unsubscribe(this);
    }).catchError((err) => print(Constants.refinedExceptionMessage(err)));
  }
}
