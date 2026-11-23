import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/app_widget.dart';
import 'package:my_personal_lib_app/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupLocator();
  // Na web, o context.push também atualiza a URL (sem isso, a barra continua
  // mostrando a tela anterior, e recarregar a página volta para ela).
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const MainApp());
}
