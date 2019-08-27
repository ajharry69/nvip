import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/scenes/charts/county-wide/screen_county_charts.dart';
import 'package:nvip/scenes/charts/nation-wide/screen_nation_charts.dart';

class ChartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _ChartsScreenBody();
}

class _ChartsScreenBody extends StatefulWidget {
  @override
  __ChartsScreenBodyState createState() => __ChartsScreenBodyState();
}

class __ChartsScreenBodyState extends State<_ChartsScreenBody>
    with SingleTickerProviderStateMixin<_ChartsScreenBody> {
  TabController _tabController;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.pushReplacementNamed(context, Routes.keyHome),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Immunization Rankings Charts"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[Tab(text: "Nation"), Tab(text: "County")],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScreenNationCharts(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScreenCountyCharts(),
            ),
          ],
        ),
      ),
    );
  }
}
