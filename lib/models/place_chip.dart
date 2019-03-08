class PlaceChipEntry {
  final String name;

  PlaceChipEntry(this.name);

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
