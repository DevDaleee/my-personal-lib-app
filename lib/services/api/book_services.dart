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
}
