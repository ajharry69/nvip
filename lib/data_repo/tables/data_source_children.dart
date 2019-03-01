import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/child.dart';

class ChildrenTableDataSource extends DataTableSource {
  final List<Child> _children;
  int _childrenSelectedCount = 0;

  ChildrenTableDataSource(this._children);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _children.length) return null;
    final Child child = _children[index];
    return DataRow.byIndex(
      index: index,
      selected: child.isSelected,
      onSelectChanged: (selected) {
        if (child.isSelected != selected) {
          _childrenSelectedCount += selected ? 1 : -1;
          child.isSelected = selected;
          notifyListeners();
        }
      },
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(child.birthCertNo),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.sName),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.fName),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.lName),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.gender),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.dob),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.aor),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.fatherId),
            onTap: () => Constants.showToast(child.fName)),
        DataCell(Text(child.motherId),
            onTap: () => Constants.showToast(child.fName)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _children.length;

  @override
  int get selectedRowCount => _childrenSelectedCount;

  void sort<T>(Comparable<T> getField(Child d), bool isAscending) {
    _children.sort((Child a, Child b) {
      if (!isAscending) {
        final Child c = a;
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
    _children.forEach((child) => child.isSelected = isAllChecked);
    _childrenSelectedCount = isAllChecked ? _children.length : 0;
    notifyListeners();
  }
}
