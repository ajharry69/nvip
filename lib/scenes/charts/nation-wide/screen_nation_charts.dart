import 'package:flutter/material.dart';
import 'package:nvip/constants.dart';
import 'package:nvip/data_repo/network/chart_data_repo.dart';
import 'package:nvip/models/disease_data.dart';
import 'package:nvip/scenes/_demo/charts/bar_group_stacked.dart';
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
  Future<List<DiseaseChartData>> _chartData;

  Future getChartData() async {
    try {
      _chartData = ChartDataRepo().nationChartData;
    } on Exception catch (err) {
      print(Constants.refinedExceptionMessage(err));
    }
  }

  Iterable<Step> _getChartWidgets(List<DiseaseChartData> chartData) sync* {
    for (DiseaseChartData cd in chartData) {
      yield Step(
        content: SizedBox(
          height: Constants.graphHeight,
          child: GroupedStackedBarChart.withSampleData(),
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
  Widget build(BuildContext context) => FutureBuilder<List<DiseaseChartData>>(
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
