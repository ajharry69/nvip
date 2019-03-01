import 'package:flutter/material.dart';
import 'package:nvip/models/immunization.dart';

class ImmunizationsTableDataSource extends DataTableSource {
  final List<Immunization> _immunizations;
  int _noRowsSelected = 0;

  ImmunizationsTableDataSource(this._immunizations);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _immunizations.length) return null;
    final Immunization immunization = _immunizations[index];
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
        DataCell(Text(immunization.notes)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _immunizations.length;

  @override
  int get selectedRowCount => _noRowsSelected;

  void sort<T>(Comparable<T> getField(Immunization d), bool isAscending) {
    _immunizations.sort((a, b) {
      if (isAscending) {
        final Immunization c = a;
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
    _immunizations
        .forEach((immunization) => immunization.isSelected = isAllChecked);
    _noRowsSelected = isAllChecked ? _immunizations.length : 0;
    notifyListeners();
  }
}
