import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/vaccination_center.dart';

class CentersTableDataSource extends DataTableSource {
  final List<VaccineCenter> centers;
  int _rowsSelectedCount = 0;

  CentersTableDataSource(this.centers);

//  Iterable<Widget> subCountiesWidget(VaccineCenter center)sync*{
//    yield
//    for()
//  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= centers.length) return null;
    final VaccineCenter center = centers[index];
    return DataRow.byIndex(
      index: index,
      selected: center.isSelected,
      onSelectChanged: (selected) => onRowSelected(center, selected),
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(center.county)),
//        DataCell(Text(center.subCounty)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => centers.length;

  @override
  int get selectedRowCount => _rowsSelectedCount;

  void sort<T>(Comparable<T> getField(VaccineCenter d), bool isAscending) {
    Constants.getSorted<VaccineCenter, T>(
        list: centers, getField: getField, isAscending: isAscending);
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
    centers.forEach((center) => center.isSelected = isAllChecked);
    _rowsSelectedCount = isAllChecked ? centers.length : 0;
    notifyListeners();
  }
}
