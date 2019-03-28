import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/disease.dart';

class DiseasesTableDataSource extends DataTableSource {
  final List<Disease> diseases;
  int _numOfRowsSelected = 0;

  DiseasesTableDataSource(this.diseases);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= diseases.length) return null;
    final Disease disease = diseases[index];
    String spreadBy = "";
    String symptoms = "";
    String complications = "";
    disease.spreadBy.forEach((s) {
      spreadBy += "- $s\n";
    });
    disease.symptoms.forEach((s) {
      symptoms += "- $s\n";
    });
    disease.complications.forEach((c) {
      complications += "- $c\n";
    });
    return DataRow.byIndex(
      index: index,
      selected: disease.isSelected,
      onSelectChanged: (selected) => onRowSelected(disease, selected),
      cells: <DataCell>[
        DataCell(Text("${index + 1}")),
        DataCell(Text(disease.name)),
        DataCell(Text(disease.vaccine)),
        DataCell(Text(spreadBy)),
        DataCell(Text(symptoms)),
        DataCell(Text(complications)),
//        DataCell(Text(disease.description ?? "")),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => diseases.length;

  @override
  int get selectedRowCount => _numOfRowsSelected;

  void sort<T>(Comparable<T> getField(Disease d), bool isAscending) {
    Constants.getSorted<Disease, T>(
        list: diseases, getField: getField, isAscending: isAscending);
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
    diseases.forEach((d) => d.isSelected = isAllChecked);
    _numOfRowsSelected = isAllChecked ? diseases.length : 0;
    notifyListeners();
  }
}
