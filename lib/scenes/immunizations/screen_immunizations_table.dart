import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/immunization_repo.dart';
import 'package:nvip/data_repo/tables/data_source_immunization.dart';
import 'package:nvip/models/immunization.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/widgets/data_fetch_error_widget.dart';
import 'package:nvip/widgets/token_error_widget.dart';

class ImmunizationsTableScreen extends StatelessWidget {
  final User user;

  const ImmunizationsTableScreen({this.user, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _ImmunizationsScreenBody(user: this.user);
}

class _ImmunizationsScreenBody extends StatefulWidget {
  final User user;

  const _ImmunizationsScreenBody({this.user, Key key}) : super(key: key);

  @override
  __ImmunizationsScreenBodyState createState() =>
      __ImmunizationsScreenBodyState(user);
}

class __ImmunizationsScreenBodyState extends State<_ImmunizationsScreenBody> {
  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  int _columnIndex = 1;
  bool _isAscending = true;
  final User user;
  Future<List<Immunization>> _immunizationList;
  ImmunizationsTableDataSource _tableDataSource;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  __ImmunizationsScreenBodyState(this.user);

  void _sort<T>(Comparable<T> getField(Immunization d), int columnIndex,
      bool isAscending) {
    _tableDataSource.sort(getField, isAscending);
    setState(() {
      _columnIndex = columnIndex;
      _isAscending = isAscending;
    });
  }

  @override
  void initState() {
    super.initState();
    _immunizationList = ImmunizationDataRepo().getImmunizations();
    _rowsPerPage = _defaultRowsPerPage;
    _rowsPerPage1 = _defaultRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyHome);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Immunizations"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
          actions: <Widget>[
            IconButton(
              tooltip: "Add new immunization record",
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, Routes.keyImmunizationAdd);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "Add new immunization record",
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.keyImmunizationAdd);
          },
        ),
        body: FutureBuilder<List<Immunization>>(
          future: _immunizationList,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              var errorMessage =
                  Constants.refinedExceptionMessage(snapshot.error);

              var isTokenError =
                  snapshot.error.toString().contains(Constants.tokenErrorType);

              return isTokenError
                  ? TokenErrorWidget()
                  : DataFetchErrorWidget(message: errorMessage);
            } else {
              if (snapshot.hasData) {
                var _immunizations = snapshot.data;
                _tableDataSource = ImmunizationsTableDataSource(_immunizations);
                var tableItemsCount = _tableDataSource.rowCount;
                var isRowCountLessDefaultRowsPerPage =
                    tableItemsCount < _defaultRowsPerPage;
                _rowsPerPage1 = isRowCountLessDefaultRowsPerPage
                    ? tableItemsCount
                    : _defaultRowsPerPage;
                return SingleChildScrollView(
                  child: PaginatedDataTable(
                    header: Text("Immunization Records"),
                    sortAscending: _isAscending,
                    sortColumnIndex: _columnIndex,
                    rowsPerPage: isRowCountLessDefaultRowsPerPage
                        ? _rowsPerPage1
                        : _rowsPerPage,
                    onRowsPerPageChanged: isRowCountLessDefaultRowsPerPage
                        ? null
                        : (rowCount) {
                            setState(() {
                              _rowsPerPage = rowCount;
                            });
                          },
                    onSelectAll: (isAllChecked) =>
                        _tableDataSource.selectAll(isAllChecked),
                    actions: <Widget>[
                      IconButton(
                        tooltip: "Add new immunization record",
                        icon: Icon(Icons.add),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, Routes.keyImmunizationAdd);
                        },
                      ),
                      IconButton(
                        tooltip: "Filters immunization records",
                        icon: Icon(Icons.filter_list),
                        onPressed: () {},
                      ),
                    ],
                    columns: <DataColumn>[
                      DataColumn(
                          label: Text("No."),
                          onSort: (ci, isAscending) => _sort<num>(
                              (d) => _immunizations.indexOf(d),
                              ci,
                              isAscending)),
                      DataColumn(
                          label: Text("Child Name"),
                          onSort: (ci, isAscending) => _sort<String>(
                              (d) => d.childName, ci, isAscending)),
                      DataColumn(
                          label: Text("Birth Cert"),
                          onSort: (ci, isAscending) => _sort<String>(
                              (d) => d.birthCert, ci, isAscending)),
                      DataColumn(
                          label: Text("D.O.I"),
                          onSort: (ci, isAscending) =>
                              _sort<String>((d) => d.doi, ci, isAscending)),
                      DataColumn(
                          label: Text("Vaccine ID"),
                          onSort: (ci, isAscending) => _sort<String>(
                              (d) => d.vaccineBatch, ci, isAscending)),
                      DataColumn(
                          label: Text("Disease"),
                          onSort: (ci, isAscending) => _sort<String>(
                              (d) => d.diseaseName, ci, isAscending)),
                      DataColumn(
                          label: Text("P.O.V"),
                          onSort: (ci, isAscending) =>
                              _sort<String>((d) => d.pov, ci, isAscending)),
                      DataColumn(
                          label: Text("PID No"),
                          tooltip: "Providers ID Number",
                          onSort: (ci, isAscending) =>
                              _sort<String>((d) => d.hpId, ci, isAscending)),
                      DataColumn(
                          label: Text("PName"),
                          tooltip: "Prividers name",
                          onSort: (ci, isAscending) =>
                              _sort<String>((d) => d.hpName, ci, isAscending)),
//                      DataColumn(
//                          label: Text("Notes"),
//                          onSort: (ci, isAscending) =>
//                              _sort<String>((d) => d.notes, ci, isAscending)),
                    ],
                    source: _tableDataSource,
                  ),
                );
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
