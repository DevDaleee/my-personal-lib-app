import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/app_widget.dart';

void main() {
  testWidgets('o app abre na tela de login', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca Pessoal'), findsOneWidget);
    expect(find.text('Acessar estante'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
