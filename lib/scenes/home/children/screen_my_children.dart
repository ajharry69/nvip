import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/children_repo.dart';
import 'package:nvip/data_repo/tables/data_source_children.dart';
import 'package:nvip/models/child.dart';
import 'package:nvip/models/user.dart';
import 'package:nvip/scenes/children/screen_child_register.dart';
import 'package:nvip/widgets/data_fetch_error_widget.dart';
import 'package:nvip/widgets/token_error_widget.dart';

class MyChildrenScreen extends StatelessWidget {
  final Future<List<Child>> children;
  final User user;
  final int positionInTab;

  const MyChildrenScreen(
      {Key key, this.user, this.positionInTab, this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _MyChildrenScreenBody(
        positionInTab: this.positionInTab,
        user: this.user,
        children: this.children,
      );
}

class _MyChildrenScreenBody extends StatefulWidget {
  final Future<List<Child>> children;
  final User user;
  final int positionInTab;

  const _MyChildrenScreenBody(
      {Key key, this.user, this.positionInTab, this.children})
      : super(key: key);

  @override
  __MyChildrenScreenBodyState createState() => __MyChildrenScreenBodyState(
      positionInTab: positionInTab,
      user: this.user,
      childrenList: this.children);
}

class __MyChildrenScreenBodyState extends State<_MyChildrenScreenBody>
    with AutomaticKeepAliveClientMixin<_MyChildrenScreenBody> {
  Future<List<Child>> childrenList;
  final User user;
  final int positionInTab;

  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  bool _isSortAscending = true;
  int _sortColumnIndex = 1;
  ChildrenTableDataSource _childrenDataSource;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  __MyChildrenScreenBodyState(
      {this.user, this.positionInTab, this.childrenList});

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
    childrenList =
        ChildrenDataRepo().getChildren(no: Constants.childrenRecNoParent);
    _rowsPerPage = _defaultRowsPerPage;
    _rowsPerPage1 = _defaultRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: user != null
            ? FloatingActionButton(
                heroTag: "fab:home:my_children",
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
          future: childrenList,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              var isTokenError =
                  snapshot.error.toString().contains(Constants.tokenErrorType);

              return isTokenError
                  ? TokenErrorWidget()
                  : DataFetchErrorWidget(
                      message: user != null
                          ? "You have no children registered with ${Constants.appName}. "
                              "Press the button below to register your child(ren)."
                          : "You must be a registered ${Constants.appName} to access "
                              "to access this service.",
                    );
            } else {
              if (snapshot.hasData) {
                var childrenList = snapshot.data;
                _childrenDataSource = ChildrenTableDataSource(
                  children: childrenList,
                  context: context,
                );
                var tableItemsCount = _childrenDataSource.rowCount;
                var isRowCountLessDefaultRowsPerPage =
                    tableItemsCount < _defaultRowsPerPage;
                _rowsPerPage1 = isRowCountLessDefaultRowsPerPage
                    ? tableItemsCount
                    : _defaultRowsPerPage;

                return SingleChildScrollView(
                  child: PaginatedDataTable(
                    header: Text("${user.fName}'s child(ren) table"),
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
                              ),
                            ),
                          );
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
      );
  }

  @override
  bool get wantKeepAlive => true;
}
