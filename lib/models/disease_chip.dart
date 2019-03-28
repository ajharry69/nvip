import 'package:nvip/constants.dart';

class DiseaseChipEntry {
  final String name;

  DiseaseChipEntry(this.name);

  String get initials => Constants.wordInitials(str: name);
}
