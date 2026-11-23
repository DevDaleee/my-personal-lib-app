import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/app_widget.dart';

import 'helpers/auth_fakes.dart';

void main() {
  setUp(() async => await setUpAuth());

  testWidgets('o app abre na tela de login', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca Pessoal'), findsOneWidget);
    expect(find.text('Acessar estante'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('os links levam do login ao cadastro e de volta', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    expect(find.text('Criar sua conta'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Entrar'));
    await tester.tap(find.widgetWithText(TextButton, 'Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Acessar estante'), findsOneWidget);
  });
}
