import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/disease_chip.dart';

class DiseasesChipTags extends StatefulWidget {
  final List<dynamic> diseases;

  const DiseasesChipTags({Key key, this.diseases}) : super(key: key);

  @override
  _DiseasesChipTagsState createState() => _DiseasesChipTagsState(diseases);
}

class _DiseasesChipTagsState extends State<DiseasesChipTags> {
  final List<dynamic> diseases;
  List<DiseaseChipEntry> _diseases = List();

  _DiseasesChipTagsState(this.diseases);

  Iterable<Widget> get diseasesWidgets sync* {
    for (DiseaseChipEntry disease in _diseases) {
      yield Padding(
        padding: const EdgeInsets.only(
          top: Dimensions.defaultPadding / 2,
          right: Dimensions.defaultPadding,
        ),
        child: Chip(
//          avatar: CircleAvatar(
//            child: Center(
//              child: Text(
//                disease.initials,
//                textAlign: TextAlign.center,
//              ),
//            ),
//          ),
          label: Text(disease.name),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    diseases.forEach((d) => _diseases.add(DiseaseChipEntry("$d")));
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
