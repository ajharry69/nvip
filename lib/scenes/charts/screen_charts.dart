import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/scenes/_demo/charts/group_chart.dart';

class ChartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ChartsScreenBody();
  }
}

class _ChartsScreenBody extends StatefulWidget {
  @override
  __ChartsScreenBodyState createState() => __ChartsScreenBodyState();
}

class __ChartsScreenBodyState extends State<_ChartsScreenBody> {
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
          title: Text("Charts"),
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GroupedBarChart.withSampleData(),
        ),
      ),
    );
  }
}
