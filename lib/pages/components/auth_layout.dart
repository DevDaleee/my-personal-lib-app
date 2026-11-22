import 'package:flutter/material.dart';

/// Espaçamentos verticais das telas de entrada no Figma (px).
class AuthSpacing {
  AuthSpacing._();

  static const double headerToForm = 20;
  static const double betweenFields = 16;
  static const double fieldsToButton = 24;
  static const double buttonToLink = 20;
  static const double linkToFootnote = 56;
}

/// Estrutura das telas de entrada (Entrar, Criar conta): rola em telas baixas
/// ou com o teclado aberto, fecha o teclado ao tocar fora e, na web, fica
/// numa coluna centralizada com largura máxima.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.children});

  // Medidas do Figma (px).
  static const double maxWidth = 600;
  static const EdgeInsets padding = EdgeInsets.fromLTRB(16, 24, 16, 40);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ),
        ),
      ),
    );
  }
}
