import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/constants.dart';

/// Chamadas de autenticação.
///
/// Toda resposta tem o mesmo formato, em qualquer caminho:
/// `{"status_code": int?, "data": corpo da API ou null, "error": mensagem ou null}`.
/// `status_code` é nulo quando não houve resposta (sem conexão, timeout).
class UserServices {
  final ApiServices api = GetIt.I.get<ApiServices>();

  static const _connectionError = 'Não foi possível conectar ao servidor. Verifique sua internet.';
  static const _unexpectedError = 'Algo deu errado. Tente novamente.';

  Future<Map<String, dynamic>> login(String email, String password) {
    return _post('/auth/login', {"email": email, "password": password}, successStatus: 200);
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) {
    return _post('/auth/register', {"name": name, "email": email, "password": password}, successStatus: 201);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, {required int successStatus}) async {
    try {
      final response = await api.dio.post("${ApiConstants.basePath}$path", data: body);
      if (response.statusCode == successStatus) return _result(response.statusCode, data: response.data);
      return _result(response.statusCode, error: _unexpectedError);
    } on DioException catch (e) {
      final response = e.response;
      // Sem resposta: o servidor não foi alcançado.
      if (response == null) return _result(null, error: _connectionError);
      // A API manda {"error": "mensagem em português"}, pronta para o usuário.
      final data = response.data;
      final message = data is Map && data["error"] is String ? data["error"] as String : _unexpectedError;
      return _result(response.statusCode, error: message);
    } catch (e) {
      // Detalhe técnico só no log, nunca na tela.
      debugPrint('UserServices$path: $e');
      return _result(null, error: _unexpectedError);
    }
  }

  Map<String, dynamic> _result(int? statusCode, {dynamic data, String? error}) {
    return {"status_code": statusCode, "data": data, "error": error};
  }
}
