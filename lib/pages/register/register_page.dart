import 'package:material_ui/material_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_lib_app/controllers/auth_controller.dart';
import 'package:my_personal_lib_app/pages/components/auth_header.dart';
import 'package:my_personal_lib_app/pages/components/auth_layout.dart';
import 'package:my_personal_lib_app/pages/components/auth_switch_link.dart';
import 'package:my_personal_lib_app/pages/components/labeled_field.dart';
import 'package:my_personal_lib_app/pages/components/password_field.dart';
import 'package:my_personal_lib_app/pages/components/quiet_footnote.dart';
import 'package:my_personal_lib_app/pages/helpers/validation_mixin.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final AuthController controller = GetIt.I.get<AuthController>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: AuthLayout(
        children: [
          const AuthHeader(subtitle: "Comece seu refúgio de leituras, anotações e memórias.", sectionTitle: "Criar sua conta", sectionSubtitle: "Leva menos de um minuto para organizar seus livros."),
          const SizedBox(height: AuthSpacing.headerToForm),

          // Nome livre: como a pessoa quer ser identificada (não precisa ser o completo).
          LabeledField(
            label: 'Nome',
            child: TextFormField(
              controller: controller.nameController,
              validator: (value) => isNotEmpty(value, 'Informe um nome'),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.next,
              style: textTheme.bodyLarge,
              decoration: const InputDecoration(hintText: 'Como quer que te chamem'),
            ),
          ),
          const SizedBox(height: AuthSpacing.betweenFields),

          LabeledField(
            label: 'E-mail',
            child: TextFormField(
              controller: controller.emailController,
              validator: (value) => combineValidations([() => isNotEmpty(value), () => isEmailValid(value)]),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              style: textTheme.bodyLarge,
              decoration: const InputDecoration(hintText: 'seu@email.com.br'),
            ),
          ),
          const SizedBox(height: AuthSpacing.betweenFields),

          LabeledField(
            label: 'Senha',
            child: PasswordField(
              controller: controller.passwordController,
              validator: (value) => combineValidations([() => isNotEmpty(value), () => isPasswordValid(value)]),
              hintText: 'Crie uma senha segura',
              helperText: 'Mínimo de 8 caracteres',
              isNewPassword: true,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: AuthSpacing.betweenFields),

          LabeledField(
            label: 'Confirmar senha',
            child: PasswordField(
              controller: controller.rpasswordController,
              validator: (value) => combineValidations([() => isNotEmpty(value), () => value != controller.passwordController.text ? 'As senhas não conferem' : null]),
              hintText: 'Repita a senha digitada',
              isNewPassword: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) async => await controller.submitRegister(_formKey, context),
            ),
          ),
          const SizedBox(height: AuthSpacing.fieldsToButton),

          // Largura total; altura e cor vêm do tema.
          ElevatedButton(
            onPressed: controller.isLoading ? null : () async => await controller.submitRegister(_formKey, context),
            child: controller.isLoading ? CircularProgressIndicator() : const Text("Criar conta"),
          ),
          const SizedBox(height: AuthSpacing.buttonToLink),

          AuthSwitchLink(question: "Já tem uma conta?", action: "Entrar", onPressed: () => context.go('/')),
          const SizedBox(height: AuthSpacing.linkToFootnote),

          const QuietFootnote(
            icon: Icons.menu_book_outlined,
            title: "Sem distrações",
            text: "Seus dados pertencem a você. Suas notas, citações e ritmo de leitura ficam protegidos em um ambiente puramente textual.",
          ),
        ],
      ),
    );
  }
}
