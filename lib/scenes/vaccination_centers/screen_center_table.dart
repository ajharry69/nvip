import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/centers_repo.dart';
import 'package:nvip/data_repo/tables/data_source_centers.dart';
import 'package:nvip/models/vaccination_center.dart';
import 'package:nvip/widgets/data_fetch_error_widget.dart';
import 'package:nvip/widgets/token_error_widget.dart';

class VaccinationCentersTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _CentersScreenBody();
}

class _CentersScreenBody extends StatefulWidget {
  @override
  __CentersScreenBodyState createState() => __CentersScreenBodyState();
}

class __CentersScreenBodyState extends State<_CentersScreenBody> {
  bool _showTableView = true;
  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  int _columnIndex = 1;
  bool _isSortAscending = true;
  Future<List<VaccineCenter>> _centers;
  CentersTableDataSource _tableDataSource;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void _sort<T>(Comparable<T> getField(TableSubCounty c), int columnIndex,
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
    _centers = VaccineCentersDataRepo().getCenters();
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
          title: Text("Vaccination Centers"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_location),
              tooltip: "Add vaccination center",
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.keyPovAdd);
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
        body: FutureBuilder<List<VaccineCenter>>(
          future: _centers,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              var errorMessage =
                  "No vaccination center(s) / place(s) of vaccinations found. "
                  "Press the (+) sign to add a new record.";

              var isTokenError =
                  snapshot.error.toString().contains(Constants.tokenErrorType);

              return isTokenError
                  ? TokenErrorWidget()
                  : DataFetchErrorWidget(message: errorMessage);
            } else {
              if (snapshot.hasData) {
                var centerList = snapshot.data;
                final List<TableSubCounty> tableSubCountyList = List();
                centerList.forEach((center) {
                  center.subCounties.forEach((sc) {
                    tableSubCountyList.add(TableSubCounty(
                        id: sc.id, name: sc.name, county: center.county));
                    return sc;
                  });
                  return center;
                });
                _tableDataSource = CentersTableDataSource(tableSubCountyList);
                if (_showTableView) {
                  var tableItemsCount = _tableDataSource.rowCount;
                  var isRowCountLessDefaultRowsPerPage =
                      tableItemsCount < _defaultRowsPerPage;
                  _rowsPerPage1 = isRowCountLessDefaultRowsPerPage
                      ? tableItemsCount
                      : _defaultRowsPerPage;
                  return SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: Text("Places of Vaccination"),
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
                      sortColumnIndex: _columnIndex,
                      sortAscending: _isSortAscending,
                      onSelectAll: (isAllChecked) =>
                          _tableDataSource?.selectAll(isAllChecked),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add_location),
                          tooltip: "Add vaccination center",
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, Routes.keyPovAdd);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_forever),
                          tooltip: "Delete vaccination center(s).",
                          onPressed: () {
                            Constants.showSnackBar(
                                _scaffoldKey, "Delete button clicked");
                          },
                        )
                      ],
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text("No."),
                          numeric: true,
                          onSort: (ci, isSortAscending) {},
                        ),
                        DataColumn(
                          label: Text("County"),
                          onSort: (ci, isSortAscending) => _sort<String>(
                              (c) => c.county, ci, isSortAscending),
                        ),
                        DataColumn(
                          label: Text("Sub County"),
                          onSort: (ci, isSortAscending) =>
                              _sort<String>((c) => c.name, ci, isSortAscending),
                        ),
                      ],
                      source: _tableDataSource,
                    ),
                  );
                } else {
                  return ListView.separated(
                    itemCount: tableSubCountyList.length,
                    separatorBuilder: (context, position) => Divider(),
                    itemBuilder: (context, position) {
                      var center = tableSubCountyList[position];
                      bool _selected = center.isSelected;
                      return ListTile(
                        leading: Text(
                          "${position + 1}",
                          style: TextStyle(
                            color: _selected
                                ? Theme.of(context).accentColor
                                : Theme.of(context).textTheme.body1.color,
                          ),
                        ),
                        title: Text(center.county),
                        selected: center.isSelected,
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

                              _tableDataSource.onRowSelected(center, _selected);
                            });
                          },
                        ),
                      );
                    },
                  );
                }
              }
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
