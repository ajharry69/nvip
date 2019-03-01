import 'package:flutter/material.dart';
import 'package:nvip/models/vaccine.dart';

class VaccinesTableDataSource extends DataTableSource {
  final List<Vaccine> _vaccines;
  int _numOfRowsSelected = 0;

  VaccinesTableDataSource(this._vaccines);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _vaccines.length) return null;
    final Vaccine vaccine = _vaccines[index];
    return DataRow.byIndex(
      index: index,
      selected: vaccine.isSelected,
      onSelectChanged: (selected) => onRowSelected(vaccine, selected),
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(vaccine.vIdNo)),
        DataCell(Text(vaccine.batchNo)),
        DataCell(Text(vaccine.name)),
        DataCell(Text(vaccine.targetDisease)),
        DataCell(Text(vaccine.manufacturer)),
        DataCell(Text(vaccine.manufactureDate)),
        DataCell(Text(vaccine.expiryDate)),
        DataCell(Text(vaccine.description)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _vaccines.length;

  @override
  int get selectedRowCount => _numOfRowsSelected;

  void sort<T>(Comparable<T> getField(Vaccine d), bool isAscending) {
    _vaccines.sort((a, b) {
      if (isAscending) {
        final Vaccine c = a;
        a = b;
        b = c;
      }

      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  void onRowSelected(Vaccine vaccine, bool selected) {
    if (vaccine.isSelected != selected) {
      _numOfRowsSelected += selected ? 1 : -1;
      vaccine.isSelected = selected;
      notifyListeners();
    }
  }

  void selectAll(bool isAllChecked) {
    _vaccines.forEach((vaccine) => vaccine.isSelected = isAllChecked);
    _numOfRowsSelected = isAllChecked ? _vaccines.length : 0;
    notifyListeners();
  }
}
