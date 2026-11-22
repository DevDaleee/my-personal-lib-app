import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/pages/router.dart';
import 'package:my_personal_lib_app/services/constants.dart';

class ApiServices {
  final Dio dio;
  static const defaltConnectTimeout = 30000;
  static const defaultReceiveTimeout = 30000;

  final SecurityStorage securityStorage = GetIt.I.get<SecurityStorage>();

  /// Rotas públicas: não levam token e um 401 nelas é "e-mail ou senha incorretos",
  /// não sessão vencida. O CORS do gateway em /auth também não libera o cabeçalho Authorization.
  static bool _isAuthRoute(String path) => path.startsWith('/auth') || path.startsWith('${ApiConstants.basePath}/auth');

  ApiServices(this.dio) {
    dio.options.baseUrl = dotenv.get("API_BASE_URL");
    dio.options.connectTimeout = Duration(milliseconds: defaltConnectTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: defaultReceiveTimeout);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          if (!_isAuthRoute(options.path)) {
            final token = await SecurityStorage.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          options.headers['Content-Type'] = 'application/json; charset=UTF-8';
          handler.next(options);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          // Sem conexão: quem chamou recebe o erro e mostra a mensagem na tela.
          // 401 fora de /auth = token vencido ou inválido: apaga a sessão e volta para "Entrar".
          if (err.response?.statusCode == ErrosStatusCode.unauthorized && !_isAuthRoute(err.requestOptions.path)) {
            await SecurityStorage.clearData();
            router.go('/');
          }
          handler.next(err);
        },
      ),
    );
  }
}
