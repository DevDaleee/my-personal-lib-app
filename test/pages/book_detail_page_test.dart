import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/book_detail_controller.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/pages/book_detail/book_detail_page.dart';
import 'package:my_personal_lib_app/pages/styles/light_theme.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:toastification/toastification.dart';

import '../helpers/auth_fakes.dart' show flushToasts;
import '../helpers/books.dart';

class MockBookServices extends Mock implements BookServices {}

class MockLibraryController extends Mock implements LibraryController {}

Map<String, dynamic> _ok(Book book) => {"status_code": 200, "data": bookJson(book), "error": null};

/// Uma Home falsa que abre o Detalhe com `push`, como a de verdade.
Widget _app() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, _) => Scaffold(
          body: TextButton(onPressed: () => context.push('/books/b-1'), child: const Text('HOME')),
        ),
      ),
      GoRoute(path: '/books/:id', builder: (_, state) => BookDetailPage(bookId: state.pathParameters['id']!)),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const Scaffold(body: Text('PERFIL')),
      ),
    ],
  );
  return ToastificationWrapper(
    child: MaterialApp.router(theme: lightTheme, routerConfig: router),
  );
}

/// Livro lido até a página 41, com nota, notas e ISBN.
Book _reading({int currentPage = 41, BookStatus status = BookStatus.reading}) => fakeBook(
  currentPage: currentPage,
  status: status,
  rating: 4,
  notes: 'Releitura com o clube.',
  isbn: '978-65-80309-21-8',
  createdAt: DateTime(2026, 11, 3),
);

void main() {
  late MockBookServices services;

  /// Abre a Home falsa, toca para abrir o Detalhe e espera a busca terminar.
  Future<void> openPage(WidgetTester tester) async {
    // Tela alta: o ListView constrói o Detalhe inteiro de uma vez.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('HOME'));
    await tester.pumpAndSettle();
  }

  Finder pageField() => find.byType(TextFormField);

  Future<void> submitPage(WidgetTester tester, String page) async {
    await tester.enterText(pageField(), page);
    await tester.tap(find.text('Atualizar'));
    await tester.pump();
  }

  setUp(() async {
    await GetIt.instance.reset();
    services = MockBookServices();
    final library = MockLibraryController();
    when(() => library.fetchBooks()).thenAnswer((_) async {});
    when(() => services.getBook('b-1')).thenAnswer((_) async => _ok(_reading()));
    GetIt.instance.registerSingleton<BookServices>(services);
    GetIt.instance.registerSingleton<LibraryController>(library);
    GetIt.instance.registerFactory<BookDetailController>(() => BookDetailController());
  });

  testWidgets('mostra o cabeçalho, o progresso e a ficha do livro', (tester) async {
    await openPage(tester);

    expect(find.text('Detalhes Do Livro'), findsOneWidget);
    expect(find.text('Torto Arado'), findsOneWidget);
    expect(find.text('Itamar Vieira Junior'), findsOneWidget);
    expect(find.text('LENDO'), findsOneWidget);
    // 41 de 264 = 15,5% → 16%.
    expect(find.text('16%'), findsOneWidget);
    expect(find.text('Página 41 de 264 páginas'), findsOneWidget);
    expect(find.text('223 restantes'), findsOneWidget);
    expect(find.text('Lendo atualmente'), findsOneWidget);
    expect(find.text('(4 de 5)'), findsOneWidget);
    expect(find.text('Sim'), findsOneWidget);
    expect(find.text('03/11/2026'), findsOneWidget);
    expect(find.text('978-65-80309-21-8'), findsOneWidget);
    expect(find.text('Releitura com o clube.'), findsOneWidget);
  });

  testWidgets('sem nota, sem notas e sem ISBN: "Não avaliado" e sem o card de notas', (tester) async {
    when(() => services.getBook('b-1')).thenAnswer((_) async => _ok(fakeBook(owned: false)));
    await openPage(tester);

    expect(find.text('Não avaliado'), findsOneWidget);
    expect(find.text('Não'), findsOneWidget);
    expect(find.text('QUERO LER'), findsOneWidget);
    expect(find.text('MINHAS NOTAS'), findsNothing);
    expect(find.text('ISBN'), findsNothing);
  });

  testWidgets('enquanto busca: mostra o carregando', (tester) async {
    final response = Completer<Map<String, dynamic>>();
    when(() => services.getBook('b-1')).thenAnswer((_) => response.future);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('HOME'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete(_ok(_reading()));
    await tester.pumpAndSettle();
    expect(find.text('Página 41 de 264 páginas'), findsOneWidget);
  });

  testWidgets('404: mostra "Livro não encontrado" e volta para a tela anterior', (tester) async {
    when(() => services.getBook('b-1')).thenAnswer((_) async => booksFailure(404, 'Livro não encontrado'));
    await openPage(tester);

    expect(find.text('Livro não encontrado'), findsOneWidget);

    await tester.tap(find.text('Voltar para a biblioteca'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('erro: mostra a mensagem e "Tentar novamente" busca de novo', (tester) async {
    when(() => services.getBook('b-1')).thenAnswer((_) async => booksFailure(null, ApiErrors.connectionError));
    await openPage(tester);

    expect(find.text(ApiErrors.connectionError), findsOneWidget);

    when(() => services.getBook('b-1')).thenAnswer((_) async => _ok(_reading()));
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Página 41 de 264 páginas'), findsOneWidget);
  });

  testWidgets('página vazia ou maior que o total: mostra o erro e não chama a API', (tester) async {
    await openPage(tester);

    await submitPage(tester, '');
    expect(find.text('Informe a página atual'), findsOneWidget);

    await submitPage(tester, '300');
    expect(find.text('O livro tem 264 páginas'), findsOneWidget);

    verifyNever(() => services.updateProgress(any(), any()));

    // Corrigir a página tira a mensagem na hora, sem precisar tocar em "Atualizar".
    await tester.enterText(pageField(), '120');
    await tester.pump();
    expect(find.text('O livro tem 264 páginas'), findsNothing);
  });

  testWidgets('atualizar: envia a página, mostra o progresso novo e o toast', (tester) async {
    when(() => services.updateProgress('b-1', 132)).thenAnswer((_) async => _ok(_reading(currentPage: 132)));
    await openPage(tester);

    await submitPage(tester, '132');
    await tester.pumpAndSettle();

    verify(() => services.updateProgress('b-1', 132)).called(1);
    expect(find.text('Página 132 de 264 páginas'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Leitura atualizada'), findsOneWidget);
    expect(find.text('Página 132 de 264.'), findsOneWidget);
    // O campo volta vazio, sem a mensagem de campo obrigatório.
    expect(tester.widget<TextFormField>(pageField()).controller!.text, isEmpty);
    expect(find.text('Informe a página atual'), findsNothing);

    await flushToasts(tester);
  });

  testWidgets('chegar à última página: status "LIDO" e o toast "Livro concluído!"', (tester) async {
    when(() => services.updateProgress('b-1', 264)).thenAnswer((_) async => _ok(_reading(currentPage: 264, status: BookStatus.read)));
    await openPage(tester);

    await submitPage(tester, '264');
    await tester.pumpAndSettle();

    expect(find.text('LIDO'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Livro concluído!'), findsOneWidget);

    await flushToasts(tester);
  });

  testWidgets('erro da API ao atualizar: mostra a mensagem num toast e mantém o progresso', (tester) async {
    when(() => services.updateProgress('b-1', 100)).thenAnswer((_) async => booksFailure(400, 'Página fora do intervalo'));
    await openPage(tester);

    await submitPage(tester, '100');
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível atualizar'), findsOneWidget);
    expect(find.text('Página fora do intervalo'), findsOneWidget);
    expect(find.text('Página 41 de 264 páginas'), findsOneWidget);

    await flushToasts(tester);
  });
}
