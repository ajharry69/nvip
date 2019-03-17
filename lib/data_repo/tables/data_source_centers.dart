import 'package:flutter/material.dart';
import 'package:nvip/models/vaccination_center.dart';

class CentersTableDataSource extends DataTableSource {
  final List<VaccineCenter> _centers;
  int _rowsSelectedCount = 0;

  CentersTableDataSource(this._centers);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _centers.length) return null;
    final VaccineCenter center = _centers[index];
    return DataRow.byIndex(
      index: index,
      selected: center.isSelected,
      onSelectChanged: (selected) => onRowSelected(center, selected),
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(center.county)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _centers.length;

  @override
  int get selectedRowCount => _rowsSelectedCount;

  void sort<T extends Object>(
      Comparable<T> getField(VaccineCenter d), bool isAscending) {
    _centers.sort((a, b) {
      if (isAscending) {
        final VaccineCenter c = a;
        a = b;
        b = c;
      }

      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  void onRowSelected(VaccineCenter center, bool selected) {
    if (center.isSelected != selected) {
      _rowsSelectedCount += selected ? 1 : -1;
      center.isSelected = selected;
      notifyListeners();
    }
  }

  void selectAll(bool isAllChecked) {
    _centers.forEach((center) => center.isSelected = isAllChecked);
    _rowsSelectedCount = isAllChecked ? _centers.length : 0;
    notifyListeners();
  }
}
