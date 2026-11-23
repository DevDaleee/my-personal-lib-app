import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_fakes.dart';

// O AuthController é testado pelas telas: ele recebe o formKey e o context delas.

Future<void> _tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<String?> _savedToken() async => (await SharedPreferences.getInstance()).getString(tokenKey);

void main() {
  late MockUserServices users;

  setUp(() async => users = await setUpAuth());

  group('submitLogin', () {
    Future<void> fillLogin(WidgetTester tester) async {
      await tester.enterText(find.byType(TextFormField).at(0), 'leitor@caderno.com.br');
      await tester.enterText(find.byType(TextFormField).at(1), 'Leitura#2026');
    }

    testWidgets('200: salva o token e vai para a Home', (tester) async {
      when(() => users.login(any(), any())).thenAnswer((_) async => ok(200, {'token': 'jwt.abc', 'user_id': 'u-1'}));
      await tester.pumpWidget(authApp());
      await fillLogin(tester);

      await _tapButton(tester, 'Entrar');

      verify(() => users.login('leitor@caderno.com.br', 'Leitura#2026')).called(1);
      expect(await _savedToken(), 'jwt.abc');
      expect((await SharedPreferences.getInstance()).getString(entityId), 'u-1');
      expect(find.text('HOME'), findsOneWidget);
      await flushToasts(tester);
    });

    testWidgets('401: mostra a mensagem da API e continua no login', (tester) async {
      await tester.pumpWidget(authApp());
      await fillLogin(tester);

      await _tapButton(tester, 'Entrar');

      expect(find.text('E-mail ou senha incorretos'), findsOneWidget);
      expect(find.text('Acessar estante'), findsOneWidget);
      expect(await _savedToken(), isNull);
      await flushToasts(tester);
    });

    testWidgets('sem conexão: mostra a mensagem do service', (tester) async {
      when(() => users.login(any(), any())).thenAnswer((_) async => failure(null, 'Sem conexão com o servidor'));
      await tester.pumpWidget(authApp());
      await fillLogin(tester);

      await _tapButton(tester, 'Entrar');

      expect(find.text('Sem conexão com o servidor'), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
      await flushToasts(tester);
    });

    testWidgets('formulário inválido: não chama a API', (tester) async {
      await tester.pumpWidget(authApp());

      await _tapButton(tester, 'Entrar');

      verifyNever(() => users.login(any(), any()));
    });

    testWidgets('o botão volta a ficar ativo depois da resposta', (tester) async {
      await tester.pumpWidget(authApp());
      await fillLogin(tester);

      await _tapButton(tester, 'Entrar');

      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Entrar'));
      expect(button.onPressed, isNotNull);
      await flushToasts(tester);
    });
  });

  group('submitRegister', () {
    Future<void> fillRegister(WidgetTester tester) async {
      await tester.enterText(find.byType(TextFormField).at(0), 'Clarice');
      await tester.enterText(find.byType(TextFormField).at(1), 'clarice@caderno.com.br');
      await tester.enterText(find.byType(TextFormField).at(2), 'Leitura#2026');
      await tester.enterText(find.byType(TextFormField).at(3), 'Leitura#2026');
    }

    const created = {'id': 'u-1', 'email': 'clarice@caderno.com.br', 'name': 'Clarice', 'created_at': '2026-11-22T18:00:00Z'};

    testWidgets('envia o nome digitado, o e-mail e a senha', (tester) async {
      await tester.pumpWidget(authApp(initialLocation: '/register'));
      await fillRegister(tester);

      await _tapButton(tester, 'Criar conta');

      verify(() => users.register('clarice@caderno.com.br', 'Leitura#2026', 'Clarice')).called(1);
      await flushToasts(tester);
    });

    testWidgets('201: volta para o login sem logar sozinho', (tester) async {
      when(() => users.register(any(), any(), any())).thenAnswer((_) async => ok(201, created));
      await tester.pumpWidget(authApp(initialLocation: '/register'));
      await fillRegister(tester);

      await _tapButton(tester, 'Criar conta');

      expect(find.text('Acessar estante'), findsOneWidget);
      expect(find.text('Conta criada'), findsOneWidget);
      verifyNever(() => users.login(any(), any()));
      expect(await _savedToken(), isNull);
      await flushToasts(tester);
    });

    testWidgets('201: o e-mail fica preenchido no login e a senha não', (tester) async {
      when(() => users.register(any(), any(), any())).thenAnswer((_) async => ok(201, created));
      await tester.pumpWidget(authApp(initialLocation: '/register'));
      await fillRegister(tester);

      await _tapButton(tester, 'Criar conta');

      String fieldText(int index) => tester.widget<EditableText>(find.byType(EditableText).at(index)).controller.text;
      expect(fieldText(0), 'clarice@caderno.com.br');
      expect(fieldText(1), isEmpty);
      await flushToasts(tester);
    });

    testWidgets('409: mostra a mensagem da API e continua no cadastro', (tester) async {
      await tester.pumpWidget(authApp(initialLocation: '/register'));
      await fillRegister(tester);

      await _tapButton(tester, 'Criar conta');

      expect(find.text('E-mail já cadastrado'), findsOneWidget);
      expect(find.text('Criar sua conta'), findsOneWidget);
      await flushToasts(tester);
    });

    testWidgets('senhas diferentes: não chama a API', (tester) async {
      await tester.pumpWidget(authApp(initialLocation: '/register'));
      await fillRegister(tester);
      await tester.enterText(find.byType(TextFormField).at(3), 'Leitura#2025');

      await _tapButton(tester, 'Criar conta');

      verifyNever(() => users.register(any(), any(), any()));
    });
  });
}
