import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _ProfileScreenBody();
}

class _ProfileScreenBody extends StatefulWidget {
  @override
  __ProfileScreenBodyState createState() => __ProfileScreenBodyState();
}

class __ProfileScreenBodyState extends State<_ProfileScreenBody> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyHome);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Account Profile"),
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
        ),
        body: ListView(
          children: <Widget>[],
        ),
      ),
    );
  }
}
