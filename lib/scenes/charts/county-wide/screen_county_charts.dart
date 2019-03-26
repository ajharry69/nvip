import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/chart_data_repo.dart';
import 'package:nvip/models/county_data.dart';
import 'package:nvip/models/disease_data.dart';
import 'package:nvip/scenes/_demo/charts/bar_group_stacked.dart';
import 'package:nvip/widgets/data_fetch_error_widget.dart';
import 'package:nvip/widgets/token_error_widget.dart';

class ScreenCountyCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _CountyChartsBody();
}

class _CountyChartsBody extends StatefulWidget {
  @override
  __CountyChartsBodyState createState() => __CountyChartsBodyState();
}

class __CountyChartsBodyState extends State<_CountyChartsBody> {
  int _currentStep = 0;
  Future<List<CountyChartData>> _chartData;

  @override
  void initState() {
    super.initState();
    getChartData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CountyChartData>>(
      future: _chartData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          var errorMessage = Constants.refinedExceptionMessage(snapshot.error);

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

  Future getChartData() async {
    try {
      _chartData = ChartDataRepo().countyChartData;
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

    _sort<num>(
        diseaseData: diseases, getField: (d) => d.year, isAscending: true);
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
        domainFn: (datum, _) => "${datum.year}",
        data: chartData,
      );
      yield charts.Series<DiseaseChartData, String>(
        id: "$disease(I)",
        seriesCategory: disease,
        measureFn: (datum, _) => datum.immunized,
        domainFn: (datum, _) => "${datum.year}",
        data: chartData,
      );
    }
  }

  Iterable<Step> _getChartWidgets(List<CountyChartData> chartData) sync* {
    for (CountyChartData cd in chartData) {
      yield Step(
        title: Text(cd.county),
        isActive: true,
        content: SizedBox(
          height: Constants.graphHeight,
          child: GroupedStackedBarChart(
            _getChartDiseasesData(cd.diseaseChartData).toList(),
            animate: true,
          ),
        ),
      );
    }
  }
}
