import 'package:flutter/material.dart';

class DashBoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _DashBoardScreenBody();
}

class _DashBoardScreenBody extends StatefulWidget {
  @override
  __DashBoardScreenBodyState createState() => __DashBoardScreenBodyState();
}

class __DashBoardScreenBodyState extends State<_DashBoardScreenBody> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
    );
  }
}
