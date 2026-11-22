import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/models/monthly_stat.dart';
import 'package:my_personal_lib_app/models/user.dart';
import 'package:my_personal_lib_app/services/api/stats_services.dart';
import 'package:my_personal_lib_app/services/api/user_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

part 'profile_controller.g.dart';

class ProfileController = ProfileControllerBase with _$ProfileController;

abstract class ProfileControllerBase with Store {
  final UserServices userServices = GetIt.I.get<UserServices>();
  final StatsServices statsServices = GetIt.I.get<StatsServices>();
  final LibraryController library = GetIt.I.get<LibraryController>();

  @observable
  bool isLoading = false;

  /// Erro ao buscar o usuário: sem ele a tela não tem o que mostrar.
  @observable
  String? error;

  @observable
  User? user;

  /// Livros concluídos no ano atual. Nulo se as estatísticas falharem
  /// (a tela mostra "–" e o resto do perfil continua aparecendo).
  @observable
  int? finishedThisYear;

  /// Dias seguidos com leitura. Nulo se a chamada falhar.
  @observable
  int? streak;

  /// `GET /users/me` respondeu 404: o usuário do token não existe mais.
  /// A sessão já foi apagada; a tela volta para "Entrar".
  @observable
  bool sessionEnded = false;

  /// Total de páginas lidas: soma da página atual de todos os livros
  /// (a API não tem o total por ano).
  @computed
  int get pagesRead => library.books.fold(0, (sum, book) => sum + book.currentPage);

  /// Busca tudo em paralelo. Só o usuário é obrigatório; se as estatísticas
  /// falharem, os números ficam nulos e o resto aparece.
  @action
  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    try {
      final results = await Future.wait([
        userServices.getMe(),
        statsServices.getStreak(),
        statsServices.getMonthly(months: 12),
        // Atualiza os livros para as páginas lidas (a Home usa a mesma lista).
        library.fetchBooks().then((_) => <String, dynamic>{}),
      ]);
      await _applyUser(results[0]);
      streak = _parseStreak(results[1]);
      finishedThisYear = _parseFinishedThisYear(results[2]);
    } finally {
      isLoading = false;
    }
  }

  Future<void> _applyUser(Map<String, dynamic> response) async {
    final status = response["status_code"];
    if (status == 200) {
      try {
        user = User.fromJson(response["data"] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('ProfileController.user: $e');
        error = ApiErrors.unexpectedError;
      }
      return;
    }
    if (status == 404) {
      // 401 já é tratado no interceptor; 404 = conta apagada: encerra a sessão.
      await SecurityStorage.clearData();
      sessionEnded = true;
      return;
    }
    error = response["error"] as String? ?? ApiErrors.unexpectedError;
  }

  int? _parseStreak(Map<String, dynamic> response) {
    if (response["status_code"] != 200) return null;
    final data = response["data"];
    return data is Map && data["current_streak"] is int ? data["current_streak"] as int : null;
  }

  /// Soma os meses do ano atual (o `months=12` pode trazer meses do ano passado).
  int? _parseFinishedThisYear(Map<String, dynamic> response) {
    if (response["status_code"] != 200) return null;
    try {
      final year = DateTime.now().year;
      final stats = (response["data"] as List<dynamic>).map((json) => MonthlyStat.fromJson(json as Map<String, dynamic>));
      return stats.where((stat) => stat.month.year == year).fold<int>(0, (sum, stat) => sum + stat.finishedCount);
    } catch (e) {
      debugPrint('ProfileController.monthly: $e');
      return null;
    }
  }
}
