import 'package:nvip/models/disease_data.dart';

class CountyChartData {
  static final _keyCounty = "county";
  static final _keyDiseases = "diseases";

  final String county;
  final List<DiseaseChartData> diseaseChartData;

  CountyChartData({this.county, this.diseaseChartData});

  factory CountyChartData.fromMap(dynamic dataMap) {
    List diseases = dataMap[_keyDiseases];
    return CountyChartData(
      county: dataMap[_keyCounty],
      diseaseChartData: diseases
          .map((datumMap) => DiseaseChartData.fromMap(datumMap))
          .toList(),
    );
  }
}
