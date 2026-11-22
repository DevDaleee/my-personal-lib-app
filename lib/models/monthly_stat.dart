import 'package:json_annotation/json_annotation.dart';

part 'monthly_stat.g.dart';

/// Livros concluídos num mês (`GET /stats/monthly`). `month` é o dia 1 do mês.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class MonthlyStat {
  final DateTime month;
  final int finishedCount;

  const MonthlyStat({required this.month, required this.finishedCount});

  factory MonthlyStat.fromJson(Map<String, dynamic> json) => _$MonthlyStatFromJson(json);
}
