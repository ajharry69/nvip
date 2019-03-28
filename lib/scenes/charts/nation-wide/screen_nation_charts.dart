import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/chart_data_repo.dart';
import 'package:nvip/models/chart_data/annual_nation_wide.dart';
import 'package:nvip/models/chart_data/disease.dart';
import 'package:nvip/widgets/charts/bar_stacked.dart';
import 'package:nvip/widgets/data_fetch_error_widget.dart';
import 'package:nvip/widgets/token_error_widget.dart';

class ScreenNationCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _NationChartsBody();
}

class _NationChartsBody extends StatefulWidget {
  @override
  __NationChartsBodyState createState() => __NationChartsBodyState();
}

class __NationChartsBodyState extends State<_NationChartsBody> {
  int _currentStep = 0;
  Future<List<AnnualChartData>> _chartData;

  Future getChartData() async {
    try {
      _chartData = ChartDataRepo().nationChartData;
    } on Exception catch (err) {
      print(Constants.refinedExceptionMessage(err));
    }
  }

  List<DiseaseChartData> _getDiseaseXSortedByYear(
      List<DiseaseChartData> diseaseData, String diseaseName) {
    List<DiseaseChartData> diseases = List();

    diseaseData.forEach((d) {
      if (d.disease == diseaseName) diseases.add(d);
    });

    _sort<String>(
        diseaseData: diseases, getField: (d) => d.disease, isAscending: true);
    return diseases;
  }

  void _sort<T>(
      {List<DiseaseChartData> diseaseData,
      Comparable<T> getField(DiseaseChartData d),
      bool isAscending}) {
    diseaseData.sort((a, b) {
      if (!isAscending) {
        final DiseaseChartData c = a;
        a = b;
        b = c;
      }

      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
  }

  Iterable<charts.Series<DiseaseChartData, String>> _getChartDiseasesData(
      List<DiseaseChartData> diseaseData) sync* {
    for (var chartDatum in diseaseData) {
      var disease = chartDatum.disease;
      var chartData = _getDiseaseXSortedByYear(diseaseData, disease);
      yield charts.Series<DiseaseChartData, String>(
        id: "$disease(NI)",
        seriesCategory: disease,
        measureFn: (datum, _) => datum.legible - datum.immunized,
        domainFn: (datum, _) => Constants.wordInitials(str: datum.disease),
        data: chartData,
      );
      yield charts.Series<DiseaseChartData, String>(
        id: "$disease(I)",
        seriesCategory: disease,
        measureFn: (datum, _) => datum.immunized,
        domainFn: (datum, _) => Constants.wordInitials(str: datum.disease),
        data: chartData,
      );
    }
  }

  Iterable<Step> _getChartWidgets(List<AnnualChartData> chartData) sync* {
    for (AnnualChartData cd in chartData) {
      yield Step(
        content: SizedBox(
          height: Constants.graphHeight,
          child: StackedBarChart(
            _getChartDiseasesData(cd.diseaseChartData).toList(),
            animate: true,
          ),
        ),
        title: Text(cd.year.toString()),
        isActive: true,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getChartData();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<AnnualChartData>>(
        future: _chartData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            var errorMessage =
                Constants.refinedExceptionMessage(snapshot.error);

            var isTokenError =
                snapshot.error.toString().contains(Constants.tokenErrorType);

            return isTokenError
                ? TokenErrorWidget()
                : DataFetchErrorWidget(message: errorMessage);
          } else {
            if (snapshot.hasData) {
              var chartData = snapshot.data;
              return Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepTapped: (pos) {
                  setState(() {
                    _currentStep = pos;
                  });
                },
                onStepContinue: () {
                  setState(() {
                    if (_currentStep < chartData.length - 1) ++_currentStep;
                  });
                },
                onStepCancel: () {
                  setState(() {
                    if (_currentStep > 0) --_currentStep;
                  });
                },
                steps: _getChartWidgets(chartData).toList(),
              );
            }
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
}
