// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyStat _$MonthlyStatFromJson(Map<String, dynamic> json) => MonthlyStat(
  month: DateTime.parse(json['month'] as String),
  finishedCount: (json['finished_count'] as num).toInt(),
);
