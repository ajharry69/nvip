import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/diseases_repo.dart';
import 'package:nvip/models/disease_chip.dart';

class DiseasesFilter extends StatefulWidget {
  @override
  _DiseasesFilterState createState() => _DiseasesFilterState();
}

class _DiseasesFilterState extends State<DiseasesFilter> {
  List<DiseaseChipEntry> _diseases = List();

  Iterable<Widget> get diseasesWidgets sync* {
    var _filters = Constants.diseaseFilters;
    for (DiseaseChipEntry disease in _diseases) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
//          avatar: CircleAvatar(
//            child: Center(
//              child: Text(
//                disease.initials,
//                textAlign: TextAlign.center,
//              ),
//            ),
//          ),
          label: Text(disease.name),
          selected: _filters.contains(disease.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _filters.add(disease.name);
              } else {
                _filters.removeWhere((String name) => name == disease.name);
              }
            });
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    DiseaseDataRepo().getDiseases().then((diseases) {
      Future(() {
        setState(() {
          diseases.forEach((d) {
            _diseases.add(DiseaseChipEntry(d.name));
          });
        });
      }).catchError((err) => throw Exception(err));
    }).catchError(
        (err) => Constants.showToast(Constants.refinedExceptionMessage(err)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: diseasesWidgets.toList(),
      ),
    );
  }
}
