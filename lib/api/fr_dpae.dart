import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:opendata/api/api.dart';

import 'odsql.dart';

part 'fr_dpae.g.dart';

class FrDpeaApi extends ApiInterface {
  FrDpeaApi() : super(
    baseUrl: "https://open.urssaf.fr/api/v2/catalog/datasets/dpae-mensuelles-france-entiere",
    displayName: "Dpea France",
    parameters: [
      CustomApiParameter(label: "CVS ", defaultValue: true),
    ],
  );

  @override
  Future<FrDpeaApiResult?> records({int limit = 10, int offset = 0}) async {
    var res = await http.get(Uri.parse('$baseUrl/records?select=*&limit=$limit&offset=$offset&order_by=dernier_jour_du_mois'));

    try {
      var json = jsonDecode(res.body);
      return FrDpeaApiResult.fromJson(json);
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<FrDpeaApiResult?> next({required dynamic old}) async {
    if (old is FrDpeaApiResult) {
      var links = old.links.where((element) => element.rel == "next");
      if (links.isNotEmpty && links.length == 1) {
        var url = links.first.href;
        var res = await http.get(Uri.parse(url));
        try {
          var json = jsonDecode(res.body);
          var newData = FrDpeaApiResult.fromJson(json);
          newData.records = old.records + newData.records;
          return newData;
        } on Exception catch (e) {
          print(e);
          return null;
        }
      } else {
        return null;
      }
    } else {
      throw Exception("Old Should be FrDpeaApiResult");
    }
  }

  @override
  bool get defaultParameterDaytime => true;

  @override
  bool get defaultParameterStacked => true;

  @override
  String get defaultParameterChartType => "line";

  @override
  bool get hasBarChart => true;

  @override
  bool get hasDaytimeAxis => true;

  @override
  bool get hasLineChart => true;

  @override
  bool get hasStacked => true;

}

@JsonSerializable()
class FrDpeaApiResult extends OdSQLResult with ApiResult {
  List<FrDpeaRecordListItem> records;

  FrDpeaApiResult(int total_count, List<OdSQLLink> links, this.records)
      : super(total_count, links);

  factory FrDpeaApiResult.fromJson(Map<String, dynamic> json) => _$FrDpeaApiResultFromJson(json);
  Map<String, dynamic> toJson() => _$FrDpeaApiResultToJson(this);

  @override
  charts.NumericExtents get numericExtents =>
      charts.NumericExtents.fromValues(records.map((e) =>
      e.record.fields.dernier_jour_du_mois.microsecondsSinceEpoch));

  @override
  int get count => records.length;

  @override
  int get maxCount => total_count;

  @override
  List<charts.Series<dynamic, T>> lineChartData<T>({bool stacked = false, bool daytime = false, List<CustomApiParameter<dynamic>>? parameters}) {
    var cdiRecords = records.where((element) => element.record.fields.nature_de_contrat == "CDI").toList();
    var cddRecords = records.where((element) => element.record.fields.nature_de_contrat == "CDD de plus d'un mois").toList();

    return [
      new charts.Series(
        id: "CDI",
        data: cdiRecords,
        domainFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (!daytime)
              return record.record.fields.dernier_jour_du_mois.microsecondsSinceEpoch as T;
            else
              return record.record.fields.dernier_jour_du_mois as T;
          }
          throw UnimplementedError();
        },
        measureFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (parameters != null && parameters.where((element) => element.label.contains("CVS")).first.value as bool)
              return record.record.fields.dpae_cvs;
            return record.record.fields.dpae_brut;
          }
          throw UnimplementedError();
        },
      ),
      new charts.Series(
        id: "CDD + 1 Mois",
        data: cddRecords,
        domainFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (!daytime)
              return record.record.fields.dernier_jour_du_mois.microsecondsSinceEpoch as T;
            else
              return record.record.fields.dernier_jour_du_mois as T;
          }
          throw UnimplementedError();
        },
        measureFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (parameters != null && parameters.where((element) => element.label.contains("CVS")).first.value as bool)
              return record.record.fields.dpae_cvs;
            return record.record.fields.dpae_brut;
          }
          throw UnimplementedError();
        },
      )
    ];
  }

  @override
  List<charts.Series<dynamic, T>> barChartData<T>({bool stacked = false, bool daytime = false, List<CustomApiParameter<dynamic>>? parameters}) {
    var cdiRecords = records.where((element) => element.record.fields.nature_de_contrat == "CDI").toList();
    var cddRecords = records.where((element) => element.record.fields.nature_de_contrat == "CDD de plus d'un mois").toList();

    return [
      new charts.Series(
        id: "CDI",
        data: cdiRecords,
        domainFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (!daytime)
              return record.record.fields.dernier_jour_du_mois.toIso8601String() as T;
            else
              return record.record.fields.dernier_jour_du_mois as T;
          }
          throw UnimplementedError();
        },
        measureFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (parameters != null && parameters.where((element) => element.label.contains("CVS")).first.value as bool)
              return record.record.fields.dpae_cvs;
            return record.record.fields.dpae_brut;
          }
          throw UnimplementedError();
        },
      ),
      new charts.Series(
        id: "CDD + 1 Mois",
        data: cddRecords,
        domainFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (!daytime)
              return record.record.fields.dernier_jour_du_mois.toIso8601String() as T;
            else
              return record.record.fields.dernier_jour_du_mois as T;
          }
          throw UnimplementedError();
        },
        measureFn: (dynamic record, _) {
          if (record is FrDpeaRecordListItem) {
            if (parameters != null && parameters.where((element) => element.label.contains("CVS")).first.value as bool)
              return record.record.fields.dpae_cvs;
            return record.record.fields.dpae_brut;
          }
          throw UnimplementedError();
        },
      )
    ];
  }
}

@JsonSerializable()
class FrDpeaRecordListItem {
  final List<OdSQLLink> links;
  final FrDpeaRecord record;

  FrDpeaRecordListItem(this.links, this.record);

  factory FrDpeaRecordListItem.fromJson(Map<String, dynamic> json) => _$FrDpeaRecordListItemFromJson(json);
  Map<String, dynamic> toJson() => _$FrDpeaRecordListItemToJson(this);
}

@JsonSerializable()
class FrDpeaRecord {
  final String id;
  final DateTime timestamp;
  final int size;
  final FrDpeaRecordData fields;

  FrDpeaRecord(this.id, this.timestamp, this.size, this.fields);

  factory FrDpeaRecord.fromJson(Map<String, dynamic> json) => _$FrDpeaRecordFromJson(json);
  Map<String, dynamic> toJson() => _$FrDpeaRecordToJson(this);
}

@JsonSerializable()
class FrDpeaRecordData {
  final String annee;
  final int trimestre;
  final DateTime dernier_jour_du_mois;
  final String duree_de_contrat;
  final String nature_de_contrat;
  final int dpae_brut;
  final int dpae_cvs;

  FrDpeaRecordData(this.annee, this.trimestre, this.dernier_jour_du_mois, this.duree_de_contrat, this.nature_de_contrat, this.dpae_brut, this.dpae_cvs);

  factory FrDpeaRecordData.fromJson(Map<String, dynamic> json) => _$FrDpeaRecordDataFromJson(json);
  Map<String, dynamic> toJson() => _$FrDpeaRecordDataToJson(this);
}