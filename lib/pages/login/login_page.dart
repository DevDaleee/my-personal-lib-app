import 'package:material_ui/material_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_personal_lib_app/controllers/auth_controller.dart';
import 'package:my_personal_lib_app/pages/components/auth_header.dart';
import 'package:my_personal_lib_app/pages/components/auth_layout.dart';
import 'package:my_personal_lib_app/pages/components/auth_switch_link.dart';
import 'package:my_personal_lib_app/pages/components/labeled_field.dart';
import 'package:my_personal_lib_app/pages/components/password_field.dart';
import 'package:my_personal_lib_app/pages/components/quiet_footnote.dart';
import 'package:my_personal_lib_app/pages/helpers/validation_mixin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final AuthController controller = GetIt.I.get<AuthController>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Observer(
      builder: (context) {
        return Form(
          key: _formKey,
          child: AuthLayout(
            children: [
              const AuthHeader(subtitle: "Seu refúgio silencioso para páginas, notas e memórias.", sectionTitle: "Acessar estante", sectionSubtitle: "Continue suas anotações de onde parou."),
              const SizedBox(height: AuthSpacing.headerToForm),

              LabeledField(
                label: 'E-mail',
                child: TextFormField(
                  controller: controller.emailController,
                  validator: (value) => isEmailValid(value),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  style: textTheme.bodyLarge,
                  decoration: const InputDecoration(hintText: 'seu@email.com.br'),
                ),
              ),
              const SizedBox(height: AuthSpacing.betweenFields),

              // Sem "Esqueceu?": recuperar senha está fora do escopo.
              LabeledField(
                label: 'Senha',
                child: PasswordField(
                  controller: controller.passwordController,
                  validator: (value) => isNotEmpty(value, 'Informe sua senha'),
                  hintText: 'Sua senha',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) async => await controller.submitLogin(_formKey, context),
                ),
              ),
              const SizedBox(height: AuthSpacing.fieldsToButton),

              // Largura total; altura e cor vêm do tema.
              ElevatedButton(
                onPressed: controller.isLoading ? null : () async => await controller.submitLogin(_formKey, context),
                child: controller.isLoading ? CircularProgressIndicator() : const Text("Entrar"),
              ),
              const SizedBox(height: AuthSpacing.buttonToLink),

              AuthSwitchLink(question: "Não tem conta?", action: "Criar conta", onPressed: () => context.go('/register')),
              const SizedBox(height: AuthSpacing.linkToFootnote),

              const QuietFootnote(
                icon: Icons.menu_book_outlined,
                title: "Sem distrações",
                text: "Seus dados pertencem a você. Suas notas, citações e ritmo de leitura ficam protegidos em um ambiente puramente textual.",
              ),
            ],
          ),
        );
      },
    );
  }
}
