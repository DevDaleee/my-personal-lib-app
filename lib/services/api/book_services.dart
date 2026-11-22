import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/constants.dart';

/// Chamadas de livros. O token vai no `Authorization` pelo interceptor do
/// `ApiServices`; o back-end tira o usuário do próprio token (sem `user_id`).
///
/// Mesmo formato de resposta do `UserServices`:
/// `{"status_code": int?, "data": corpo da API ou null, "error": mensagem ou null}`.
class BookServices {
  final ApiServices api = GetIt.I.get<ApiServices>();

  /// `GET /books`: todos os livros do usuário (lista vazia = `[]`).
  Future<Map<String, dynamic>> getBooks() async {
    try {
      final response = await api.dio.get("${ApiConstants.basePath}/books");
      if (response.statusCode == 200) return _result(response.statusCode, data: response.data);
      return _result(response.statusCode, error: ApiErrors.unexpectedError);
    } on DioException catch (e) {
      final response = e.response;
      // Sem resposta: o servidor não foi alcançado.
      if (response == null) return _result(null, error: ApiErrors.connectionError);
      // A API manda {"error": "mensagem em português"}, pronta para o usuário.
      final data = response.data;
      final message = data is Map && data["error"] is String ? data["error"] as String : ApiErrors.unexpectedError;
      return _result(response.statusCode, error: message);
    } catch (e) {
      // Detalhe técnico só no log, nunca na tela.
      debugPrint('BookServices/books: $e');
      return _result(null, error: ApiErrors.unexpectedError);
    }
  }

  Map<String, dynamic> _result(int? statusCode, {dynamic data, String? error}) {
    return {"status_code": statusCode, "data": data, "error": error};
  }
}
