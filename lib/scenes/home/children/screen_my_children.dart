import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/children_repo.dart';
import 'package:nvip/data_repo/tables/data_source_children.dart';
import 'package:nvip/models/child.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/children/screen_child_register.dart';

class MyChildrenScreen extends StatelessWidget {
  final User _user;

  const MyChildrenScreen([this._user]);

  @override
  Widget build(BuildContext context) => _MyChildrenScreenBody(this._user);
}

class _MyChildrenScreenBody extends StatefulWidget {
  final User _user;

  const _MyChildrenScreenBody([this._user]);

  @override
  __MyChildrenScreenBodyState createState() =>
      __MyChildrenScreenBodyState(this._user);
}

class __MyChildrenScreenBodyState extends State<_MyChildrenScreenBody>
    with AutomaticKeepAliveClientMixin<_MyChildrenScreenBody> {
  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  bool _isSortAscending = true;
  int _sortColumnIndex = 1;
  final User _user;
  ChildrenTableDataSource _childrenDataSource;
  Future<List<Child>> _children;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  __MyChildrenScreenBodyState(this._user);

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
    _children =
        ChildrenDataRepo().getChildren(no: Constants.childrenRecNoParent);
    _rowsPerPage = _defaultRowsPerPage;
    _rowsPerPage1 = _defaultRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _user != null
          ? FloatingActionButton(
              child: Icon(Icons.person_add),
              tooltip: "Register a new child",
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterChildScreen(
                              callerId: RegisterCallerId.tab,
                            )));
              },
            )
          : null,
      body: FutureBuilder<List<Child>>(
        future: _children,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Constants.noDataWidget(
                context,
                _user != null
                    ? "You have no children registered with ${Constants.appName}. "
                        "Press the button below to register your child(ren)."
                    : "You must be a registered ${Constants.appName} to access "
                    "to access this service.");
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
                  header: Text("${_user.fName}'s child(ren) table"),
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
                                      callerId: RegisterCallerId.tab,
                                    )));
                      },
                    )
                  ],
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text("No."),
                      numeric: true,
                      onSort: (ci, isSortAscending) => _sort<num>(
                          (c) => childrenList.indexOf(c), ci, isSortAscending),
                    ),
                    DataColumn(
                      label: Text("B/C No"),
                      onSort: (index, ascending) => _sort<String>(
                          (Child c) => c.birthCertNo, index, ascending),
                    ),
                    DataColumn(
                      label: Text("Sir Name"),
                      onSort: (index, ascending) =>
                          _sort<String>((Child c) => c.sName, index, ascending),
                    ),
                    DataColumn(
                      label: Text("First Name"),
                      onSort: (index, ascending) =>
                          _sort<String>((Child c) => c.fName, index, ascending),
                    ),
                    DataColumn(
                      label: Text("Last Name"),
                      onSort: (index, ascending) =>
                          _sort<String>((Child c) => c.lName, index, ascending),
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
