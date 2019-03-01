import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/tables/data_source_users.dart';
import 'package:nvip/models/user.dart';

class AdminsTableScreen extends StatelessWidget {
  final Future<List<User>> userList;

  const AdminsTableScreen({Key key, this.userList}) : super(key: key);

  @override
  Widget build(BuildContext context) => _AdminsTableScreenBody(
        userList: this.userList,
      );
}

class _AdminsTableScreenBody extends StatefulWidget {
  final Future<List<User>> userList;

  const _AdminsTableScreenBody({Key key, this.userList}) : super(key: key);

  @override
  __AdminsTableScreenBodyState createState() =>
      __AdminsTableScreenBodyState(this.userList);
}

class __AdminsTableScreenBodyState extends State<_AdminsTableScreenBody> {
  var _defaultRowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _rowsPerPage = 0;
  int _rowsPerPage1 = 0;
  int _columnIndex = 1;
  bool _isSortAscending = true;
  final Future<List<User>> _userList;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  UsersTableDataSource _tableDataSource;

  __AdminsTableScreenBodyState(this._userList);

  void _sort<T>(
      Comparable<T> getField(User d), int columnIndex, bool isSortAscending) {
    _tableDataSource.sort(getField, isSortAscending);
    setState(() {
      _columnIndex = columnIndex;
      _isSortAscending = isSortAscending;
    });
  }

  @override
  void initState() {
    super.initState();
    _rowsPerPage = _defaultRowsPerPage;
    _rowsPerPage1 = _defaultRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: FutureBuilder<List<User>>(
        future: _userList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Constants.showHasNoDataWidget(
                context, Constants.refinedExceptionMessage(snapshot.error));
          } else {
            if (snapshot.hasData) {
              var userList = snapshot.data;
              if (userList.length > 0) {
                _tableDataSource = UsersTableDataSource(userList);
                var tableItemsCount = _tableDataSource.rowCount;
                var isRowCountLessDefaultRowsPerPage =
                    tableItemsCount < _defaultRowsPerPage;
                _rowsPerPage1 = isRowCountLessDefaultRowsPerPage
                    ? tableItemsCount
                    : _defaultRowsPerPage;
                return SingleChildScrollView(
                  child: PaginatedDataTable(
                    header: Text("Admins Table"),
                    sortColumnIndex: _columnIndex,
                    sortAscending: _isSortAscending,
                    rowsPerPage: isRowCountLessDefaultRowsPerPage
                        ? _rowsPerPage1
                        : _rowsPerPage,
                    onSelectAll: (isAllChecked) =>
                        _tableDataSource.selectAll(isAllChecked),
                    onRowsPerPageChanged: isRowCountLessDefaultRowsPerPage
                        ? null
                        : (rowCount) {
                            setState(() {
                              _rowsPerPage = rowCount;
                            });
                          },
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text("No."),
                        numeric: true,
                        onSort: (ci, ascending) {},
                      ),
                      DataColumn(
                        label: Text("ID No."),
                        onSort: (ci, ascending) =>
                            _sort<String>((user) => user.idNo, ci, ascending),
                      ),
                      DataColumn(
                        label: Text("Sir Name"),
                        onSort: (ci, ascending) =>
                            _sort<String>((user) => user.sName, ci, ascending),
                      ),
                      DataColumn(
                        label: Text("First Name"),
                        onSort: (ci, ascending) =>
                            _sort<String>((user) => user.fName, ci, ascending),
                      ),
                      DataColumn(
                        label: Text("Last Name"),
                        onSort: (ci, ascending) =>
                            _sort<String>((user) => user.lName, ci, ascending),
                      ),
                      DataColumn(
                        label: Text("Email"),
                        onSort: (ci, ascending) =>
                            _sort<String>((user) => user.email, ci, ascending),
                      ),
                      DataColumn(
                        label: Text("Mobile"),
                        onSort: (ci, ascending) => _sort<String>(
                            (user) => user.mobileNo, ci, ascending),
                      ),
                      DataColumn(
                        label: Text("Role"),
                        onSort: (ci, ascending) =>
                            _sort<String>((user) => user.role, ci, ascending),
                      ),
                      DataColumn(
                        label: Text("Active"),
                        onSort: (ci, ascending) {},
                      ),
                    ],
                    source: _tableDataSource,
                  ),
                );
              } else {
                return Constants.showHasNoDataWidget(
                    context,
                    "No Administrator(s) have been registered with "
                    "${Constants.appName}. Please press the 'Add Administrator'"
                    " button above to register an Administrator.");
              }
            }
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
