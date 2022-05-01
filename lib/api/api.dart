import 'package:charts_flutter/flutter.dart' as charts;

abstract class ApiInterface {
  String baseUrl;
  String displayName;

  bool get hasDaytimeAxis;
  bool get hasStacked;
  bool get defaultParameterDaytime;
  bool get defaultParameterStacked;
  String get defaultParameterChartType; /// [line, bar]

  bool get hasLineChart;
  bool get hasBarChart;

  List<CustomApiParameter> parameters;

  ApiInterface({required this.baseUrl, required this.displayName, required this.parameters});
  Future<dynamic> records({int limit = 10, int offset = 0});
  Future<dynamic> next({required dynamic old});
}

abstract class ApiResult {
  /// The number of element fetched by the API
  int get count;
  int get maxCount;
  charts.NumericExtents get numericExtents;

  List<charts.Series<dynamic, T>> lineChartData<T>({bool stacked = false,
    bool daytime = false, List<CustomApiParameter> parameters});
  List<charts.Series<dynamic, T>> barChartData<T>({bool stacked = false,
    bool daytime = false, List<CustomApiParameter> parameters});
}

class CustomApiParameter<T> {
  final String label;
  final T defaultValue;
  T value;

  CustomApiParameter({required this.label, required this.defaultValue}) : value = defaultValue;
}