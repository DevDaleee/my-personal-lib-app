import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_fakes.dart';

Widget _app() => authApp(initialLocation: '/register');

Finder _field(int index) => find.byType(TextFormField).at(index);

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Criar conta'));
  await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
  await tester.pump();
}

void main() {
  setUp(() async => await setUpAuth());

  testWidgets('mostra os textos e os quatro campos do Figma', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('Criar sua conta'), findsOneWidget);
    expect(find.text('Comece seu refúgio de leituras, anotações e memórias.'), findsOneWidget);
    for (final label in ['Nome', 'E-mail', 'Senha', 'Confirmar senha']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Mínimo de 8 caracteres'), findsOneWidget);
    expect(find.text('Já tem uma conta? '), findsOneWidget);
  });

  testWidgets('mostra os erros com os campos vazios', (tester) async {
    await tester.pumpWidget(_app());
    await _submit(tester);

    expect(find.text('Informe um nome'), findsOneWidget);
    // E-mail, Senha e Confirmar senha vazios usam a mensagem padrão do isNotEmpty.
    expect(find.text('Por favor, preencha esse campo'), findsNWidgets(3));
  });

  testWidgets('avisa quando as senhas não conferem', (tester) async {
    await tester.pumpWidget(_app());
    await tester.enterText(_field(2), 'Leitura#2026');
    await tester.enterText(_field(3), 'Leitura#2025');
    await _submit(tester);

    expect(find.text('As senhas não conferem'), findsOneWidget);
  });

  testWidgets('não mostra erros com tudo preenchido certo', (tester) async {
    await tester.pumpWidget(_app());
    await tester.enterText(_field(0), 'Clarice');
    await tester.enterText(_field(1), 'clarice@caderno.com.br');
    await tester.enterText(_field(2), 'Leitura#2026');
    await tester.enterText(_field(3), 'Leitura#2026');
    await _submit(tester);

    for (final error in ['Informe um nome', 'Informe um e-mail válido', 'As senhas não conferem', 'Por favor, preencha esse campo']) {
      expect(find.text(error), findsNothing);
    }
    await flushToasts(tester);
  });

  testWidgets('cada olho alterna só o seu campo', (tester) async {
    await tester.pumpWidget(_app());
    bool obscured(int index) => tester.widget<EditableText>(find.byType(EditableText).at(index)).obscureText;

    expect(obscured(2), isTrue);
    expect(obscured(3), isTrue);
    await tester.tap(find.byTooltip('Mostrar senha').first);
    await tester.pump();
    expect(obscured(2), isFalse);
    expect(obscured(3), isTrue);
  });
}
