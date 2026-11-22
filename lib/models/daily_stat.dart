import 'package:json_annotation/json_annotation.dart';

part 'daily_stat.g.dart';

/// Páginas lidas num dia (`GET /stats/daily`). `day` é a data, sem hora.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class DailyStat {
  final DateTime day;
  final int pagesRead;

  /// Quantas atualizações de página houve no dia.
  final int updates;

  const DailyStat({required this.day, required this.pagesRead, this.updates = 0});

  factory DailyStat.fromJson(Map<String, dynamic> json) => _$DailyStatFromJson(json);
}
