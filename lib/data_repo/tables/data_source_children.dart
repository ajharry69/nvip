import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/child.dart';
import 'package:nvip/models/immunization_dose.dart';
import 'package:rounded_modal/rounded_modal.dart';

class ChildrenTableDataSource extends DataTableSource {
  final dateFormat = DateFormat(Constants.dateFormatLong);
  final List<Child> children;
  final BuildContext context;
  int _childrenSelectedCount = 0;

  ChildrenTableDataSource({this.children, this.context});

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= children.length) return null;
    final Child child = children[index];
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
        DataCell(Text(child.birthCertNo), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.sName), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.fName), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.lName), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.gender), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.dob), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.aor), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.fatherId), onTap: () => _onRowSelected(child)),
        DataCell(Text(child.motherId), onTap: () => _onRowSelected(child)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => children.length;

  @override
  int get selectedRowCount => _childrenSelectedCount;

  void sort<T>(Comparable<T> getField(Child d), bool isAscending) {
    Constants.getSorted<Child, T>(
        list: children, getField: getField, isAscending: isAscending);
    notifyListeners();
  }

  void selectAll(bool isAllChecked) {
    children.forEach((child) => child.isSelected = isAllChecked);
    _childrenSelectedCount = isAllChecked ? children.length : 0;
    notifyListeners();
  }

  void _onRowSelected(Child child) {
    showRoundedModalBottomSheet(
      radius: 16,
      context: context,
      builder: (BuildContext context) {
        var sortedDoseList = Constants.getSorted<ImmunizationDose, String>(
          list: child.immunizationDoses,
          getField: (d) => d.nextImmunizationDate,
        );
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.defaultPadding * 2,
            horizontal: Dimensions.defaultPadding * 2,
          ),
          child: ListView(
            children: _listWidgets(child, sortedDoseList).toList(),
          ),
        );
      },
    );
  }

  Iterable<Widget> _listWidgets(
      Child child, List<ImmunizationDose> doseList) sync* {
    var childName =
        "${child.sName} ${child.fName} ${child.lName}".trimRight().trimLeft();
    yield Container(
      padding: EdgeInsets.only(bottom: Dimensions.defaultPadding * 2),
      child: Center(
        child: Text(
          childName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1.merge(
                TextStyle(
                  fontFamily: "Bree_Serif",
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
        ),
      ),
    );
    for (var i = 0; i < doseList.length; i++) {
      var dose = doseList[i];
      var diseaseInitials = Constants.wordInitials(str: dose.disease);
//      var lastImmunizationDate = dose.lastImmunizationDate;
      var nextImmunizationDate = dose.nextImmunizationDate;
      yield Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Center(
                child: Text(
                  diseaseInitials,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "${dose.disease}(${dose.vaccine})",
                  style: Theme.of(context).textTheme.subhead.merge(
                        TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ),
                Text(
                  "(${dose.administered}/${dose.recommended} doses)",
                  style: Theme.of(context).textTheme.subhead.merge(
                        TextStyle(
                          fontFamily: "Courgette",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Dimensions.defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
//              Text(
//                lastImmunizationDate != null && lastImmunizationDate != ''
//                    ? dateFormat.format(DateTime.tryParse(lastImmunizationDate))
//                    : "YYYY-MM-DD",
//                style: Theme.of(context).textTheme.body1,
//              ),
                  Text(
                    nextImmunizationDate != null && nextImmunizationDate != ''
                        ? dateFormat
                            .format(DateTime.tryParse(nextImmunizationDate))
                        : "YYYY-MM-DD",
                    style: Theme.of(context).textTheme.body1,
                  ),
                  Text(
                    "Approx, ${dose.daysToNext} days",
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.defaultPadding),
            child: Divider(
              height: 1,
              color: Colors.black54,
            ),
          )
        ],
      );
    }
  }
}
