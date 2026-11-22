import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/controllers/profile_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/api/stats_services.dart';
import 'package:my_personal_lib_app/services/api/user_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/books.dart';

class MockUserServices extends Mock implements UserServices {}

class MockStatsServices extends Mock implements StatsServices {}

class MockBookServices extends Mock implements BookServices {}

Map<String, dynamic> _ok(Object data) => {"status_code": 200, "data": data, "error": null};
Map<String, dynamic> _fail(int? status, String error) => {"status_code": status, "data": null, "error": error};

final _me = {'id': 'u-1', 'email': 'clarice@caderno.com.br', 'name': 'Clarice Lispector', 'created_at': '2024-03-10T12:00:00Z'};

void main() {
  late MockUserServices users;
  late MockStatsServices stats;
  late MockBookServices books;
  late ProfileController controller;
  final year = DateTime.now().year;

  setUp(() async {
    await GetIt.instance.reset();
    SharedPreferences.setMockInitialValues({tokenKey: 'jwt.abc', entityId: 'u-1'});
    users = MockUserServices();
    stats = MockStatsServices();
    books = MockBookServices();
    GetIt.instance
      ..registerSingleton<UserServices>(users)
      ..registerSingleton<StatsServices>(stats)
      ..registerSingleton<BookServices>(books);
    GetIt.instance.registerSingleton<LibraryController>(LibraryController());

    when(() => users.getMe()).thenAnswer((_) async => _ok(_me));
    when(() => stats.getStreak()).thenAnswer((_) async => _ok({'current_streak': 4}));
    when(() => stats.getMonthly(months: any(named: 'months'))).thenAnswer(
      (_) async => _ok([
        {'month': '${year - 1}-12-01', 'finished_count': 5},
        {'month': '$year-03-01', 'finished_count': 2},
        {'month': '$year-11-01', 'finished_count': 1},
      ]),
    );
    when(() => books.getBooks()).thenAnswer(
      (_) async => booksOk([
        fakeBook(id: 'b-1', currentPage: 137, totalPages: 624, status: BookStatus.reading),
        fakeBook(id: 'b-2', currentPage: 88, totalPages: 88, status: BookStatus.read),
        fakeBook(id: 'b-3'),
      ]),
    );
    controller = ProfileController();
  });

  test('sucesso: usuário, sequência, lidos no ano e páginas lidas', () async {
    await controller.load();

    expect(controller.user?.name, 'Clarice Lispector');
    expect(controller.user?.email, 'clarice@caderno.com.br');
    expect(controller.streak, 4);
    expect(controller.finishedThisYear, 3); // dezembro do ano passado não conta
    expect(controller.pagesRead, 137 + 88);
    expect(controller.error, isNull);
    expect(controller.isLoading, isFalse);
    verify(() => stats.getMonthly(months: 12)).called(1);
  });

  test('isLoading fica verdadeiro durante a busca', () async {
    final future = controller.load();
    expect(controller.isLoading, isTrue);
    await future;
    expect(controller.isLoading, isFalse);
  });

  test('erro no usuário: guarda a mensagem', () async {
    when(() => users.getMe()).thenAnswer((_) async => _fail(null, ApiErrors.connectionError));

    await controller.load();

    expect(controller.user, isNull);
    expect(controller.error, ApiErrors.connectionError);
  });

  test('estatísticas falham: o perfil aparece e os números ficam nulos', () async {
    when(() => stats.getStreak()).thenAnswer((_) async => _fail(500, 'Erro'));
    when(() => stats.getMonthly(months: any(named: 'months'))).thenAnswer((_) async => _fail(500, 'Erro'));

    await controller.load();

    expect(controller.user, isNotNull);
    expect(controller.error, isNull);
    expect(controller.streak, isNull);
    expect(controller.finishedThisYear, isNull);
  });

  test('sem livros concluídos no ano: zero (não nulo)', () async {
    when(() => stats.getMonthly(months: any(named: 'months'))).thenAnswer((_) async => _ok([]));

    await controller.load();

    expect(controller.finishedThisYear, 0);
  });

  test('404 no /users/me: apaga a sessão e avisa a tela', () async {
    when(() => users.getMe()).thenAnswer((_) async => _fail(404, 'Usuário não encontrado'));

    await controller.load();

    expect(controller.sessionEnded, isTrue);
    expect(controller.error, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(tokenKey), isNull);
    expect(prefs.getString(entityId), isNull);
  });
}
