import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/controllers/new_book_controller.dart';
import 'package:my_personal_lib_app/pages/new_book/new_book_page.dart';
import 'package:my_personal_lib_app/pages/styles/light_theme.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:toastification/toastification.dart';

import '../helpers/auth_fakes.dart' show flushToasts;
import '../helpers/books.dart';

class MockBookServices extends Mock implements BookServices {}

class MockLibraryController extends Mock implements LibraryController {}

/// Uma Home falsa que abre o Novo livro com `push`, como a de verdade.
Widget _app() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, _) => Scaffold(
          body: TextButton(onPressed: () => context.push('/books/new'), child: const Text('HOME')),
        ),
      ),
      GoRoute(path: '/books/new', builder: (_, _) => const NewBookPage()),
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

// Ordem dos campos de texto na tela.
Finder _field(int index) => find.byType(TextFormField).at(index);
const _title = 0, _author = 1, _pages = 2, _isbn = 3, _notes = 4, _cover = 5;

void main() {
  late MockBookServices services;

  void stubCreate(Future<Map<String, dynamic>> Function() answer) {
    when(
      () => services.createBook(
        title: any(named: 'title'),
        author: any(named: 'author'),
        totalPages: any(named: 'totalPages'),
        owned: any(named: 'owned'),
        isbn: any(named: 'isbn'),
        rating: any(named: 'rating'),
        notes: any(named: 'notes'),
        coverUrl: any(named: 'coverUrl'),
      ),
    ).thenAnswer((_) => answer());
  }

  /// Abre a Home falsa e toca para abrir o Novo livro.
  Future<void> openPage(WidgetTester tester) async {
    // Tela alta: o ListView constrói o formulário inteiro de uma vez.
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.tap(find.text('HOME'));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Salvar no Caderno'));
    await tester.pump();
  }

  Future<void> fillRequired(WidgetTester tester) async {
    await tester.enterText(_field(_title), 'Torto Arado');
    await tester.enterText(_field(_author), 'Itamar Vieira Junior');
    await tester.enterText(_field(_pages), '264');
  }

  setUp(() async {
    await GetIt.instance.reset();
    services = MockBookServices();
    final library = MockLibraryController();
    when(() => library.fetchBooks()).thenAnswer((_) async {});
    GetIt.instance.registerSingleton<BookServices>(services);
    GetIt.instance.registerSingleton<LibraryController>(library);
    GetIt.instance.registerFactory<NewBookController>(() => NewBookController());
  });

  testWidgets('mostra o cabeçalho, os campos, o card e as ações do Figma', (tester) async {
    await openPage(tester);

    expect(find.text('Registro De Leitura'), findsOneWidget);
    expect(find.text('REGISTRO LITERÁRIO'), findsOneWidget);
    for (final label in ['Título *', 'Autor *', 'Total de páginas *', 'ISBN', 'Nota de 1 a 5', 'Notas', 'URL da capa']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Obrigatório'), findsNWidgets(3));
    expect(find.text('Opcional'), findsNWidgets(3));
    expect(find.text('Não avaliado'), findsOneWidget);
    expect(find.text('PÁGS'), findsOneWidget);
    expect(find.text('Tenho este livro'), findsOneWidget);
    expect(find.text('Salvar no Caderno'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('campos obrigatórios vazios: mostra os erros e "Inválido" e não chama a API', (tester) async {
    await openPage(tester);
    await tapSave(tester);

    expect(find.text('Informe o título'), findsOneWidget);
    expect(find.text('Informe o autor'), findsOneWidget);
    expect(find.text('O total de páginas deve ser maior que 0'), findsOneWidget);
    expect(find.text('Inválido'), findsNWidgets(3));
    verifyNever(
      () => services.createBook(
        title: any(named: 'title'),
        author: any(named: 'author'),
        totalPages: any(named: 'totalPages'),
        owned: any(named: 'owned'),
      ),
    );
  });

  testWidgets('tela pequena, rolada até o fim: campos fora da tela também são validados', (tester) async {
    // Regressão: com ListView, os campos fora da tela não entravam no Form.validate().
    await tester.pumpWidget(_app());
    await tester.tap(find.text('HOME'));
    await tester.pumpAndSettle();
    await tester.enterText(_field(_title), 'Torto Arado');
    // Tira o foco: o campo focado puxaria a rolagem de volta para ele.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    // Rola até o fim, como a pessoa faria (os primeiros campos saem da tela).
    final page = find.descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Scrollable)).first;
    final position = tester.state<ScrollableState>(page).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Título *')).dy, lessThan(0), reason: 'o título precisa estar fora da tela');
    await tapSave(tester);

    verifyNever(
      () => services.createBook(
        title: any(named: 'title'),
        author: any(named: 'author'),
        totalPages: any(named: 'totalPages'),
        owned: any(named: 'owned'),
      ),
    );
    expect(find.text('Informe o autor'), findsOneWidget);
  });

  testWidgets('total de páginas 0 é inválido e o "Inválido" some ao corrigir', (tester) async {
    await openPage(tester);
    await fillRequired(tester);
    await tester.enterText(_field(_pages), '0');
    await tapSave(tester);

    expect(find.text('O total de páginas deve ser maior que 0'), findsOneWidget);
    expect(find.text('Inválido'), findsOneWidget);

    await tester.enterText(_field(_pages), '120');
    await tester.pump();

    expect(find.text('Inválido'), findsNothing);
    expect(find.text('O total de páginas deve ser maior que 0'), findsNothing, reason: 'a mensagem some junto com o "Inválido"');

    // Apagar de novo volta o erro na hora (depois do primeiro "Salvar").
    await tester.enterText(_field(_pages), '');
    await tester.pump();

    expect(find.text('Inválido'), findsOneWidget);
    expect(find.text('O total de páginas deve ser maior que 0'), findsOneWidget);
  });

  testWidgets('URL da capa sem http(s): mostra o erro', (tester) async {
    await openPage(tester);
    await fillRequired(tester);
    await tester.enterText(_field(_cover), 'exemplo.com/capa.jpg');
    await tapSave(tester);

    expect(find.text('Informe um endereço que comece com http:// ou https://'), findsOneWidget);
  });

  testWidgets('nota: a estrela marca "4 de 5" e "Limpar" volta para "Não avaliado"', (tester) async {
    await openPage(tester);

    await tester.tap(find.byTooltip('4 de 5'));
    await tester.pump();
    expect(find.text('4 de 5'), findsOneWidget);

    await tester.tap(find.text('Limpar'));
    await tester.pump();
    expect(find.text('Não avaliado'), findsOneWidget);
  });

  testWidgets('salvar: envia os campos, mostra o toast e volta para a tela anterior', (tester) async {
    stubCreate(() async => {"status_code": 201, "data": bookJson(fakeBook(title: 'Torto Arado')), "error": null});
    await openPage(tester);
    await fillRequired(tester);
    await tester.enterText(_field(_isbn), '978-65-5921-000-0');
    await tester.enterText(_field(_notes), 'Releitura');
    await tester.enterText(_field(_cover), 'https://exemplo.com/capa.jpg');
    await tester.tap(find.byTooltip('5 de 5'));
    await tester.tap(find.byType(Switch));
    await tapSave(tester);
    await tester.pumpAndSettle();

    verify(
      () => services.createBook(
        title: 'Torto Arado',
        author: 'Itamar Vieira Junior',
        totalPages: 264,
        owned: true,
        isbn: '978-65-5921-000-0',
        rating: 5,
        notes: 'Releitura',
        coverUrl: 'https://exemplo.com/capa.jpg',
      ),
    ).called(1);
    expect(find.text('Livro adicionado'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.byType(NewBookPage), findsNothing);

    await flushToasts(tester);
  });

  testWidgets('erro da API: mostra a mensagem num toast e continua na tela', (tester) async {
    stubCreate(() async => booksFailure(400, 'Total de páginas inválido'));
    await openPage(tester);
    await fillRequired(tester);
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível salvar'), findsOneWidget);
    expect(find.text('Total de páginas inválido'), findsOneWidget);
    expect(find.byType(NewBookPage), findsOneWidget);

    await flushToasts(tester);
  });

  testWidgets('"Cancelar" volta para a tela anterior sem chamar a API', (tester) async {
    await openPage(tester);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(NewBookPage), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
  });
}
