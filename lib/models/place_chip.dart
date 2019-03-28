import 'package:nvip/constants.dart';

class PlaceChipEntry {
  final String name;

  PlaceChipEntry(this.name);

  String get initials => Constants.wordInitials(str: name);
}
