import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/controllers/profile_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/profile/profile_page.dart';
import 'package:my_personal_lib_app/pages/styles/light_theme.dart';
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

final _me = {'id': 'u-1', 'email': 'clarice@caderno.com.br', 'name': 'Clarice Lispector', 'created_at': '2024-03-10T12:00:00'};

Widget _app() {
  final router = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('LOGIN')),
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      GoRoute(
        path: '/stats',
        builder: (_, _) => const Scaffold(body: Text('ESTATÍSTICAS')),
      ),
    ],
  );
  return MaterialApp.router(theme: lightTheme, routerConfig: router);
}

void main() {
  late MockUserServices users;
  late MockStatsServices stats;
  late MockBookServices books;
  late LibraryController library;
  final year = DateTime.now().year;

  /// Abre o Perfil e espera as chamadas terminarem.
  Future<void> openProfile(WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
  }

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
    library = LibraryController();
    GetIt.instance.registerSingleton<LibraryController>(library);
    GetIt.instance.registerSingleton<ProfileController>(ProfileController());

    when(() => users.getMe()).thenAnswer((_) async => _ok(_me));
    when(() => stats.getStreak()).thenAnswer((_) async => _ok({'current_streak': 4}));
    when(() => stats.getMonthly(months: any(named: 'months'))).thenAnswer(
      (_) async => _ok([
        {'month': '$year-03-01', 'finished_count': 18},
      ]),
    );
    when(() => books.getBooks()).thenAnswer(
      (_) async => booksOk([
        fakeBook(id: 'b-1', currentPage: 4000, totalPages: 5000, status: BookStatus.reading),
        fakeBook(id: 'b-2', currentPage: 820, totalPages: 820, status: BookStatus.read),
      ]),
    );
  });

  testWidgets('mostra avatar, nome, e-mail, membro desde e os três números', (tester) async {
    await openProfile(tester);

    expect(find.text('Perfil do leitor'), findsOneWidget);
    expect(find.text('CL'), findsOneWidget);
    expect(find.text('Clarice Lispector'), findsOneWidget);
    expect(find.text('clarice@caderno.com.br'), findsOneWidget);
    expect(find.text('Membro desde mar/2024'), findsOneWidget);

    expect(find.text('18'), findsOneWidget);
    expect(find.text('LIDOS EM $year'), findsOneWidget);
    expect(find.text('4.820'), findsOneWidget); // milhar com ponto
    expect(find.text('PÁGINAS LIDAS'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('DIAS SEGUIDOS'), findsOneWidget);

    expect(find.text('Estatísticas detalhadas de leitura'), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets('enquanto busca: mostra o carregando', (tester) async {
    final response = Completer<Map<String, dynamic>>();
    when(() => users.getMe()).thenAnswer((_) => response.future);
    await tester.pumpWidget(_app());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete(_ok(_me));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Clarice Lispector'), findsOneWidget);
  });

  testWidgets('estatísticas falham: mostra "–" nos números', (tester) async {
    when(() => stats.getStreak()).thenAnswer((_) async => _fail(500, 'Erro'));
    when(() => stats.getMonthly(months: any(named: 'months'))).thenAnswer((_) async => _fail(500, 'Erro'));
    await openProfile(tester);

    expect(find.text('Clarice Lispector'), findsOneWidget);
    expect(find.text('–'), findsNWidgets(2));
  });

  testWidgets('erro no usuário: mensagem, "Tentar novamente" e o Sair continua lá', (tester) async {
    when(() => users.getMe()).thenAnswer((_) async => _fail(null, ApiErrors.connectionError));
    await openProfile(tester);

    expect(find.text('Não foi possível carregar seu perfil'), findsOneWidget);
    expect(find.text(ApiErrors.connectionError), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);

    when(() => users.getMe()).thenAnswer((_) async => _ok(_me));
    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();

    expect(find.text('Clarice Lispector'), findsOneWidget);
  });

  testWidgets('Sair da conta apaga a sessão, esquece os livros e volta para o login', (tester) async {
    await openProfile(tester);
    expect(library.books, isNotEmpty);

    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(tokenKey), isNull);
    expect(prefs.getString(entityId), isNull);
    expect(library.books, isEmpty);
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('404 no /users/me: volta para o login', (tester) async {
    when(() => users.getMe()).thenAnswer((_) async => _fail(404, 'Usuário não encontrado'));
    await openProfile(tester);
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('"Estatísticas detalhadas de leitura" abre as Estatísticas', (tester) async {
    await openProfile(tester);

    await tester.tap(find.text('Estatísticas detalhadas de leitura'));
    await tester.pumpAndSettle();

    expect(find.text('ESTATÍSTICAS'), findsOneWidget);
  });
}
