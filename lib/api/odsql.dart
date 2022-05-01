import 'package:json_annotation/json_annotation.dart';

part 'odsql.g.dart';

@JsonSerializable()
class OdSQLResult {
  final int total_count;
  final List<OdSQLLink> links;

  OdSQLResult(this.total_count, this.links);

  factory OdSQLResult.fromJson(Map<String, dynamic> json) => _$OdSQLResultFromJson(json);
  Map<String, dynamic> toJson() => _$OdSQLResultToJson(this);
}

@JsonSerializable()
class OdSQLLink {
  final String rel;
  final String href;

  OdSQLLink(this.rel, this.href);

  factory OdSQLLink.fromJson(Map<String, dynamic> json) => _$OdSQLLinkFromJson(json);
  Map<String, dynamic> toJson() => _$OdSQLLinkToJson(this);
}
