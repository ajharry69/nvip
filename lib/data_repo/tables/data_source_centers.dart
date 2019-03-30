import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/vaccination_center.dart';

class CentersTableDataSource extends DataTableSource {
  final List<TableSubCounty> tableSubCountyList;
  int _rowsSelectedCount = 0;

  CentersTableDataSource(this.tableSubCountyList);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= tableSubCountyList.length) return null;
    final TableSubCounty center = tableSubCountyList[index];
    return DataRow.byIndex(
      index: index,
      selected: center.isSelected,
      onSelectChanged: (selected) => onRowSelected(center, selected),
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(center.county)),
        DataCell(Text(center.name)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => tableSubCountyList.length;

  @override
  int get selectedRowCount => _rowsSelectedCount;

  void sort<T>(Comparable<T> getField(TableSubCounty d), bool isAscending) {
    Constants.getSorted<TableSubCounty, T>(
        list: tableSubCountyList, getField: getField, isAscending: isAscending);
    notifyListeners();
  }

  void onRowSelected(TableSubCounty center, bool selected) {
    if (center.isSelected != selected) {
      _rowsSelectedCount += selected ? 1 : -1;
      center.isSelected = selected;
      notifyListeners();
    }
  }

  void selectAll(bool isAllChecked) {
    tableSubCountyList.forEach((center) => center.isSelected = isAllChecked);
    _rowsSelectedCount = isAllChecked ? tableSubCountyList.length : 0;
    notifyListeners();
  }
}
