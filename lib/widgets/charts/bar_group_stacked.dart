import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class GroupedStackedBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GroupedStackedBarChart(this.seriesList, {this.animate});

  factory GroupedStackedBarChart.withSampleData() {
    return new GroupedStackedBarChart(
      createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.groupedStacked,
//      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [
        charts.SeriesLegend(
          position: charts.BehaviorPosition.top,
          showMeasures: true,
          desiredMaxColumns: 2,
        )
      ],
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> createSampleData() {
    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop A',
        seriesCategory: 'A',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: [
          new OrdinalSales('2014', 20),
          new OrdinalSales('2015', 25),
          new OrdinalSales('2016', 100),
          new OrdinalSales('2017', 75),
        ],
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet A',
        seriesCategory: 'A',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: [
          new OrdinalSales('2014', 1), // TODO
          new OrdinalSales('2015', 50),
          new OrdinalSales('2016', 10),
          new OrdinalSales('2017', 20),
        ],
      ),
//      new charts.Series<OrdinalSales, String>(
//        id: 'Desktop B',
//        seriesCategory: 'B',
//        domainFn: (OrdinalSales sales, _) => sales.year,
//        measureFn: (OrdinalSales sales, _) => sales.sales,
//        data: [
//          new OrdinalSales('2014', 25),
//          new OrdinalSales('2015', 25),
//          new OrdinalSales('2016', 100),
//          new OrdinalSales('2017', 75),
//        ],
//      ),
//      new charts.Series<OrdinalSales, String>(
//        id: 'Tablet B',
//        seriesCategory: 'B',
//        domainFn: (OrdinalSales sales, _) => sales.year,
//        measureFn: (OrdinalSales sales, _) => sales.sales,
//        data: [
//          new OrdinalSales('2014', 0), // TODO
//          new OrdinalSales('2015', 50),
//          new OrdinalSales('2016', 10),
//          new OrdinalSales('2017', 20),
//        ],
//      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
