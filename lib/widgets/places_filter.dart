import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/centers_repo.dart';
import 'package:nvip/models/place_chip.dart';

class PlacesFilter extends StatefulWidget {
  final List<String> filters;

  const PlacesFilter({Key key, this.filters}) : super(key: key);
  @override
  _PlacesFilterState createState() => _PlacesFilterState(filters);
}

class _PlacesFilterState extends State<PlacesFilter> {
  final List<String> filters;
  List<PlaceChipEntry> _places = List();

  _PlacesFilterState(this.filters);

  Iterable<Widget> get placesWidgets sync* {
    for (PlaceChipEntry place in _places) {
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
          label: Text(place.name),
          selected: filters.contains(place.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                filters.add(place.name);
              } else {
                filters.removeWhere((String name) => name == place.name);
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
    VaccineCentersDataRepo().getCenters().then((centers) {
      Future(() {
        setState(() {
          _places.add(PlaceChipEntry("Nation-wide"));
          centers.forEach((c) {
            _places.add(PlaceChipEntry(c.county));
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
        children: placesWidgets.toList(),
      ),
    );
  }
}
