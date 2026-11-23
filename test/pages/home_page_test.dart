import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/components/book_cover.dart';
import 'package:my_personal_lib_app/pages/home/home_page.dart';
import 'package:my_personal_lib_app/pages/styles/light_theme.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/books.dart';

class MockBookServices extends Mock implements BookServices {}

/// Opção do filtro (o selo do livro também pode ter o mesmo texto).
Finder _filter(String label) => find.descendant(of: find.byType(SegmentedButton<BookFilter>), matching: find.text(label));

Widget _app() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('LOGIN')),
      ),
      GoRoute(path: '/home', builder: (_, _) => const HomePage()),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const Scaffold(body: Text('PERFIL')),
      ),
      GoRoute(
        path: '/books/new',
        builder: (_, _) => const Scaffold(body: Text('NOVO LIVRO')),
      ),
      GoRoute(
        path: '/books/:id',
        builder: (_, state) => Scaffold(body: Text('DETALHE ${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/stats',
        builder: (_, _) => const Scaffold(body: Text('ESTATÍSTICAS')),
      ),
    ],
  );
  return MaterialApp.router(theme: lightTheme, routerConfig: router);
}

void main() {
  late LibraryController controller;
  late MockBookServices services;

  /// O que o `GET /books` responde neste teste.
  void apiReturns(List<Book> books) => when(() => services.getBooks()).thenAnswer((_) async => booksOk(books));

  /// Abre a Home e espera a busca dos livros terminar.
  Future<void> openHome(WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
  }

  setUp(() async {
    await GetIt.instance.reset();
    services = MockBookServices();
    GetIt.instance.registerSingleton<BookServices>(services);
    apiReturns([]);
    controller = LibraryController();
    GetIt.instance.registerSingleton<LibraryController>(controller);
    SharedPreferences.setMockInitialValues({tokenKey: 'jwt.abc', entityId: 'u-1'});
  });

  testWidgets('mostra o cabeçalho, os filtros e a barra inferior', (tester) async {
    await openHome(tester);

    expect(find.text('Biblioteca'), findsWidgets); // AppBar e barra inferior
    expect(find.text('CADERNO DE LEITURAS'), findsOneWidget);
    expect(find.text('Minha biblioteca'), findsOneWidget);
    expect(find.text('Novo livro'), findsOneWidget);
    expect(find.text('Estatísticas'), findsOneWidget);
    for (final label in ['Lendo', 'Quero ler', 'Lidos']) {
      expect(_filter(label), findsOneWidget);
    }
  });

  testWidgets('sem livros: mostra a estante vazia', (tester) async {
    await openHome(tester);

    expect(find.text('Sua estante está vazia'), findsOneWidget);
    expect(find.text('Todos 0'), findsOneWidget);
  });

  testWidgets('lista os livros com o progresso de quem está lendo', (tester) async {
    apiReturns(sampleShelf());
    await openHome(tester);

    expect(find.text('Todos 3'), findsOneWidget);
    expect(find.text('Grande Sertão: Veredas'), findsOneWidget);
    expect(find.text('137 de 624 páginas'), findsOneWidget);
    expect(find.text('22%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // Quero ler e Lido mostram só o total de páginas.
    expect(find.text('264 páginas'), findsOneWidget);
    expect(find.text('88 páginas'), findsOneWidget);
    // Divisória entre os livros, não depois do último.
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('o filtro mostra só os livros do status e conta no selecionado', (tester) async {
    apiReturns(sampleShelf());
    await openHome(tester);

    await tester.tap(_filter('Lendo'));
    await tester.pump();

    expect(_filter('Lendo 1'), findsOneWidget);
    expect(find.text('Grande Sertão: Veredas'), findsOneWidget);
    expect(find.text('Torto Arado'), findsNothing);
    expect(find.text('A Hora da Estrela'), findsNothing);
    expect(_filter('Todos'), findsOneWidget); // sem número quando não está selecionado
  });

  testWidgets('filtro sem livros: mensagem do status', (tester) async {
    apiReturns([fakeBook(status: BookStatus.wannaRead)]);
    await openHome(tester);

    await tester.tap(_filter('Lidos'));
    await tester.pump();

    expect(find.text('Nenhum livro concluído'), findsOneWidget);
  });

  testWidgets('capa sem imagem: iniciais do título e sobrenome do autor', (tester) async {
    apiReturns([fakeBook(title: 'Torto Arado', author: 'Itamar Vieira Junior')]);
    await openHome(tester);

    expect(find.byType(BookCover), findsOneWidget);
    expect(find.text('TA'), findsOneWidget);
    expect(find.text('Junior'), findsOneWidget);
  });

  testWidgets('o botão Perfil da AppBar abre o perfil', (tester) async {
    await openHome(tester);

    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL'), findsOneWidget);
  });

  testWidgets('tocar num livro abre o Detalhe dele', (tester) async {
    apiReturns(sampleShelf());
    await openHome(tester);

    await tester.tap(find.text('A Hora da Estrela'));
    await tester.pumpAndSettle();

    expect(find.text('DETALHE b-3'), findsOneWidget);
  });

  testWidgets('o botão "Novo livro" abre o formulário', (tester) async {
    await openHome(tester);

    await tester.tap(find.text('Novo livro'));
    await tester.pumpAndSettle();

    expect(find.text('NOVO LIVRO'), findsOneWidget);
  });

  testWidgets('enquanto busca: mostra o carregando no lugar da estante vazia', (tester) async {
    final response = Completer<Map<String, dynamic>>();
    when(() => services.getBooks()).thenAnswer((_) => response.future);
    await tester.pumpWidget(_app());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sua estante está vazia'), findsNothing);

    response.complete(booksOk(sampleShelf()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Torto Arado'), findsOneWidget);
  });

  testWidgets('erro: mostra a mensagem e "Tentar novamente" busca de novo', (tester) async {
    when(() => services.getBooks()).thenAnswer((_) async => booksFailure(null, ApiErrors.connectionError));
    await openHome(tester);

    expect(find.text('Não foi possível carregar seus livros'), findsOneWidget);
    expect(find.text(ApiErrors.connectionError), findsOneWidget);
    expect(find.text('Sua estante está vazia'), findsNothing);

    apiReturns(sampleShelf());
    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();

    expect(find.text('Não foi possível carregar seus livros'), findsNothing);
    expect(find.text('Torto Arado'), findsOneWidget);
    verify(() => services.getBooks()).called(2);
  });

  testWidgets('puxar para atualizar busca os livros de novo', (tester) async {
    await openHome(tester);
    expect(find.text('Sua estante está vazia'), findsOneWidget);

    apiReturns([fakeBook(title: 'Torto Arado')]);
    await tester.fling(find.text('Minha biblioteca'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Torto Arado'), findsOneWidget);
    verify(() => services.getBooks()).called(2);
  });

  testWidgets('a barra inferior abre as Estatísticas', (tester) async {
    await openHome(tester);

    await tester.tap(find.text('Estatísticas'));
    await tester.pumpAndSettle();

    expect(find.text('ESTATÍSTICAS'), findsOneWidget);
  });
}
