import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_personal_lib_app/pages/helpers/validation_mixin.dart';

// Medidas da tela "Entrar" no Figma (em px, sem escala do sizer,
// para ficar igual ao design em qualquer tamanho de tela).
class _LoginSizes {
  _LoginSizes._();

  static const double maxWidth = 600;
  static const double horizontalPadding = 16;
  static const double topPadding = 24;
  static const double bottomPadding = 40;

  static const double logo = 56;
  static const double logoToOverline = 16;
  static const double overlineToTitle = 8;
  static const double titleToSubtitle = 6;
  static const double headerToSection = 32;
  static const double sectionTitleToSubtitle = 4;
  static const double sectionToForm = 20;
  static const double labelToField = 6;
  static const double betweenFields = 16;
  static const double fieldsToButton = 24;
  static const double buttonToLink = 20;
  static const double linkToFootnote = 56;

  static const double footnotePaddingTop = 24;
  static const double footnotePadding = 16;
  static const double footnoteIcon = 15;
  static const double footnoteIconGap = 8;
  static const double footnoteTitleToText = 8;
  static const double footnoteRadius = 4;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  // Senha escondida por padrão; o ícone de olho alterna.
  bool _obscurePassword = true;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: chamar POST /auth/login
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        // Rola em telas baixas ou com o teclado aberto.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(_LoginSizes.horizontalPadding, _LoginSizes.topPadding, _LoginSizes.horizontalPadding, _LoginSizes.bottomPadding),
          // Na web, coluna centralizada com largura máxima; no celular, ocupa a tela.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _LoginSizes.maxWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cabeçalho
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset("assets/logo/logo.svg", height: _LoginSizes.logo, width: _LoginSizes.logo),
                    ),
                    const SizedBox(height: _LoginSizes.logoToOverline),
                    Text("CADERNO DE LEITURA", style: textTheme.labelSmall?.copyWith(color: colors.secondary)),
                    const SizedBox(height: _LoginSizes.overlineToTitle),
                    Text("Biblioteca Pessoal", style: textTheme.headlineMedium),
                    const SizedBox(height: _LoginSizes.titleToSubtitle),
                    Text("Seu refúgio silencioso para páginas, notas e memórias.", style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                    const SizedBox(height: _LoginSizes.headerToSection),

                    // Seção "Acessar estante"
                    Text("Acessar estante", style: textTheme.titleLarge),
                    const SizedBox(height: _LoginSizes.sectionTitleToSubtitle),
                    Text("Continue suas anotações de onde parou.", style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                    const SizedBox(height: _LoginSizes.sectionToForm),

                    // E-mail
                    Text('E-mail', style: textTheme.labelMedium),
                    const SizedBox(height: _LoginSizes.labelToField),
                    TextFormField(
                      validator: (value) => isEmailValid(value),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      style: textTheme.bodyLarge,
                      decoration: const InputDecoration(hintText: 'seu@email.com.br'),
                    ),
                    const SizedBox(height: _LoginSizes.betweenFields),

                    // Senha (sem "Esqueceu?": recuperar senha está fora do escopo)
                    Text('Senha', style: textTheme.labelMedium),
                    const SizedBox(height: _LoginSizes.labelToField),
                    TextFormField(
                      // No login só conferimos se foi preenchida; as regras de senha valem no cadastro.
                      validator: (value) => isNotEmpty(value, 'Informe sua senha'),
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Sua senha',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          tooltip: _obscurePassword ? 'Mostrar senha' : 'Esconder senha',
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: _LoginSizes.fieldsToButton),

                    // Botão: largura total; altura e cor vêm do tema.
                    ElevatedButton(onPressed: _submit, child: const Text("Entrar")),
                    const SizedBox(height: _LoginSizes.buttonToLink),

                    // Link para criar conta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Não tem conta? ", style: textTheme.bodyMedium?.copyWith(color: colors.secondary)),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: textTheme.labelMedium?.copyWith(decoration: TextDecoration.underline),
                          ),
                          child: const Text("Criar conta"),
                        ),
                      ],
                    ),
                    const SizedBox(height: _LoginSizes.linkToFootnote),

                    // Card "Sem distrações"
                    Container(
                      padding: const EdgeInsets.fromLTRB(_LoginSizes.footnotePadding, _LoginSizes.footnotePaddingTop, _LoginSizes.footnotePadding, _LoginSizes.footnotePadding),
                      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(_LoginSizes.footnoteRadius)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book_outlined, size: _LoginSizes.footnoteIcon, color: colors.secondary),
                              const SizedBox(width: _LoginSizes.footnoteIconGap),
                              Text("SEM DISTRAÇÕES", style: textTheme.labelSmall?.copyWith(color: colors.secondary, letterSpacing: 0.275)),
                            ],
                          ),
                          const SizedBox(height: _LoginSizes.footnoteTitleToText),
                          Text(
                            "Seus dados pertencem a você. Suas notas, citações e ritmo de leitura ficam protegidos em um ambiente puramente textual.",
                            style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
