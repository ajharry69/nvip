import 'package:flutter/material.dart';
import 'package:nvip/models/user.dart';

class UsersTableDataSource extends DataTableSource {
  final List<User> _users;
  int _numOfRowsSelected = 0;

  UsersTableDataSource(this._users);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _users.length) return null;
    final User user = _users[index];
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
  int get rowCount => _users.length;

  @override
  int get selectedRowCount => _numOfRowsSelected;

  void sort<T>(Comparable<T> getField(User d), bool isAscending) {
    _users.sort((a, b) {
      if (isAscending) {
        final User c = a;
        a = b;
        b = c;
      }

      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  void selectAll(bool isAllChecked) {
    _users.forEach((user) => user.isSelected = isAllChecked);
    _numOfRowsSelected = isAllChecked ? _users.length : 0;
    notifyListeners();
  }
}
