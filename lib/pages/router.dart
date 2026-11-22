import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/pages/home/home_page.dart';
import 'package:my_personal_lib_app/pages/login/login_page.dart';
import 'package:my_personal_lib_app/pages/profile/profile_page.dart';
import 'package:my_personal_lib_app/pages/register/register_page.dart';

/// Rotas abertas, que não exigem sessão.
const publicRoutes = {'/', '/register'};

/// Sem token ou sem entityId salvos, qualquer rota fora das públicas volta para o login.
/// Roda em toda navegação (inclusive ao abrir o app direto numa URL na web).
Future<String?> authGuard(String location) async {
  if (publicRoutes.contains(location)) return null;

  final token = await SecurityStorage.readAccessToken();
  final userId = await SecurityStorage.readEntityId();
  final hasSession = (token?.isNotEmpty ?? false) && (userId?.isNotEmpty ?? false);

  return hasSession ? null : '/';
}

final router = GoRouter(
  redirect: (context, state) => authGuard(state.matchedLocation),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    GoRoute(path: "/home", builder: (context, state) => const HomePage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
  ],
);
