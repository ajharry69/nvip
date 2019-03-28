import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/immunization.dart';

class ImmunizationsTableDataSource extends DataTableSource {
  final List<Immunization> immunizations;
  int _noRowsSelected = 0;

  ImmunizationsTableDataSource(this.immunizations);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= immunizations.length) return null;
    final Immunization immunization = immunizations[index];
    return DataRow.byIndex(
      index: index,
      selected: immunization.isSelected,
      onSelectChanged: (selected) {
        if (immunization.isSelected != selected) {
          _noRowsSelected += selected ? 1 : -1;
          immunization.isSelected = selected;
          notifyListeners();
        }
      },
      cells: <DataCell>[
        DataCell(Text('${index + 1}')),
        DataCell(Text(immunization.childName)),
        DataCell(Text(immunization.birthCert)),
        DataCell(Text(immunization.doi)),
        DataCell(Text(immunization.vaccineBatch)),
        DataCell(Text(immunization.diseaseName)),
        DataCell(Text(immunization.pov)),
        DataCell(Text(immunization.hpId)),
        DataCell(Text(immunization.hpName)),
//        DataCell(Text(immunization.notes)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => immunizations.length;

  @override
  int get selectedRowCount => _noRowsSelected;

  void sort<T>(Comparable<T> getField(Immunization d), bool isAscending) {
    Constants.getSorted<Immunization, T>(
        list: immunizations, getField: getField, isAscending: isAscending);

    notifyListeners();
  }

  void selectAll(bool isAllChecked) {
    immunizations
        .forEach((immunization) => immunization.isSelected = isAllChecked);
    _noRowsSelected = isAllChecked ? immunizations.length : 0;
    notifyListeners();
  }
}
