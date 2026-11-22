import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_fakes.dart';

void main() {
  setUp(() async => await setUpAuth());

  testWidgets('mostra os erros ao tocar em Entrar com os campos vazios', (tester) async {
    await tester.pumpWidget(authApp());
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });

  testWidgets('não mostra erros com e-mail válido e senha preenchida', (tester) async {
    await tester.pumpWidget(authApp());
    await tester.enterText(find.byType(TextFormField).at(0), 'leitor@caderno.com.br');
    await tester.enterText(find.byType(TextFormField).at(1), 'qualquer');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe um e-mail válido'), findsNothing);
    expect(find.text('Informe sua senha'), findsNothing);
    await flushToasts(tester);
  });

  testWidgets('a senha começa escondida e o olho alterna', (tester) async {
    await tester.pumpWidget(authApp());
    EditableText password() => tester.widget<EditableText>(find.byType(EditableText).at(1));

    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();
    expect(password().obscureText, isFalse);
    await tester.tap(find.byTooltip('Esconder senha'));
    await tester.pump();
    expect(password().obscureText, isTrue);
  });

  testWidgets('não tem o link "Esqueceu?"', (tester) async {
    await tester.pumpWidget(authApp());
    expect(find.text('Esqueceu?'), findsNothing);
  });
}
