import 'package:nvip/constants.dart';
import 'package:nvip/models/county_data.dart';
import 'package:nvip/models/disease_data.dart';
import 'package:nvip/models/server_response.dart';
import 'package:nvip/utils/network_utils.dart';

class ChartDataRepo {
  NetworkUtils _networkUtils = NetworkUtils();

  Future<List<CountyChartData>> get countyChartData async {
    try {
      var response = await _networkUtils.get(Urls.countyChartData,
          headers: await Constants.httpHeaders());

      var sr = ServerResponse.fromMap(response);
      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      List data = response[Constants.keyChartData];
      return data.map((chartMap) => CountyChartData.fromMap(chartMap)).toList();
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }

  Future<List<DiseaseChartData>> get nationChartData async {
    try {
      var response = await _networkUtils.get(Urls.nationChartData,
          headers: await Constants.httpHeaders());

      var sr = ServerResponse.fromMap(response);

      if (sr.isError) {
        print(sr.debugMessage);
        throw Exception(sr.message);
      }

      List data = response[Constants.keyChartData];
      return data.map((dataMap) => DiseaseChartData.fromMap(dataMap)).toList();
    } on Exception catch (err) {
      throw Exception(Constants.refinedExceptionMessage(err));
    }
  }
}
