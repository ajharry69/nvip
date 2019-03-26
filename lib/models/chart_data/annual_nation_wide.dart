import 'package:nvip/models/chart_data/disease.dart';

class AnnualChartData {
  static final _keyYear = "year";
  static final _keyDiseases = "diseases";
  final int year;
  final List<DiseaseChartData> diseaseChartData;

  AnnualChartData({this.year, this.diseaseChartData});

  factory AnnualChartData.fromMap(dynamic dataMap) {
    List diseases = dataMap[_keyDiseases];
    return AnnualChartData(
      year: dataMap[_keyYear],
      diseaseChartData:
          diseases.map((datum) => DiseaseChartData.fromMap(datum)).toList(),
    );
  }
}
