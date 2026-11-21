import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:my_personal_lib_app/pages/components/custom_dialog.dart';

class ApiServices {
  final Dio dio;
  static const defaltConnectTimeout = 30000;
  static const defaultReceiveTimeout = 30000;

  bool showExpirationDialog = false;
  bool _showingConnError = false;

  final SecurityStorage securityStorage = GetIt.I.get<SecurityStorage>();

  ApiServices(this.dio) {
    dio.options.baseUrl = dotenv.get("API_BASE_URL");
    dio.options.connectTimeout = Duration(milliseconds: defaltConnectTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: defaultReceiveTimeout);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          final token = await SecurityStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json; charset=UTF-8';
          handler.next(options);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          final isConnError = err.type == DioExceptionType.connectionError || err.type == DioExceptionType.unknown && err.error is SocketException;

          if (isConnError) {
            if (!_showingConnError) {
              _showingConnError = true;
              CustomDialog(
                bodyMessage: "O nosso app ainda não funciona offline, mas estamos trabalhando para ofertar uma vesão offline",
                textCancel: '',
                textConfirm: '',
                title: "Você está offline!",
                informativeDialog: true,
              );
              Future.delayed(const Duration(seconds: 3), () => _showingConnError = false);
            }
            return handler.next(err);
          }

          if (err.response?.statusCode == ErrosStatusCode.unauthorized) {
            if (!showExpirationDialog && entityId.isNotEmpty) {
              showExpirationDialog = true;
              CustomDialog(
                bodyMessage: "Acesso expirado, faça login novamente para conseguir acesso novamente",
                textCancel: '',
                textConfirm: '',
                title: "Erro ao abrir o app",
                informativeDialog: true,
              );
            }
            return handler.next(err);
          }

          handler.next(err);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
      ),
    );
  }
}
