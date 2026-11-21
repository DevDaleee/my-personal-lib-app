import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/pages/login/login_page.dart';

final router = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => LoginPage())],
);
