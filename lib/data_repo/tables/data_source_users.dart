import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/user.dart';

class UsersTableDataSource extends DataTableSource {
  final List<User> users;
  int _numOfRowsSelected = 0;

  UsersTableDataSource(this.users);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= users.length) return null;
    final User user = users[index];
    return DataRow.byIndex(
      index: index,
      selected: user.isSelected,
      onSelectChanged: (selected) {
        if (user.isSelected != selected) {
          _numOfRowsSelected += selected ? 1 : -1;
          user.isSelected = selected;
          notifyListeners();
        }
      },
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(user.idNo)),
        DataCell(Text(user.sName)),
        DataCell(Text(user.fName)),
        DataCell(Text(user.lName)),
        DataCell(Text(user.email)),
        DataCell(Text(user.mobileNo ?? "")),
        DataCell(Text(user.role.toUpperCase())),
        DataCell(Container(
          alignment: Alignment.center,
          child: user.isVerified
              ? Icon(
                  Icons.verified_user,
                  color: Colors.greenAccent,
                )
              : Icon(
                  Icons.verified_user,
                  color: Colors.redAccent,
                ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => _numOfRowsSelected;

  void sort<T>(Comparable<T> getField(User d), bool isAscending) {
    Constants.getSorted<User, T>(
        list: users, getField: getField, isAscending: isAscending);
    notifyListeners();
  }

  void selectAll(bool isAllChecked) {
    users.forEach((user) => user.isSelected = isAllChecked);
    _numOfRowsSelected = isAllChecked ? users.length : 0;
    notifyListeners();
  }
}
