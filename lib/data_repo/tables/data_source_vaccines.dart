import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/vaccine.dart';

class VaccinesTableDataSource extends DataTableSource {
  final List<Vaccine> vaccines;
  int _numOfRowsSelected = 0;

  VaccinesTableDataSource(this.vaccines);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= vaccines.length) return null;
    final Vaccine vaccine = vaccines[index];
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
        DataCell(Text(vaccine.deliveryMode)),
        DataCell(Text(vaccine.isShared ? 'Yes' : 'No')),
        DataCell(Text(vaccine.isUsed ? 'Yes' : 'No')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => vaccines.length;

  @override
  int get selectedRowCount => _numOfRowsSelected;

  void sort<T>(Comparable<T> getField(Vaccine d), bool isAscending) {
    Constants.getSorted<Vaccine, T>(
        list: vaccines, getField: getField, isAscending: isAscending);
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
    vaccines.forEach((vaccine) => vaccine.isSelected = isAllChecked);
    _numOfRowsSelected = isAllChecked ? vaccines.length : 0;
    notifyListeners();
  }
}
