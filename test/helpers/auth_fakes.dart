import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/auth_controller.dart';
import 'package:my_personal_lib_app/pages/login/login_page.dart';
import 'package:my_personal_lib_app/pages/register/register_page.dart';
import 'package:my_personal_lib_app/pages/styles/light_theme.dart';
import 'package:my_personal_lib_app/services/api/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class MockUserServices extends Mock implements UserServices {}

// Formato único das respostas do UserServices (o mesmo em todos os caminhos):
// {"status_code": int?, "data": corpo da API ou null, "error": mensagem ou null}
Map<String, dynamic> ok(int status, Map<String, dynamic> data) => {"status_code": status, "data": data, "error": null};
Map<String, dynamic> failure(int? status, String error) => {"status_code": status, "data": null, "error": error};

/// Zera o get_it e registra um UserServices falso e um AuthController novo.
/// Por padrão, login e cadastro respondem 401 (os testes que precisam de outra resposta trocam o stub).
Future<MockUserServices> setUpAuth() async {
  final getIt = GetIt.instance;
  await getIt.reset();
  SharedPreferences.setMockInitialValues({});

  final users = MockUserServices();
  when(() => users.login(any(), any())).thenAnswer((_) async => failure(401, 'E-mail ou senha incorretos'));
  when(() => users.register(any(), any(), any())).thenAnswer((_) async => failure(409, 'E-mail já cadastrado'));

  getIt.registerSingleton<UserServices>(users);
  getIt.registerSingleton<AuthController>(AuthController());
  return users;
}

/// App mínimo com as rotas de entrada e uma Home falsa, para conferir a navegação.
Widget authApp({String initialLocation = '/'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: LoginPage()),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const Scaffold(body: RegisterPage()),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
    ],
  );
  return ToastificationWrapper(
    child: MaterialApp.router(theme: lightTheme, routerConfig: router),
  );
}

/// Deixa os toasts fecharem sozinhos (4s): libera a chave do ToastService
/// para o próximo teste e não deixa timer pendente.
Future<void> flushToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
