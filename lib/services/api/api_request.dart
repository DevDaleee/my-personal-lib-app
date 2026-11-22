import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_personal_lib_app/services/constants.dart';

/// Executa uma chamada do Dio e devolve sempre o mesmo formato, em qualquer caminho:
/// `{"status_code": int?, "data": corpo da API ou null, "error": mensagem ou null}`.
/// `status_code` é nulo quando não houve resposta (sem conexão, timeout).
///
/// `label` só aparece no log, para saber de onde veio o erro.
Future<Map<String, dynamic>> apiRequest(String label, Future<Response<dynamic>> Function() call, {int successStatus = 200}) async {
  try {
    final response = await call();
    if (response.statusCode == successStatus) return apiResult(response.statusCode, data: response.data);
    return apiResult(response.statusCode, error: ApiErrors.unexpectedError);
  } on DioException catch (e) {
    final response = e.response;
    // Sem resposta: o servidor não foi alcançado.
    if (response == null) return apiResult(null, error: ApiErrors.connectionError);
    // A API manda {"error": "mensagem em português"}, pronta para o usuário.
    final data = response.data;
    final message = data is Map && data["error"] is String ? data["error"] as String : ApiErrors.unexpectedError;
    return apiResult(response.statusCode, error: message);
  } catch (e) {
    // Detalhe técnico só no log, nunca na tela.
    debugPrint('$label: $e');
    return apiResult(null, error: ApiErrors.unexpectedError);
  }
}

Map<String, dynamic> apiResult(int? statusCode, {dynamic data, String? error}) {
  return {"status_code": statusCode, "data": data, "error": error};
}
