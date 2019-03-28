import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/models/place_chip.dart';
import 'package:rounded_modal/rounded_modal.dart';

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
        child: ActionChip(
//          avatar: CircleAvatar(
//            child: Center(
//              child: Text(
//                place.initials,
//                textAlign: TextAlign.center,
//              ),
//            ),
//          ),
          label: Text(place.name),
          onPressed: () {
            showRoundedModalBottomSheet(
                radius: 16,
                context: context,
                builder: (context) {
                  return Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: Constants.defaultPadding,
                      horizontal: Constants.defaultPadding,
                    ),
                    child: Wrap(
                      children: _getSubCountyWidgets([
                        "Starehe",
                        "Kasarani",
                        "Roysambu",
                        "Starehe",
                        "Kasarani",
                        "Roysambu"
                      ]).toList(),
                    ),
                  );
                });
          },
        ),
      );
    }
  }

  Iterable<Widget> _getSubCountyWidgets(List<String> subCounties) sync* {
    for (String subCounty in subCounties) {
      yield Padding(
        padding: const EdgeInsets.only(
          top: Constants.defaultPadding / 2,
          right: Constants.defaultPadding,
        ),
        child: Chip(
          label: Text(subCounty),
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
