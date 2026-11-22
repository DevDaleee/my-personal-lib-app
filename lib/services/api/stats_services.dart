import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/services/api/api_request.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/constants.dart';

/// Chamadas de estatísticas (stats-service). Os números são atualizados de forma
/// assíncrona (NATS): logo depois de um PATCH, podem vir com o valor antigo.
/// Respostas no formato do `apiRequest`: `{"status_code", "data", "error"}`.
class StatsServices {
  final ApiServices api = GetIt.I.get<ApiServices>();

  /// `GET /stats/streak` → `{"current_streak": 4}`.
  Future<Map<String, dynamic>> getStreak() {
    return apiRequest('StatsServices/streak', () => api.dio.get("${ApiConstants.basePath}/stats/streak"));
  }

  /// `GET /stats/monthly?months=2|3|6|12` → `[{"month": "2026-11-01", "finished_count": 2}]`.
  /// Meses sem livro concluído não aparecem.
  Future<Map<String, dynamic>> getMonthly({int months = 12}) {
    return apiRequest('StatsServices/monthly', () => api.dio.get("${ApiConstants.basePath}/stats/monthly", queryParameters: {"months": months}));
  }

  /// `GET /stats/daily?days=7|15|30` → `[{"day": "2026-11-21", "pages_read": 41, "updates": 1}]`.
  /// Dias sem leitura não aparecem.
  Future<Map<String, dynamic>> getDaily({int days = 7}) {
    return apiRequest('StatsServices/daily', () => api.dio.get("${ApiConstants.basePath}/stats/daily", queryParameters: {"days": days}));
  }
}
