import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/vaccines_repo.dart';
import 'package:nvip/data_repo/tables/data_source_vaccines.dart';
import 'package:nvip/models/vaccine.dart';

class VaccinesTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _VaccinesScreenBody();
}

class _VaccinesScreenBody extends StatefulWidget {
  @override
  __VaccinesScreenBodyState createState() => __VaccinesScreenBodyState();
}

class __VaccinesScreenBodyState extends State<_VaccinesScreenBody> {
  bool _showTableView = true;
  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  int _columnIndex = 1;
  bool _isSortAscending = true;
  Future<List<Vaccine>> _vaccines;
  VaccinesTableDataSource _tableDataSource;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void _sort<T>(Comparable<T> getField(Vaccine v), int columnIndex,
      bool isSortAscending) {
    _tableDataSource?.sort(getField, isSortAscending);
    setState(() {
      _columnIndex = columnIndex;
      _isSortAscending = isSortAscending;
    });
  }

  @override
  void initState() {
    super.initState();
    _vaccines = VaccineDataRepo().getVaccines();
    _rowsPerPage = _defaultRowsPerPage;
    _rowsPerPage1 = _defaultRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    var addVaccineTooltip = "Add new vaccine";
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyHome);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Vaccines"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              tooltip: addVaccineTooltip,
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.keyVaccineAdd);
              },
            ),
            IconButton(
              icon: Icon(_showTableView ? Icons.view_list : Icons.table_chart),
              tooltip:
                  _showTableView ? "Switch to listview" : "Switch to tableview",
              onPressed: () {
                setState(() {
                  _showTableView = _showTableView ? false : true;
                });
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: addVaccineTooltip,
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.keyVaccineAdd);
          },
        ),
        body: FutureBuilder<List<Vaccine>>(
          future: _vaccines,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Constants.showHasNoDataWidget(
                  context,
                  "${Constants.refinedExceptionMessage(snapshot.error)} "
                  "Press the (+) button to add a new vaccine.");
            } else {
              if (snapshot.hasData) {
                var vaccineList = snapshot.data;
                _tableDataSource = VaccinesTableDataSource(vaccineList);
                if (_showTableView) {
                  var tableItemsCount = _tableDataSource.rowCount;
                  var isRowCountLessDefaultRowsPerPage =
                      tableItemsCount < _defaultRowsPerPage;
                  _rowsPerPage1 = isRowCountLessDefaultRowsPerPage
                      ? tableItemsCount
                      : _defaultRowsPerPage;
                  return SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: Text("Vaccines"),
                      sortColumnIndex: _columnIndex,
                      sortAscending: _isSortAscending,
                      onSelectAll: (isAllChecked) =>
                          _tableDataSource.selectAll(isAllChecked),
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
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add),
                          tooltip: addVaccineTooltip,
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, Routes.keyVaccineAdd);
                          },
                        ),
                      ],
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text("No."),
                          numeric: true,
                          onSort: (_, __) {},
                        ),
                        DataColumn(
                          label: Text("VID."),
                          tooltip: "Vaccine ID",
                          onSort: (ci, isAscending) =>
                              _sort<String>((v) => v.batchNo, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("BNo."),
                          tooltip: "Batch Number",
                          onSort: (ci, isAscending) =>
                              _sort<String>((v) => v.batchNo, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("Name"),
                          onSort: (ci, isAscending) =>
                              _sort<String>((v) => v.name, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("TD"),
                          tooltip: "Target Disease",
                          onSort: (ci, isAscending) => _sort<String>(
                              (v) => v.targetDisease, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("Manufacturer"),
                          tooltip: "Vaccine manufacturer",
                          onSort: (ci, isAscending) => _sort<String>(
                              (v) => v.manufacturer, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("DoM"),
                          tooltip: "Date of Manufacture",
                          onSort: (ci, isAscending) => _sort<String>(
                              (v) => v.manufactureDate, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("DoE"),
                          tooltip: "Date of Expiry",
                          onSort: (ci, isAscending) => _sort<String>(
                              (v) => v.expiryDate, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("Description"),
                          tooltip: "Description of vaccine",
                          onSort: (ci, isAscending) => _sort<String>(
                              (v) => v.description, ci, isAscending),
                        ),
                      ],
                      source: _tableDataSource,
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: vaccineList.length,
                    itemBuilder: (context, position) {
                      var vaccine = vaccineList[position];
                      bool _selected = vaccine.isSelected;
                      return Card(
                        margin: EdgeInsets.only(
                          right: Constants.defaultPadding,
                          left: Constants.defaultPadding,
                          top: Constants.defaultPadding / 2,
                          bottom: Constants.defaultPadding / 2,
                        ),
                        child: ListTile(
                          leading: Text(
                            "${position + 1}",
                            style: TextStyle(
                              color: _selected
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context).textTheme.body1.color,
                            ),
                          ),
                          title: Text(vaccine.name),
                          subtitle: vaccine.targetDisease != null
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text(vaccine.targetDisease)),
                                    Expanded(child: Text(vaccine.batchNo)),
                                  ],
                                )
                              : null,
                          selected: vaccine.isSelected,
                          onTap: () {
                            // TODO: Implement update...
                          },
                          trailing: IconButton(
                            icon: _selected
                                ? Icon(
                                    Icons.check_box,
                                    color: Theme.of(context).accentColor,
                                  )
                                : Icon(Icons.check_box_outline_blank),
                            onPressed: () {
                              setState(() {
                                _selected = _selected ? false : true;

                                _tableDataSource.onRowSelected(
                                    vaccine, _selected);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
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
