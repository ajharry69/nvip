import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/children_repo.dart';
import 'package:nvip/data_repo/tables/data_source_children.dart';
import 'package:nvip/models/child.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/children/screen_child_register.dart';

class ChildrenTableScreen extends StatelessWidget {
  final User user;

  const ChildrenTableScreen({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) => _ChildrenScreenBody(user: user);
}

class _ChildrenScreenBody extends StatefulWidget {
  final User user;

  const _ChildrenScreenBody({Key key, this.user}) : super(key: key);

  @override
  __ChildrenScreenBodyState createState() => __ChildrenScreenBodyState();
}

class __ChildrenScreenBodyState extends State<_ChildrenScreenBody> {
  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  bool _isSortAscending = true;
  int _sortColumnIndex = 1;
  ChildrenTableDataSource _childrenDataSource;
  Future<List<Child>> _children;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  __ChildrenScreenBodyState();

  void _sort<T>(
      Comparable<T> getField(Child d), int columnIndex, bool isAscending) {
    _childrenDataSource.sort(getField, isAscending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _isSortAscending = isAscending;
    });
  }

  @override
  void initState() {
    super.initState();
    _children = ChildrenDataRepo().getChildren();
    setState(() {
      _rowsPerPage = _defaultRowsPerPage;
      _rowsPerPage1 = _defaultRowsPerPage;
    });
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
          title: Text("Children"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Constants.backIcon),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.keyHome);
            },
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.person_add),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RegisterChildScreen(
                                callerId: RegisterCallerId.table,
                              )));
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          tooltip: "Register new child with ${Constants.appName}",
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => RegisterChildScreen(
                          callerId: RegisterCallerId.table,
                        )));
          },
        ),
        body: FutureBuilder<List<Child>>(
          future: _children,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Constants.showHasNoDataWidget(
                  context,
                  "${Constants.refinedExceptionMessage(snapshot.error)}. "
                  "Press the button below to register your child(ren).");
            } else {
              if (snapshot.hasData) {
                var childrenList = snapshot.data;
                _childrenDataSource = ChildrenTableDataSource(childrenList);
                var tableItemsCount = _childrenDataSource.rowCount;
                var isRowCountLessDefaultRowsPerPage =
                    tableItemsCount < _defaultRowsPerPage;
                _rowsPerPage1 = isRowCountLessDefaultRowsPerPage
                    ? tableItemsCount
                    : _defaultRowsPerPage;

                return SingleChildScrollView(
                  child: PaginatedDataTable(
                    header: Text("Children Table"),
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
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _isSortAscending,
                    onSelectAll: (isSelectAll) =>
                        _childrenDataSource.selectAll(isSelectAll),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.person_add),
                        tooltip: "Register a new child",
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterChildScreen(
                                        callerId: RegisterCallerId.table,
                                      )));
                        },
                      )
                    ],
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text("No."),
                        numeric: true,
                        onSort: (ci, isSortAscending) => _sort<num>(
                            (c) => childrenList.indexOf(c),
                            ci,
                            isSortAscending),
                      ),
                      DataColumn(
                        label: Text("B/C No"),
                        onSort: (index, ascending) => _sort<String>(
                            (Child c) => c.birthCertNo, index, ascending),
                      ),
                      DataColumn(
                        label: Text("Sir Name"),
                        onSort: (index, ascending) => _sort<String>(
                            (Child c) => c.sName, index, ascending),
                      ),
                      DataColumn(
                        label: Text("First Name"),
                        onSort: (index, ascending) => _sort<String>(
                            (Child c) => c.fName, index, ascending),
                      ),
                      DataColumn(
                        label: Text("Last Name"),
                        onSort: (index, ascending) => _sort<String>(
                            (Child c) => c.lName, index, ascending),
                      ),
                      DataColumn(
                        label: Text("Gender"),
                        onSort: (index, ascending) => _sort<String>(
                            (Child c) => c.gender, index, ascending),
                      ),
                      DataColumn(
                        label: Text("D.O.B"),
                        onSort: (index, ascending) =>
                            _sort<String>((Child c) => c.dob, index, ascending),
                      ),
                      DataColumn(
                        label: Text("A.O.R"),
                        onSort: (index, ascending) =>
                            _sort<String>((Child c) => c.aor, index, ascending),
                      ),
                      DataColumn(
                        label: Text("Father Id"),
                        numeric: true,
                        onSort: (index, ascending) => _sort<String>(
                            (Child c) => c.fatherId, index, ascending),
                      ),
                      DataColumn(
                        label: Text("Mother Id"),
                        numeric: true,
                        onSort: (index, ascending) => _sort<String>(
                            (Child c) => c.motherId, index, ascending),
                      ),
                    ],
                    source: _childrenDataSource,
                  ),
                );
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
