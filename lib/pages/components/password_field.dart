import 'package:flutter/material.dart';

/// Campo de senha com o ícone de olho para mostrar/esconder.
/// Começa escondido; cada campo controla o próprio estado.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.validator,
    this.hintText,
    this.helperText,
    this.isNewPassword = false,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final String? hintText;
  // Dica embaixo do campo (ex.: "Mínimo de 8 caracteres"); some quando há erro.
  final String? helperText;
  // Cadastro: o gerenciador de senhas oferece criar uma senha nova.
  final bool isNewPassword;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscured,
      autofillHints: [widget.isNewPassword ? AutofillHints.newPassword : AutofillHints.password],
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hintText,
        helperText: widget.helperText,
        helperStyle: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscured = !_obscured),
          visualDensity: VisualDensity.compact,
          tooltip: _obscured ? 'Mostrar senha' : 'Esconder senha',
          icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
        ),
      ),
    );
  }
}
