class DiseaseChartData {
  static final _keyDisease = "disease";
  static final _keyYear = "year";
  static final _keyRegistered = "registered";
  static final _keyLegible = "legible";
  static final _keyImmunized = "immunized";

  final String disease;
  final int year;
  final int registered;
  final int legible;
  final int immunized;

  DiseaseChartData(
      {this.disease, this.year, this.registered, this.legible, this.immunized});

  factory DiseaseChartData.fromMap(dynamic dataMap) {
    return DiseaseChartData(
      disease: dataMap[_keyDisease],
      year: dataMap[_keyYear],
      registered: dataMap[_keyRegistered],
      legible: dataMap[_keyLegible],
      immunized: dataMap[_keyImmunized],
    );
  }
}
