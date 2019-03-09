import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/place_chip.dart';

class PlacesChipTags extends StatefulWidget {
  final List<dynamic> centers;

  const PlacesChipTags({Key key, this.centers}) : super(key: key);

  @override
  _PlacesChipTagsState createState() => _PlacesChipTagsState(centers);
}

class _PlacesChipTagsState extends State<PlacesChipTags> {
  final List<dynamic> centers;
  List<PlaceChipEntry> _places = List();

  _PlacesChipTagsState(this.centers);

  Iterable<Widget> get placesWidgets sync* {
    for (PlaceChipEntry place in _places) {
      yield Padding(
        padding: const EdgeInsets.only(
          top: Constants.defaultPadding / 2,
          right: Constants.defaultPadding,
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
          label: Text(place.name),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    centers.forEach((c) => _places.add(PlaceChipEntry("$c")));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: placesWidgets.toList(),
      ),
    );
  }
}
