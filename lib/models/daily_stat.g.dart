// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyStat _$DailyStatFromJson(Map<String, dynamic> json) => DailyStat(
  day: DateTime.parse(json['day'] as String),
  pagesRead: (json['pages_read'] as num).toInt(),
  updates: (json['updates'] as num?)?.toInt() ?? 0,
);
