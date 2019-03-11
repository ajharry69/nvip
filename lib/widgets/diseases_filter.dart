import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/diseases_repo.dart';
import 'package:nvip/models/disease_chip.dart';

class DiseasesFilter extends StatefulWidget {
  final List<String> filters;

  const DiseasesFilter({Key key, this.filters}) : super(key: key);

  @override
  _DiseasesFilterState createState() => _DiseasesFilterState(filters);
}

class _DiseasesFilterState extends State<DiseasesFilter> {
  final List<String> filters;
  List<DiseaseChipEntry> _diseases = List();

  _DiseasesFilterState(this.filters);

  Iterable<Widget> get diseasesWidgets sync* {
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
          selected: filters.contains(disease.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                filters.add(disease.name);
              } else {
                filters.removeWhere((String name) => name == disease.name);
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
