import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/cache_db/user_cache.dart';
import 'package:nvip/data_repo/network/user_repo.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.onTokenRefresh.listen(
      (token) async {
        try {
          User user = await UserCache().currentUser;
          await UserDataRepo().updateDeviceId(user?.id, token);
        } on Exception catch (err) {
          print('MyApp.build: ${Constants.refinedExceptionMessage(err)}');
        }
      },
    ).onError((err) => print(
        "${Constants.appName}: ${Constants.refinedExceptionMessage(err)}"));

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (message) {},
      onResume: (message) {},
      onLaunch: (message) {},
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
//          primaryColor: Color(0xFF1976d2),
//          primaryColorDark: Color(0xFF004ba0),
//          primaryColorLight: Color(0xFF63a4ff),
//          accentColor: Color(0xFF63a4ff),
//          canvasColor: Colors.transparent,
          buttonTheme: ButtonThemeData(
            buttonColor: Theme.of(context).accentColor,
            shape: Constants.defaultButtonShape(context),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
          )),
      routes: routes,
    );
  }
}
