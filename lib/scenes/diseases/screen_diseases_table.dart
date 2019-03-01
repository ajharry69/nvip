import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/diseases_repo.dart';
import 'package:nvip/data_repo/tables/data_source_diseases.dart';
import 'package:nvip/models/disease.dart';
import 'package:nvip/scenes/diseases/screen_disease_add.dart';

class DiseasesTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _DiseasesScreenBody();
}

class _DiseasesScreenBody extends StatefulWidget {
  @override
  __DiseasesScreenBodyState createState() => __DiseasesScreenBodyState();
}

class __DiseasesScreenBodyState extends State<_DiseasesScreenBody> {
  bool _showTableView = true;
  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  int _columnIndex = 1;
  bool _isSortAscending = true;
  Future<List<Disease>> _diseases;
  DiseasesTableDataSource _tableDataSource;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  void _sort<T>(Comparable<T> getField(Disease d), int columnIndex,
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
    _diseases = DiseaseDataRepo().getDiseases();
    _rowsPerPage = _defaultRowsPerPage;
    _rowsPerPage1 = _defaultRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    var addDiseaseTooltip = "Add new disease";
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, Routes.keyHome);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Diseases"),
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
              tooltip: addDiseaseTooltip,
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddDiseaseScreen(
                            callerId: AddDiseaseCaller.table,
                          ),
                    ));
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
          tooltip: addDiseaseTooltip,
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AddDiseaseScreen(
                        callerId: AddDiseaseCaller.table,
                      ),
                ));
          },
        ),
        body: FutureBuilder<List<Disease>>(
          future: _diseases,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Constants.showHasNoDataWidget(
                  context,
                  "${Constants.refinedExceptionMessage(snapshot.error)} Press "
                  "the (+) button to add a new disease.");
            } else {
              if (snapshot.hasData) {
                var diseaseList = snapshot.data;
                _tableDataSource = DiseasesTableDataSource(diseaseList);
                if (_showTableView) {
                  var tableItemsCount = _tableDataSource.rowCount;
                  var isRowCountLessDefaultRowsPerPage =
                      tableItemsCount < _defaultRowsPerPage;
                  _rowsPerPage1 = isRowCountLessDefaultRowsPerPage
                      ? tableItemsCount
                      : _defaultRowsPerPage;
                  return SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: Text("Vaccine Preventable Diseases Table"),
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
                          _tableDataSource.selectAll(isAllChecked),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add),
                          tooltip: addDiseaseTooltip,
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddDiseaseScreen(
                                        callerId: AddDiseaseCaller.table,
                                      ),
                                ));
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
                          label: Text("Name"),
                          onSort: (ci, isAscending) =>
                              _sort<String>((d) => d.name, ci, isAscending),
                        ),
                        DataColumn(
                          label: Text("Description"),
                          onSort: (ci, isAscending) => _sort<String>(
                              (d) => d.description, ci, isAscending),
                        ),
                      ],
                      source: _tableDataSource,
                    ),
                  );
                } else {
                  return ListView.separated(
                    itemBuilder: (context, position) {
                      var disease = diseaseList[position];
                      bool _selected = disease.isSelected;
                      return ListTile(
                        leading: Text(
                          "${position + 1}",
                          style: TextStyle(
                            color: _selected
                                ? Theme.of(context).accentColor
                                : Theme.of(context).textTheme.body1.color,
                          ),
                        ),
                        title: Text(disease.name),
                        subtitle: Text(disease.description),
                        selected: disease.isSelected,
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
                                  disease, _selected);
                            });
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, position) => Divider(),
                    itemCount: diseaseList.length,
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
