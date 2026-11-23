import 'package:material_ui/material_ui.dart';

/// Linha centralizada que troca entre Entrar e Criar conta:
/// "Não tem conta? Criar conta" / "Já tem uma conta? Entrar".
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({super.key, required this.question, required this.action, required this.onPressed});

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$question ", style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            textStyle: textTheme.labelMedium?.copyWith(decoration: TextDecoration.underline),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
