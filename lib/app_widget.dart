import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:my_personal_lib_app/pages/router.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';
import 'package:my_personal_lib_app/pages/styles/dark_theme.dart';
import 'package:my_personal_lib_app/pages/styles/light_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';

class MainApp extends StatefulWidget {
  final String initialRoute;

  const MainApp({super.key, this.initialRoute = '/boot-pages'});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  SystemUiOverlayStyle _systemUiFor(Brightness platformBrightness) {
    final isDark = platformBrightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final overlayStyle = _systemUiFor(platformBrightness);
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    return ToastificationWrapper(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Sizer(
          builder: (context, orientation, screenType) {
            return MaterialApp.router(
              builder: (context, child) {
                final mq = MediaQuery.of(context);
                return MediaQuery(
                  data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2)),
                  // Na web, a tela inteira (AppBar e barra inferior incluídas) fica
                  // centralizada com no máximo 600px; o fundo aparece nas laterais.
                  child: Scaffold(
                    body: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxContentWidth),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.system,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
