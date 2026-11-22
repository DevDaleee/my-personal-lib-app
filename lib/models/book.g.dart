// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  isbn: json['isbn'] as String?,
  totalPages: (json['total_pages'] as num).toInt(),
  currentPage: (json['current_page'] as num).toInt(),
  status: $enumDecode(_$BookStatusEnumMap, json['status']),
  rating: (json['rating'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  coverUrl: json['cover_url'] as String?,
  owned: json['owned'] as bool,
  startedAt: json['started_at'] == null ? null : DateTime.parse(json['started_at'] as String),
  finishedAt: json['finished_at'] == null ? null : DateTime.parse(json['finished_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

const _$BookStatusEnumMap = {BookStatus.wannaRead: 'wanna_read', BookStatus.reading: 'reading', BookStatus.read: 'read'};
