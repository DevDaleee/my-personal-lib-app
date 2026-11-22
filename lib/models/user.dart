import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Usuário logado, como vem do `GET /users/me`. Nunca traz senha nem hash.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  const User({required this.id, required this.email, required this.name, required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Iniciais do avatar: primeira e última palavra do nome ("Clarice Lispector" → "CL").
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words.first[0] + words.last[0]).toUpperCase();
  }
}
