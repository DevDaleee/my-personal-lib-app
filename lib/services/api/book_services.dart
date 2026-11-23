import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/services/api/api_request.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/constants.dart';

/// Chamadas de livros. O token vai no `Authorization` pelo interceptor do
/// `ApiServices`; o back-end tira o usuário do próprio token (sem `user_id`).
/// Respostas no formato do `apiRequest`: `{"status_code", "data", "error"}`.
class BookServices {
  final ApiServices api = GetIt.I.get<ApiServices>();

  /// `GET /books`: todos os livros do usuário (lista vazia = `[]`).
  Future<Map<String, dynamic>> getBooks() {
    return apiRequest('BookServices/books', () => api.dio.get("${ApiConstants.basePath}/books"));
  }

  /// `POST /books`: cadastra um livro e devolve o livro criado (201).
  /// Manda só os campos do contrato (o back-end recusa campos desconhecidos);
  /// texto opcional vazio vai como `null`.
  Future<Map<String, dynamic>> createBook({
    required String title,
    required String author,
    required int totalPages,
    required bool owned,
    String? isbn,
    int? rating,
    String? notes,
    String? coverUrl,
  }) {
    final body = {
      "title": title.trim(),
      "author": author.trim(),
      "total_pages": totalPages,
      "owned": owned,
      "isbn": _orNull(isbn),
      "rating": rating,
      "notes": _orNull(notes),
      "cover_url": _orNull(coverUrl),
    };
    return apiRequest('BookServices/createBook', () => api.dio.post("${ApiConstants.basePath}/books", data: body), successStatus: 201);
  }

  // Texto vazio ou só com espaços vira null.
  String? _orNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
