import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/services/api/api_request.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/constants.dart';

/// Chamadas de autenticação e do usuário logado.
/// Respostas no formato do `apiRequest`: `{"status_code", "data", "error"}`.
class UserServices {
  final ApiServices api = GetIt.I.get<ApiServices>();

  Future<Map<String, dynamic>> login(String email, String password) {
    return _post('/auth/login', {"email": email, "password": password}, successStatus: 200);
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) {
    return _post('/auth/register', {"name": name, "email": email, "password": password}, successStatus: 201);
  }

  /// `GET /users/me`: o dono do token (`id`, `email`, `name`, `created_at`).
  Future<Map<String, dynamic>> getMe() {
    return apiRequest('UserServices/users/me', () => api.dio.get("${ApiConstants.basePath}/users/me"));
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, {required int successStatus}) {
    return apiRequest('UserServices$path', () => api.dio.post("${ApiConstants.basePath}$path", data: body), successStatus: successStatus);
  }
}
