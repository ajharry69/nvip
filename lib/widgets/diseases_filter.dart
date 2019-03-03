import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/diseases_repo.dart';

class _DiseaseFilterEntry {
  final String name;

  _DiseaseFilterEntry(this.name);

  String get initials {
    var sb = StringBuffer();
    if (name != null) {
      var names = name.split(" ");
      if (names.length >= 2) {
        var initSet = Set<String>();
        names.sublist(0, 1).forEach((x) {
          initSet.add(x.toUpperCase());
        });
        sb.writeAll(initSet);
      } else {
        sb.write(names.first.toUpperCase());
      }
    }

    return sb.toString();
  }
}

class DiseasesFilter extends StatefulWidget {
  @override
  _DiseasesFilterState createState() => _DiseasesFilterState();
}

class _DiseasesFilterState extends State<DiseasesFilter> {
  List<_DiseaseFilterEntry> _diseases = List();

  Iterable<Widget> get diseasesWidgets sync* {
    var _filters = Constants.diseaseFilters;
    for (_DiseaseFilterEntry disease in _diseases) {
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
            _diseases.add(_DiseaseFilterEntry(d.name));
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
