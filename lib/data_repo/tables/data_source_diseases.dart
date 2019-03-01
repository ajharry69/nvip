import 'package:flutter/material.dart';
import 'package:nvip/models/disease.dart';

class DiseasesTableDataSource extends DataTableSource {
  final List<Disease> _diseases;
  int _numOfRowsSelected = 0;

  DiseasesTableDataSource(this._diseases);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _diseases.length) return null;
    final Disease disease = _diseases[index];
    return DataRow.byIndex(
      index: index,
      selected: disease.isSelected,
      onSelectChanged: (selected) => onRowSelected(disease, selected),
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(disease.name)),
        DataCell(Text(disease.description ?? "")),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _diseases.length;

  @override
  int get selectedRowCount => _numOfRowsSelected;

  void sort<T>(Comparable<T> getField(Disease d), bool isAscending) {
    _diseases.sort((a, b) {
      if (isAscending) {
        final Disease c = a;
        a = b;
        b = c;
      }

      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  void onRowSelected(Disease disease, bool selected) {
    if (disease.isSelected != selected) {
      _numOfRowsSelected += selected ? 1 : -1;
      disease.isSelected = selected;
      notifyListeners();
    }
  }

  void selectAll(bool isAllChecked) {
    _diseases.forEach((d) => d.isSelected = isAllChecked);
    _numOfRowsSelected = isAllChecked ? _diseases.length : 0;
    notifyListeners();
  }
}
